################################################################################
#
# roms-homebrew-bass
#
################################################################################

ROMS_HOMEBREW_BASS_VERSION = 1.3
ROMS_HOMEBREW_BASS_SITE = https://downloads.scummvm.org/frs/extras/Beneath%20a%20Steel%20Sky
ROMS_HOMEBREW_BASS_SOURCE = BASS-Floppy-$(ROMS_HOMEBREW_BASS_VERSION).zip
# The game needs ScummVM's sky.cpt engine data, which the core does not
# install. ScummVM also looks in the game's own directory, so ship it there,
# from the same ScummVM commit libretro-scummvm builds.
ROMS_HOMEBREW_BASS_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/libretro/scummvm/$(LIBRETRO_SCUMMVM_VERSION)/dists/engine-data/sky.cpt
# Revolution's freeware license, in the readme: free redistribution,
# including in a Linux distribution, with the readme intact. sky.cpt is
# ScummVM's, GPL-3.0.
ROMS_HOMEBREW_BASS_LICENSE = Freeware (game), GPL-3.0 (sky.cpt)
ROMS_HOMEBREW_BASS_LICENSE_FILES = readme.txt

define ROMS_HOMEBREW_BASS_EXTRACT_CMDS
	$(UNZIP) -q -d $(@D) $(ROMS_HOMEBREW_BASS_DL_DIR)/$(ROMS_HOMEBREW_BASS_SOURCE)
	cp $(ROMS_HOMEBREW_BASS_DL_DIR)/sky.cpt $(@D)/
endef

# A ScummVM entry is a directory holding the game and a .scummvm file that
# names its ScummVM game id.
ROMS_HOMEBREW_BASS_GAME_DIR = $(TARGET_DIR)/usr/share/roms-homebrew/scummvm/Beneath a Steel Sky

define ROMS_HOMEBREW_BASS_INSTALL_TARGET_CMDS
	$(INSTALL) -d "$(ROMS_HOMEBREW_BASS_GAME_DIR)"
	$(INSTALL) -m 0644 $(@D)/sky.dnr $(@D)/sky.dsk $(@D)/sky.cpt $(@D)/readme.txt \
		"$(ROMS_HOMEBREW_BASS_GAME_DIR)/"
	echo sky > "$(ROMS_HOMEBREW_BASS_GAME_DIR)/Beneath a Steel Sky.scummvm"
endef

$(eval $(generic-package))
