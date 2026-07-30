################################################################################
#
# game-music-emu
#
# Needed by sdl3_mixer for GME (console chiptune) playback. The Nuked
# YM2612 emulator is picked because the MAME one would make the whole
# library GPL-2.0+.
#
################################################################################

GAME_MUSIC_EMU_VERSION = 0.6.5
GAME_MUSIC_EMU_SITE = $(call github,libgme,game-music-emu,$(GAME_MUSIC_EMU_VERSION))
GAME_MUSIC_EMU_LICENSE = LGPL-2.1+
GAME_MUSIC_EMU_LICENSE_FILES = license.txt
GAME_MUSIC_EMU_INSTALL_STAGING = YES
GAME_MUSIC_EMU_DEPENDENCIES = host-pkgconf zlib

# Upstream still declares a CMake 3.3 minimum, which CMake 4.x refuses to
# accept; the policy floor keeps it configuring with a 4.x host cmake.
GAME_MUSIC_EMU_CONF_OPTS = \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DGME_YM2612_EMU=Nuked \
	-DGME_ZLIB=ON \
	-DGME_BUILD_EXAMPLES=OFF \
	-DGME_BUILD_TESTING=OFF \
	-DGME_BUILD_SHARED=$(if $(BR2_STATIC_LIBS),OFF,ON) \
	-DGME_BUILD_STATIC=$(if $(BR2_SHARED_LIBS),OFF,ON)

$(eval $(cmake-package))
