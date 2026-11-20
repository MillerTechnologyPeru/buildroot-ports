################################################################################
#
# roms-homebrew-ucity
#
################################################################################

ROMS_HOMEBREW_UCITY_VERSION = v1.3
ROMS_HOMEBREW_UCITY_SITE = https://github.com/AntonioND/ucity/releases/download/$(ROMS_HOMEBREW_UCITY_VERSION)
ROMS_HOMEBREW_UCITY_SOURCE = ucity.gbc
ROMS_HOMEBREW_UCITY_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/AntonioND/ucity/$(ROMS_HOMEBREW_UCITY_VERSION)/readme.rst \
	https://raw.githubusercontent.com/AntonioND/ucity/$(ROMS_HOMEBREW_UCITY_VERSION)/gpl-3.0.txt
# Its readme states the licensing; the GPL text is from the same tag.
ROMS_HOMEBREW_UCITY_LICENSE = GPL-3.0+ (code), CC-BY-SA-4.0 (graphics, music)
ROMS_HOMEBREW_UCITY_LICENSE_FILES = readme.rst gpl-3.0.txt

define ROMS_HOMEBREW_UCITY_EXTRACT_CMDS
	cp $(ROMS_HOMEBREW_UCITY_DL_DIR)/ucity.gbc $(ROMS_HOMEBREW_UCITY_DL_DIR)/readme.rst $(ROMS_HOMEBREW_UCITY_DL_DIR)/gpl-3.0.txt \
		$(@D)/
endef

define ROMS_HOMEBREW_UCITY_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/ucity.gbc \
		$(TARGET_DIR)/usr/share/roms-homebrew/gbc/uCity.gbc
endef

$(eval $(generic-package))
