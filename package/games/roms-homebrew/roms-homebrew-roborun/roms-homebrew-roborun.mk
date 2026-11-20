################################################################################
#
# roms-homebrew-roborun
#
################################################################################

ROMS_HOMEBREW_ROBORUN_VERSION = 1.1
ROMS_HOMEBREW_ROBORUN_SITE = https://github.com/heaven-hm/roborun-nes/releases/download/$(ROMS_HOMEBREW_ROBORUN_VERSION)
ROMS_HOMEBREW_ROBORUN_SOURCE = RoboRun-NES_$(ROMS_HOMEBREW_ROBORUN_VERSION).nes
ROMS_HOMEBREW_ROBORUN_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/heaven-hm/roborun-nes/$(ROMS_HOMEBREW_ROBORUN_VERSION)/LICENSE
# The license file is from the same tag.
ROMS_HOMEBREW_ROBORUN_LICENSE = GPL-3.0
ROMS_HOMEBREW_ROBORUN_LICENSE_FILES = LICENSE

define ROMS_HOMEBREW_ROBORUN_EXTRACT_CMDS
	cp $(ROMS_HOMEBREW_ROBORUN_DL_DIR)/RoboRun-NES_$(ROMS_HOMEBREW_ROBORUN_VERSION).nes $(ROMS_HOMEBREW_ROBORUN_DL_DIR)/LICENSE \
		$(@D)/
endef

define ROMS_HOMEBREW_ROBORUN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/RoboRun-NES_$(ROMS_HOMEBREW_ROBORUN_VERSION).nes \
		$(TARGET_DIR)/usr/share/roms-homebrew/nes/RoboRun.nes
endef

$(eval $(generic-package))
