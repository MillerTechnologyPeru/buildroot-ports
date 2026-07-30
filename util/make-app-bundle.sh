#!/bin/bash
# Build a port into a multi-architecture AppRuntime bundle:
#
#     util/make-app-bundle.sh ccleste
#     util/make-app-bundle.sh ccleste --arch "arm64 x86_64" --pack
#
# The bundle format is PureSwift/AppRuntime's (Documentation/BundleFormat.md):
# a <id>.app directory holding manifest.json, bin/<arch>/<executable>, the
# architecture-independent resources/, and a run.sh that picks an architecture
# and execs. Bundles are user content - they live on the data partition and
# survive A/B updates, so a port needs no image rebuild.
#
# No cross-toolchain is built. One clang cross-compiles every target, driven
# with --target/--sysroot/-fuse-ld=lld against the Swift Linux SDK sysroots,
# which carry the folded cross-gcc (crt objects, libgcc) clang discovers from
# the sysroot alone - the same mechanism swift-linux's
# util/make-cmake-toolchain.sh relies on. clang/lld come from the host Swift
# toolchain; the SDK bundle itself ships no compilers.
#
# Getting a bundle onto a device: copy the .squashfs to /data/apps, where the
# frontend's Apps group picks it up and es-launch loop-mounts it and runs
# run.sh. Two things to know before relying on that:
#   - Only the EmulationStation frontend enables CONFIG_SQUASHFS/_ZSTD and the
#     loop device (see the emulationstation package's config fixups), so a
#     GNOME/XFCE/gmenu2x image cannot mount a bundle at all.
#   - The Ports group accepts only .sh - /data/apps is the place for bundles.
#   - The on-device mksquashfs is gzip-only (BR2_PACKAGE_SQUASHFS with no
#     compressor suboptions), so zstd bundles have to be built on a host.
#
# Usage:
#   util/make-app-bundle.sh <recipe> [--arch "a b"] [--sdk N] [--out DIR] [--pack]
#
#   <recipe>   a package name (e.g. ccleste), whose recipe is read from
#              package/<category>/<name>/<name>.bundle.sh, or a path to one.
#   --arch     architectures to build (default: arm64 x86_64 armv7 i386).
#              Each is skipped with a warning if the SDK has no sysroot for it,
#              so a single-arch bundle from a single-arch SDK still works.
#   --sdk      Swift SDK bundle name in ~/.swiftpm/swift-sdks, or a path to an
#              .artifactbundle (default: swift-linux, the combined all-arch one).
#   --out      output directory (default: output/apps).
#   --pack     also pack a plain squashfs image next to the bundle. Offset 0,
#              not the spec's self-executing polyglot: es-squashfs mounts with
#              "mount -o loop,ro" and no offset, so an offset image would not
#              mount on the device at all.
set -eu

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RECIPE=""; ARCHES=""; SDK="swift-linux"; OUT=""; PACK=0
while [ $# -gt 0 ]; do
	case "$1" in
		--arch) ARCHES="$2"; shift 2 ;;
		--sdk) SDK="$2"; shift 2 ;;
		--out) OUT="$2"; shift 2 ;;
		--pack) PACK=1; shift ;;
		-h|--help) grep '^#' "$0" | sed 's/^# \?//'; exit 0 ;;
		-*) echo "unknown arg: $1" >&2; exit 1 ;;
		*) [ -z "$RECIPE" ] || { echo "error: one recipe at a time" >&2; exit 1; }
		   RECIPE="$1"; shift ;;
	esac
done

[ -n "$RECIPE" ] || { echo "error: no recipe given (try: $(basename "$0") ccleste)" >&2; exit 1; }
ARCHES="${ARCHES:-arm64 x86_64 armv7 i386}"
OUT="${OUT:-$REPO_DIR/output/apps}"

command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 1; }

# The triples the SDK bundles are keyed by (util/make-swift-sdk.sh).
triple_for_arch() {
	case "$1" in
		arm64|aarch64) echo "aarch64-unknown-linux-gnu" ;;
		x86_64|amd64)  echo "x86_64-unknown-linux-gnu" ;;
		armv7|arm)     echo "armv7-unknown-linux-gnueabihf" ;;
		i386|i686)     echo "i686-unknown-linux-gnu" ;;
		*) return 1 ;;
	esac
}

# clang from PATH, or next to swiftc (Swift toolchains ship clang and lld).
CLANG="${CLANG:-$(command -v clang || true)}"
if [ -z "$CLANG" ] && command -v swiftc >/dev/null; then
	c="$(dirname "$(command -v swiftc)")/clang"
	[ -x "$c" ] && CLANG="$c"
fi
[ -n "$CLANG" ] || { echo "error: clang not found (install a Swift toolchain or LLVM)" >&2; exit 1; }

