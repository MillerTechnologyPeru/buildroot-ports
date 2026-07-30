# ccleste - Celeste Classic, a hand translation of the PICO-8 cart to C.
#
# Recipe for util/make-app-bundle.sh. A plain two-file compile: sdl12main.c is
# the SDL frontend, celeste.c the game logic, and they link against the SDL2
# and SDL2_mixer the image already ships.
#
# Not built through upstream's Makefile: it takes its SDL flags from
# sdl2-config, and the SDK sysroots carry no sdl2-config (the pkg-config files
# are there, but for two translation units a direct clang call is clearer than
# teaching make about a sysroot).
#
# The bundle form of this package: ccleste.mk builds the game into the rootfs,
# this builds the same upstream into an AppRuntime bundle that lands on the data
# partition instead. The two are independent - either, both or neither.
#
# Version is pinned separately from CCLESTE_VERSION in ccleste.mk on purpose: a
# bundle is published and updated on its own schedule, not the image's.

APP_ID="io.github.lemon32767.ccleste"
APP_NAME="Celeste Classic"
APP_DESCRIPTION="The original Celeste, translated from PICO-8 to C"
APP_EXECUTABLE="ccleste"
APP_VERSION="1.4.0"
APP_BUILD="1"
APP_CAPABILITIES="Display Audio"
APP_COPYRIGHT="Maddy Thorson & Noel Berry; C port by lemon32767"

CCLESTE_REPO="https://github.com/lemon32767/ccleste"
CCLESTE_TAG="v1.4.0"

# The bundle mount is read-only and the game writes its input configuration
# into the working directory, which is the bundle root. Both paths it opens
# have an environment override, so point the writable one at the save tree -
# es-launch exports XDG_DATA_HOME=/data/saves.
APP_RUN_ENV='CFG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ccleste"
mkdir -p "$CFG_DIR" 2>/dev/null || true
export CCLESTE_INPUT_CFG_PATH="$CFG_DIR/input-cfg.txt"'

app_fetch() {
	src="$1"
	if [ -d "$src/.git" ]; then
		echo "  sources: $src (cached)"
	else
		rm -rf "$src"
		git clone --depth 1 --branch "$CCLESTE_TAG" "$CCLESTE_REPO" "$src"
	fi
	CCLESTE_SRC="$src"
}

app_build() {
	arch="$1"; triple="$2"; sysroot="$3"; out="$4"
	# No -latomic (which the Swift SDK's toolset adds for Swift's sake): every
	# target links without it, including armv7, and naming it would put a
	# libatomic.so.1 dependency in the binary the game never needs.
	"$CLANG" --target="$triple" --sysroot="$sysroot" -fuse-ld=lld \
		-O2 -fPIC -D_REENTRANT \
		-I"$sysroot/usr/include/SDL2" \
		"$CCLESTE_SRC/sdl12main.c" "$CCLESTE_SRC/celeste.c" \
		-o "$out" \
		-L"$sysroot/usr/lib" -lSDL2 -lSDL2_mixer -lm
}

app_stage() {
	bundle="$1"
	# Graphics, sounds and music are architecture-independent.
	cp -R "$CCLESTE_SRC/data/." "$bundle/resources/"
	# The binary opens "data/<file>" relative to the working directory, which
	# the launcher sets to the bundle root.
	ln -sfn resources "$bundle/data"
	# Controller mappings are read from the working directory too, and live at
	# the top of the source tree rather than in data/.
	cp "$CCLESTE_SRC/gamecontrollerdb.txt" "$bundle/gamecontrollerdb.txt"
	[ -f "$CCLESTE_SRC/icon.png" ] && cp "$CCLESTE_SRC/icon.png" "$bundle/icon.png"
	# SDL2 and SDL2_mixer are part of the image, so nothing goes in lib/<arch>:
	# the format forbids bundling a soname the rootfs already provides.
}
