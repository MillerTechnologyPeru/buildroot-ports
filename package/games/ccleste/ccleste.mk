################################################################################
#
# ccleste
#
# A plain Makefile, no configure. sdl12main.c is the SDL frontend and
# celeste.c the translated game logic; the default target links the two into
# a single "ccleste" binary. The build takes its SDL cflags from
# sdl2-config, so it is pointed at the fixed-up script in staging.
#
# CFLAGS and LDFLAGS are assigned unconditionally in the Makefile and have
# the SDL library list and -lm appended afterwards, so setting either from
# the command line would drop those - EXTRA_CFLAGS/EXTRA_LDFLAGS (added by
# the patch) are the way in for the target flags.
#
# The assets and gamecontrollerdb.txt were read from a path relative to the
# working directory, so the game only ran from its own source directory.
# The patch turns that into DATADIR, set here to where the data is
# installed.
#
################################################################################

CCLESTE_VERSION = v1.4.0
CCLESTE_SITE = $(call github,lemon32767,ccleste,$(CCLESTE_VERSION))

# Upstream ships no license file and states no terms anywhere in the tree or
# in its GitHub metadata; the code is a hand translation of a cart whose own
# rights stay with the original authors. Flagged rather than guessed.
CCLESTE_LICENSE = unknown

CCLESTE_DEPENDENCIES = sdl2 sdl2_mixer

CCLESTE_DATA_DIR = /usr/share/ccleste/data

define CCLESTE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" \
		SDL_CONFIG="$(STAGING_DIR)/usr/bin/sdl2-config" \
		DATADIR="$(CCLESTE_DATA_DIR)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)"
endef

define CCLESTE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/ccleste $(TARGET_DIR)/usr/bin/ccleste
	$(INSTALL) -d $(TARGET_DIR)$(CCLESTE_DATA_DIR)
	$(INSTALL) -m 0644 $(@D)/data/* $(TARGET_DIR)$(CCLESTE_DATA_DIR)
	$(INSTALL) -D -m 0644 $(@D)/gamecontrollerdb.txt \
		$(TARGET_DIR)$(CCLESTE_DATA_DIR)/gamecontrollerdb.txt
endef

$(eval $(generic-package))
