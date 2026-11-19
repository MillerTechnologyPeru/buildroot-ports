################################################################################
#
# roms-homebrew
#
# Freely licensed homebrew ROMs, fetched from each game's own published
# release. Installed to /usr/share/roms-homebrew/<system>/, which the data
# partition's first-boot setup (S15data) copies into /data/roms/<system>/.
#
################################################################################

ROMS_HOMEBREW_VERSION = 1
# Every file is an extra download; there is no single source archive.
ROMS_HOMEBREW_SOURCE =

# uCity (Game Boy Color), the v1.3 release ROM. Its readme states the
# licensing (GPLv3+ code, CC BY-SA 4.0 media); the GPL text comes from the
# same tag.
ROMS_HOMEBREW_UCITY_VERSION = v1.3
ROMS_HOMEBREW_EXTRA_DOWNLOADS += \
	https://github.com/AntonioND/ucity/releases/download/$(ROMS_HOMEBREW_UCITY_VERSION)/ucity.gbc \
	https://raw.githubusercontent.com/AntonioND/ucity/$(ROMS_HOMEBREW_UCITY_VERSION)/readme.rst \
	https://raw.githubusercontent.com/AntonioND/ucity/$(ROMS_HOMEBREW_UCITY_VERSION)/gpl-3.0.txt

ROMS_HOMEBREW_LICENSE = GPL-3.0+ (uCity code), CC-BY-SA-4.0 (uCity media)
ROMS_HOMEBREW_LICENSE_FILES = ucity/readme.rst ucity/gpl-3.0.txt

define ROMS_HOMEBREW_EXTRACT_CMDS
	$(INSTALL) -d $(@D)/ucity
	cp $(ROMS_HOMEBREW_DL_DIR)/ucity.gbc $(ROMS_HOMEBREW_DL_DIR)/readme.rst \
		$(ROMS_HOMEBREW_DL_DIR)/gpl-3.0.txt $(@D)/ucity/
endef

# The file name is what the frontend lists, so give it the game's name.
define ROMS_HOMEBREW_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/ucity/ucity.gbc \
		$(TARGET_DIR)/usr/share/roms-homebrew/gbc/uCity.gbc
endef

$(eval $(generic-package))
