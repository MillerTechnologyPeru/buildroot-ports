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
	# Pomme (the Mac Toolbox reimplementation) is a submodule, and the game data
	# only exists in the git tree.
	fetch_git "$1" "$NANOSAUR2_REPO" "$NANOSAUR2_COMMIT" submodules
	NANOSAUR2_SRC="$1"
}

app_build() {
	build="$(dirname "$4")/cmake"
	cmake_cross "$2" "$3" "$NANOSAUR2_SRC" "$build" -DBUILD_SDL_FROM_SOURCE=OFF
	# The project has no install rules - it leaves a runnable game in the build
	# directory - so take the executable from wherever it landed.
	take_binary "$build" "$APP_EXECUTABLE" "$4"
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
