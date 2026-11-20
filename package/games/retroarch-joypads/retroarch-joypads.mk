################################################################################
#
# retroarch-joypads
#
# RetroArch controller profiles ("autoconfig"): the button layout of each
# known gamepad, matched by device name when it is plugged in, so a game
# is playable without mapping anything first.
#
# The same set upstream ships: libretro's profile collection, pinned at
# upstream's commit (same tarball hash), flattened into one directory -
# the udev profiles are the ones the udev joypad driver matches - with
# upstream's own handheld profiles in gamepads/ laid over it. Those are
# kept byte-identical to upstream's
# projects/ROCKNIX/packages/emulators/libretro/retroarch/retroarch-joypads/gamepads/
# (synced at 2af82cb), so a resync is a straight copy.
#
# The handheld profiles also carry upstream's hotkeys, Select being the
# hotkey button:
#
#   Select+Start  quit the game        Select+L1  load state
#   Select+X      RetroArch menu       Select+R1  save state
#   Select+Y      show FPS             Select+L2  rewind
#                                      Select+R2  fast-forward
#
################################################################################

RETROARCH_JOYPADS_VERSION = 38cf938bba0adbde375972053068f10d955a9d14
RETROARCH_JOYPADS_SITE = $(call github,libretro,retroarch-joypad-autoconfig,$(RETROARCH_JOYPADS_VERSION))
RETROARCH_JOYPADS_LICENSE = MIT (profile collection), GPL-2.0 (handheld profiles)
RETROARCH_JOYPADS_LICENSE_FILES = COPYING

RETROARCH_JOYPADS_AUTOCONFIG_DIR = $(TARGET_DIR)/usr/share/libretro/autoconfig

# cp -n: where two driver directories carry a profile of the same name,
# the first one copied wins. Upstream copies linuxraw first; udev goes
# first here, because a profile only matches under the joypad driver it
# names, and RetroArch's driver on this image is udev (see retroarch.mk).
define RETROARCH_JOYPADS_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(RETROARCH_JOYPADS_AUTOCONFIG_DIR)
	for d in udev linuxraw sdl2 x xinput; do \
		cp -n $(@D)/$$d/*.cfg $(RETROARCH_JOYPADS_AUTOCONFIG_DIR)/ || exit 1; \
	done
	cp -f $(RETROARCH_JOYPADS_PKGDIR)/gamepads/*.cfg $(RETROARCH_JOYPADS_AUTOCONFIG_DIR)/
	chmod 0644 $(RETROARCH_JOYPADS_AUTOCONFIG_DIR)/*.cfg
endef

$(eval $(generic-package))