# Strip with LLVM's tools: the host may be macOS, whose strip cannot touch an
# ELF file. Silently leaving binaries unstripped would triple the bundle, so
# this reports what it found rather than swallowing a failure.
STRIP=""
for s in "$(dirname "$CLANG")/llvm-strip" "$(dirname "$CLANG")/llvm-objcopy" \
         "$(command -v llvm-strip || true)" "$(command -v llvm-objcopy || true)"; do
	[ -n "$s" ] && [ -x "$s" ] && { STRIP="$s"; break; }
done
strip_elf() {
	case "$STRIP" in
		"") return 0 ;;
		*llvm-objcopy) "$STRIP" --strip-all "$1" ;;
		*) "$STRIP" "$1" ;;
	esac
}

BUNDLE_ROOT="$SDK"
[ -d "$BUNDLE_ROOT" ] || BUNDLE_ROOT="$HOME/.swiftpm/swift-sdks/$SDK"
[ -d "$BUNDLE_ROOT" ] || BUNDLE_ROOT="$HOME/.swiftpm/swift-sdks/$SDK.artifactbundle"
[ -d "$BUNDLE_ROOT" ] || { echo "error: SDK bundle not found: $SDK" >&2; exit 1; }
SDK_JSON="$(find "$BUNDLE_ROOT" -maxdepth 2 -name swift-sdk.json | head -1)"
[ -n "$SDK_JSON" ] || { echo "error: no swift-sdk.json in $BUNDLE_ROOT" >&2; exit 1; }

# Resolve a triple's sysroot the way make-cmake-toolchain.sh does: portable
# bundles record it relative to swift-sdk.json, local ones absolute.
sysroot_for_triple() {
	rel=$(jq -r --arg t "$1" '.targetTriples[$t].sdkRootPath // empty' "$SDK_JSON")
	[ -n "$rel" ] || return 1
	case "$rel" in
		/*) echo "$rel" ;;
		*)  echo "$(cd "$(dirname "$SDK_JSON")/$rel" && pwd)" ;;
	esac
}

# A recipe defines the metadata and the per-architecture build, and lives with
# the rest of its package (package/<category>/<pkg>/<pkg>.bundle.sh) so a port's
# in-image and bundle forms sit side by side.
RECIPE_FILE="$RECIPE"
if [ ! -f "$RECIPE_FILE" ]; then
	RECIPE_FILE="$(find "$REPO_DIR/package" -mindepth 3 -maxdepth 3 \
		-name "$RECIPE.bundle.sh" 2>/dev/null | head -1)"
fi
if [ -z "$RECIPE_FILE" ] || [ ! -f "$RECIPE_FILE" ]; then
	echo "error: no recipe for '$RECIPE'; packages with one:" >&2
	find "$REPO_DIR/package" -mindepth 3 -maxdepth 3 -name '*.bundle.sh' 2>/dev/null |
		sed 's#.*/##; s#\.bundle\.sh$##' | sort | sed 's/^/  /' >&2
	exit 1
fi
APP_CAPABILITIES=""; APP_RUN_ENV=""
# shellcheck source=/dev/null
. "$RECIPE_FILE"
for v in APP_ID APP_NAME APP_DESCRIPTION APP_EXECUTABLE APP_VERSION APP_BUILD; do
	eval "[ -n \"\${$v:-}\" ]" || { echo "error: $RECIPE_FILE sets no $v" >&2; exit 1; }
done
command -v app_build >/dev/null || { echo "error: $RECIPE_FILE defines no app_build" >&2; exit 1; }

WORK="$OUT/.build/$APP_ID"
BUNDLE="$OUT/$APP_ID.app"
mkdir -p "$WORK"
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/bin" "$BUNDLE/resources"

echo "==> $APP_NAME $APP_VERSION ($APP_ID)"
if command -v app_fetch >/dev/null; then
	SRC_DIR="$WORK/src"
	app_fetch "$SRC_DIR"
fi

BUILT=""
for arch in $ARCHES; do
	triple="$(triple_for_arch "$arch")" || { echo "  skip $arch: unknown architecture" >&2; continue; }
	sysroot="$(sysroot_for_triple "$triple")" || { echo "  skip $arch: $SDK has no $triple" >&2; continue; }
	echo "--> $arch ($triple)"
	binary="$WORK/$arch/$APP_EXECUTABLE"
	mkdir -p "$WORK/$arch"
	app_build "$arch" "$triple" "$sysroot" "$binary"
	[ -f "$binary" ] || { echo "error: $arch build produced no $binary" >&2; exit 1; }
	install -d "$BUNDLE/bin/$arch"
	install -m 755 "$binary" "$BUNDLE/bin/$arch/$APP_EXECUTABLE"
	strip_elf "$BUNDLE/bin/$arch/$APP_EXECUTABLE"
	BUILT="$BUILT $arch"
done
[ -n "$BUILT" ] || { echo "error: nothing built" >&2; exit 1; }

# Architecture-independent payload, plus whatever paths the binary opens
# relative to its working directory (the launcher cds to the bundle root).
if command -v app_stage >/dev/null; then
	echo "==> Staging resources"
	app_stage "$BUNDLE"
fi

# manifest.json. "architectures" is ordered best-first: the launcher takes the
# first entry it can run, so a native slot must precede one needing a
# translator.
echo "==> Writing manifest.json"
arch_json=""
for arch in arm64 x86_64 armv7 i386; do
	case " $BUILT " in *" $arch "*) arch_json="$arch_json${arch_json:+, }\"$arch\"" ;; esac
