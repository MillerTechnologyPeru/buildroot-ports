################################################################################
#
# roms-homebrew-gothicvania
#
################################################################################

ROMS_HOMEBREW_GOTHICVANIA_VERSION = v1.0.0
ROMS_HOMEBREW_GOTHICVANIA_SITE = https://github.com/donth77/snes-homebrew/releases/download/$(ROMS_HOMEBREW_GOTHICVANIA_VERSION)
ROMS_HOMEBREW_GOTHICVANIA_SOURCE = gothicvania.sfc
ROMS_HOMEBREW_GOTHICVANIA_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/donth77/snes-homebrew/119496e6a2f1e53b7704712fef8cb81814f1698a/LICENSE \
	https://raw.githubusercontent.com/donth77/snes-homebrew/119496e6a2f1e53b7704712fef8cb81814f1698a/README.md
# The graphics are ansimuz's GothicVania Cemetery set, CC0, as the README's
# credits state. The tag predates the license file, so both come from the
# commit that added it.
ROMS_HOMEBREW_GOTHICVANIA_LICENSE = MIT (code, music), CC0-1.0 (graphics)
ROMS_HOMEBREW_GOTHICVANIA_LICENSE_FILES = LICENSE README.md

define ROMS_HOMEBREW_GOTHICVANIA_EXTRACT_CMDS
	cp $(ROMS_HOMEBREW_GOTHICVANIA_DL_DIR)/gothicvania.sfc $(ROMS_HOMEBREW_GOTHICVANIA_DL_DIR)/LICENSE $(ROMS_HOMEBREW_GOTHICVANIA_DL_DIR)/README.md \
		$(@D)/
endef

define ROMS_HOMEBREW_GOTHICVANIA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/gothicvania.sfc \
		$(TARGET_DIR)/usr/share/roms-homebrew/snes/Gothicvania.sfc
endef

$(eval $(generic-package))
