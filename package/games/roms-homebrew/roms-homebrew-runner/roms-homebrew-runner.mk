################################################################################
#
# roms-homebrew-runner
#
################################################################################

ROMS_HOMEBREW_RUNNER_VERSION = v1
ROMS_HOMEBREW_RUNNER_SITE = https://github.com/zorchenhimer/nes-runner/releases/download/$(ROMS_HOMEBREW_RUNNER_VERSION)
ROMS_HOMEBREW_RUNNER_SOURCE = runner.nes
ROMS_HOMEBREW_RUNNER_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/zorchenhimer/nes-runner/e6b5fe2e40ae46385ceccbc5bc1606cbd8bc02f2/LICENSE.md
# The release tag predates the license file, so it comes from the commit that added it.
ROMS_HOMEBREW_RUNNER_LICENSE = MIT
ROMS_HOMEBREW_RUNNER_LICENSE_FILES = LICENSE.md

define ROMS_HOMEBREW_RUNNER_EXTRACT_CMDS
	cp $(ROMS_HOMEBREW_RUNNER_DL_DIR)/runner.nes $(ROMS_HOMEBREW_RUNNER_DL_DIR)/LICENSE.md \
		$(@D)/
endef

define ROMS_HOMEBREW_RUNNER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/runner.nes \
		$(TARGET_DIR)/usr/share/roms-homebrew/nes/Runner.nes
endef

$(eval $(generic-package))
