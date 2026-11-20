################################################################################
#
# roms-homebrew-lutro-pong
#
################################################################################

ROMS_HOMEBREW_LUTRO_PONG_VERSION = 0.0.1
ROMS_HOMEBREW_LUTRO_PONG_SITE = https://github.com/libretro/lutro-pong/releases/download/$(ROMS_HOMEBREW_LUTRO_PONG_VERSION)
ROMS_HOMEBREW_LUTRO_PONG_SOURCE = lutro-pong.lutro
ROMS_HOMEBREW_LUTRO_PONG_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/libretro/lutro-pong/$(ROMS_HOMEBREW_LUTRO_PONG_VERSION)/LICENSE.md
ROMS_HOMEBREW_LUTRO_PONG_LICENSE = MIT
ROMS_HOMEBREW_LUTRO_PONG_LICENSE_FILES = LICENSE.md

# A .lutro file is a zip archive the core loads as is.
define ROMS_HOMEBREW_LUTRO_PONG_EXTRACT_CMDS
	cp $(ROMS_HOMEBREW_LUTRO_PONG_DL_DIR)/lutro-pong.lutro \
		$(ROMS_HOMEBREW_LUTRO_PONG_DL_DIR)/LICENSE.md $(@D)/
endef

define ROMS_HOMEBREW_LUTRO_PONG_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/lutro-pong.lutro \
		$(TARGET_DIR)/usr/share/roms-homebrew/lutro/Pong.lutro
endef

$(eval $(generic-package))