done
caps_json=""
for cap in $APP_CAPABILITIES; do caps_json="$caps_json${caps_json:+, }\"$cap\""; done
{
	printf '{\n'
	printf '  "formatVersion" : 1,\n'
	printf '  "id" : "%s",\n' "$APP_ID"
	printf '  "name" : "%s",\n' "$APP_NAME"
	printf '  "description" : "%s",\n' "$APP_DESCRIPTION"
	printf '  "sdk" : "%s",\n' "${APP_SDK:-1.0}"
	printf '  "executable" : "%s",\n' "$APP_EXECUTABLE"
	printf '  "version" : "%s",\n' "$APP_VERSION"
	printf '  "build" : "%s",\n' "$APP_BUILD"
	[ -n "${APP_COPYRIGHT:-}" ] && printf '  "copyright" : "%s",\n' "$APP_COPYRIGHT"
	[ -n "$caps_json" ] && printf '  "capabilities" : [ %s ],\n' "$caps_json"
	printf '  "architectures" : [ %s ]\n' "$arch_json"
	printf '}\n'
} > "$BUNDLE/manifest.json"

# run.sh: the bundle's own launcher, so a bundle runs from a plain shell as
# well as through the frontend. es-launch finds run.sh at the flat root, cds
# to the mount and runs it - but it exports no LD_LIBRARY_PATH, so private
# libraries are this script's business.
echo "==> Writing run.sh"
cat > "$BUNDLE/run.sh" <<EOF
#!/bin/sh
# Generated by util/make-app-bundle.sh - regenerate rather than edit.
#
# No "set -e": every slot below is tried in turn and a missing one returns 1,
# which under -e would exit here instead of falling through to the next
# architecture - taking the required diagnostic with it.
set -u
HERE=\$(CDPATH= cd -- "\$(dirname -- "\$0")" && pwd) || exit 1
cd "\$HERE" || exit 1
${APP_RUN_ENV}
run() {
	arch=\$1; shift
	bin="\$HERE/bin/\$arch/$APP_EXECUTABLE"
	[ -x "\$bin" ] || return 1
	[ -d "\$HERE/lib/\$arch" ] && export LD_LIBRARY_PATH="\$HERE/lib/\$arch\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
	exec "\$@" "\$bin"
}

# Native first, then a translator. box64/box86 run x86 builds on ARM.
case "\$(uname -m)" in
	aarch64|arm64)
		run arm64
		run armv7
		command -v box64 >/dev/null 2>&1 && run x86_64 box64
		command -v box86 >/dev/null 2>&1 && run i386 box86
		;;
	armv7l|armv7|armv6l|arm)
		run armv7
		command -v box86 >/dev/null 2>&1 && run i386 box86
		;;
	x86_64|amd64)
		run x86_64
		run i386
		;;
	i386|i486|i586|i686)
		run i386
		;;
esac
echo "run.sh: no runnable binary for \$(uname -m)" >&2
exit 1
EOF
chmod 755 "$BUNDLE/run.sh"

if [ "$PACK" = 1 ]; then
	if command -v mksquashfs >/dev/null 2>&1; then
		IMAGE="$OUT/$APP_ID.app.squashfs"
		rm -f "$IMAGE"
		echo "==> Packing $IMAGE"
		# zstd: the kernel mounts it (CONFIG_SQUASHFS_ZSTD, enabled with the
		# frontend) and it beats gzip on both size and decompression.
		# -no-xattrs: a macOS host tags files with com.apple.provenance, which
		# has no meaning on the device and which mksquashfs warns about.
		mksquashfs "$BUNDLE" "$IMAGE" -comp zstd -all-root -noappend -no-xattrs -quiet
	else
		echo "warning: mksquashfs not found; bundle directory is complete" >&2
	fi
fi

echo "bundle    : $BUNDLE"
echo "arches    :$BUILT"
echo "clang     : $CLANG"
echo "strip     : ${STRIP:-<none, binaries not stripped>}"
