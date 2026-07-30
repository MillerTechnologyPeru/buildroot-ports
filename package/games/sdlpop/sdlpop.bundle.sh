# SDLPoP - an open-source reimplementation of Prince of Persia (1989).
#
# The bundle form of this package: sdlpop.mk builds it into the rootfs, this
# builds the same upstream into an AppRuntime bundle on the data partition.
#
# CMake (in src/), SDL2 + SDL2_image, both in the SDK sysroots - so the whole
# thing cross-compiles with clang and nothing is built from source but the game.
#
# Upstream ships the level data, so this is a complete game: no assets have to
# be supplied on the device.

APP_ID="io.github.nagyd.sdlpop"
APP_NAME="SDLPoP"
APP_DESCRIPTION="Prince of Persia, reimplemented from the 1989 original"
APP_EXECUTABLE="prince"
APP_VERSION="1.23"
APP_BUILD="1"
APP_CAPABILITIES="Display Audio"
APP_COPYRIGHT="SDLPoP contributors; original game by Jordan Mechner"

SDLPOP_REPO="https://github.com/NagyD/SDLPoP"
SDLPOP_TAG="v1.23"

app_fetch() {
	fetch_git "$1" "$SDLPOP_REPO" "$SDLPOP_TAG"
	SDLPOP_SRC="$1"
}

app_build() {
	# The CMake project is in src/, not at the top of the tree.
	#
	# _GNU_SOURCE: the project compiles as strict C99, under which glibc hides
	# strdup/strnlen/fileno, and clang treats the resulting implicit
	# declarations as errors rather than warnings the way older gcc did.
	#
	# The project sets CMAKE_RUNTIME_OUTPUT_DIRECTORY to the top of its own
	# source tree, and a plain set() shadows any -D override, so the binary
	# lands next to the sources rather than in the build directory - the same
	# place for every architecture. Delete it first: without that, an
	# architecture whose link failed would silently inherit the previous one's
	# binary and the bundle would ship an arm64 build as x86_64.
	rm -f "$SDLPOP_SRC/$APP_EXECUTABLE"
	cmake_cross "$2" "$3" "$SDLPOP_SRC/src" "$(dirname "$4")/cmake" \
		-DCMAKE_C_FLAGS="-D_GNU_SOURCE"
	take_binary "$SDLPOP_SRC" "$APP_EXECUTABLE" "$4"
}

app_stage() {
	bundle="$1"
	# Levels, graphics and sound, all architecture-independent. The game opens
	# them as "data/..." relative to its working directory, which the launcher
	# sets to the bundle root.
	cp -R "$SDLPOP_SRC/data/." "$bundle/resources/"
	ln -sfn resources "$bundle/data"
	# Read at startup from the working directory as well.
	cp "$SDLPOP_SRC/SDLPoP.ini" "$bundle/SDLPoP.ini"
	# SDL2 and SDL2_image are the image's, so nothing goes in lib/<arch>.
}
