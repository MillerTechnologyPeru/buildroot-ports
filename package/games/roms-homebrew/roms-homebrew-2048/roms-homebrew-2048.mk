################################################################################
#
# roms-homebrew-2048
#
################################################################################

ROMS_HOMEBREW_2048_VERSION = v1.1
ROMS_HOMEBREW_2048_SITE = https://github.com/wyattferguson/2048-gb/releases/download/$(ROMS_HOMEBREW_2048_VERSION)
ROMS_HOMEBREW_2048_SOURCE = 2048.gb
ROMS_HOMEBREW_2048_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/wyattferguson/2048-gb/167788105db659f2049dd2d537ee12f63d87b1e7/LICENSE
# The tag predates the license file, so it comes from the commit that added it.
ROMS_HOMEBREW_2048_LICENSE = MIT
ROMS_HOMEBREW_2048_LICENSE_FILES = LICENSE

define ROMS_HOMEBREW_2048_EXTRACT_CMDS
	cp $(ROMS_HOMEBREW_2048_DL_DIR)/2048.gb $(ROMS_HOMEBREW_2048_DL_DIR)/LICENSE \
		$(@D)/
endef

define ROMS_HOMEBREW_2048_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/2048.gb \
		$(TARGET_DIR)/usr/share/roms-homebrew/gbc/2048.gb
endef

$(eval $(generic-package))
