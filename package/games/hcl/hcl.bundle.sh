# hcl - Hydra Castle Labyrinth, Buster's freeware platformer, ported to SDL2
# by ptitSeb.
#
# The bundle form of this package: hcl.mk builds it into the rootfs, this builds
# the same upstream into an AppRuntime bundle on the data partition.
#
# CMake, SDL2 + SDL2_mixer, both in the SDK sysroots. Upstream ships the game
# data and an icon, so the bundle is complete and needs nothing on the device.

APP_ID="io.github.ptitseb.hydracastlelabyrinth"
APP_NAME="Hydra Castle Labyrinth"
APP_DESCRIPTION="Buster's freeware exploration platformer"
APP_EXECUTABLE="hcl"
APP_VERSION="1.3.4"
APP_BUILD="1"
APP_CAPABILITIES="Display Audio"
APP_COPYRIGHT="Buster (original game); SDL2 port by ptitSeb"

HCL_REPO="https://github.com/ptitSeb/hydracastlelabyrinth"
# Same commit nanosaur2-style pinning as hcl.mk's HCL_VERSION.
HCL_COMMIT="a4000681a20cd6639183cf72a722f4c2daf30cc7"

app_fetch() {
	fetch_git "$1" "$HCL_REPO" "$HCL_COMMIT"
	HCL_SRC="$1"
}

app_build() {
	# USE_SDL2 as in hcl.mk: the default is the SDL 1.2 backend.
	cmake_cross "$2" "$3" "$HCL_SRC" "$(dirname "$4")/cmake" -DUSE_SDL2=ON
	take_binary "$(dirname "$4")/cmake" "$APP_EXECUTABLE" "$4"
}

app_stage() {
	bundle="$1"
	# Maps, sprites and music, opened as "data/..." relative to the working
	# directory the launcher sets to the bundle root.
	cp -R "$HCL_SRC/data/." "$bundle/resources/"
	ln -sfn resources "$bundle/data"
	[ -f "$HCL_SRC/icon.png" ] && cp "$HCL_SRC/icon.png" "$bundle/icon.png"
	# SDL2 and SDL2_mixer are the image's, so nothing goes in lib/<arch>.
}
