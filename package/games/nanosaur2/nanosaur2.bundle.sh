# nanosaur2 - Nanosaur II: Hatchling, Pangea's 2004 sequel ported by Iliyas
# Jorio, running on the Pomme reimplementation of the Mac Toolbox.
#
# The bundle form of this package: nanosaur2.mk builds the game into the rootfs,
# this builds the same upstream into an AppRuntime bundle on the data partition.
#
# CMake, C++20, SDL3 and fixed-function desktop OpenGL - all of which the SDK
# sysroots carry (libGL.so, libSDL3.so and SDL3's own cmake config), so nothing
# is built from source but the game.
#
# Pinned to the same commit as nanosaur2.mk rather than to v2.1.0: the only tag
# predates the move to SDL3, and building it here would mean linking against the
# SDL2 the rest of the image is moving away from. The tree needs git and its
# submodules - Pomme is one, and the release tarball carries neither it nor the
# game data.
#
# Assets: about 113 MB of them, which is most of the bundle. They are
# CC-BY-NC-SA-4.0 (Pomme itself is MIT), so a bundle you build and install is
# fine, but publishing one commercially is not - which is also why
# nanosaur2.mk sets NANOSAUR2_REDISTRIBUTE = NO.

APP_ID="io.jorio.nanosaur2"
APP_NAME="Nanosaur II"
APP_DESCRIPTION="Fly an armed pterodactyl through Pangea's 2004 sequel"
APP_EXECUTABLE="Nanosaur2"
APP_VERSION="2.1.0"
APP_BUILD="1"
APP_CAPABILITIES="Display Audio"
APP_COPYRIGHT="Pangea Software; port by Iliyas Jorio"

NANOSAUR2_REPO="https://github.com/jorio/Nanosaur2.git"
# Post-v2.1.0 SDL3 commit; keep in step with NANOSAUR2_VERSION in nanosaur2.mk.
NANOSAUR2_COMMIT="56cac5bc849a8eb90b3fa84e3826b2cadc1d4855"

app_fetch() {
	src="$1"
	# A pinned commit cannot be cloned with --branch, and the submodules are
	# not optional, so fetch the one commit and its submodules by hand.
	if [ -d "$src/.git" ]; then
		echo "  sources: $src (cached)"
	else
		rm -rf "$src"
		mkdir -p "$src"
		git -C "$src" init -q
		git -C "$src" remote add origin "$NANOSAUR2_REPO"
		git -C "$src" fetch -q --depth 1 origin "$NANOSAUR2_COMMIT"
		git -C "$src" checkout -q FETCH_HEAD
		git -C "$src" submodule update -q --init --depth 1 --recursive
	fi
	NANOSAUR2_SRC="$src"
}

app_build() {
	arch="$1"; triple="$2"; sysroot="$3"; out="$4"
	build="$(dirname "$out")/cmake"

	# pkg-config has to be told to look in the sysroot and nowhere else, or a
	# host .pc file answers for the target.
	PKG_CONFIG_SYSROOT_DIR="$sysroot" \
	PKG_CONFIG_LIBDIR="$sysroot/usr/lib/pkgconfig:$sysroot/usr/share/pkgconfig" \
	cmake -S "$NANOSAUR2_SRC" -B "$build" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR="${triple%%-*}" \
		-DCMAKE_SYSROOT="$sysroot" \
		-DCMAKE_C_COMPILER="$CLANG" \
		-DCMAKE_CXX_COMPILER="$CLANGXX" \
		-DCMAKE_C_COMPILER_TARGET="$triple" \
		-DCMAKE_CXX_COMPILER_TARGET="$triple" \
		-DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
		-DCMAKE_FIND_ROOT_PATH="$sysroot" \
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
		-DBUILD_SDL_FROM_SOURCE=OFF \
		>/dev/null
	cmake --build "$build" --parallel

	# The project has no install rules - it leaves a runnable game in the build
	# directory - so take the executable from wherever it landed.
	bin="$build/$APP_EXECUTABLE"
	[ -f "$bin" ] || bin="$(find "$build" -maxdepth 2 -type f -name "$APP_EXECUTABLE" | head -1)"
	[ -n "$bin" ] || { echo "error: no $APP_EXECUTABLE in $build" >&2; return 1; }
	cp "$bin" "$out"
}

app_stage() {
	bundle="$1"
	# The assets are architecture-independent, and the game looks for a "Data"
	# directory in its working directory - which the launcher sets to the bundle
	# root. That path needs no patching, unlike an installed copy under a
	# prefix (see the package's data-directory patch).
	cp -R "$NANOSAUR2_SRC/Data/." "$bundle/resources/"
	ln -sfn resources "$bundle/Data"
	# Upstream's desktop-packaging icon, under the name the format expects.
	icon="$NANOSAUR2_SRC/packaging/io.jor.nanosaur2.png"
	[ -f "$icon" ] && cp "$icon" "$bundle/icon.png"
	# SDL3 and libGL belong to the image, so nothing goes in lib/<arch>.
}
