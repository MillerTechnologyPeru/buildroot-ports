################################################################################
#
# ibus
#
# The release *dist* tarball (not the tag archive): it carries the
# pregenerated unicode/emoji data and needs no autogen. GTK immodules and
# the standalone UI are off - on GNOME the shell is the UI; the daemon,
# libibus and the dconf backend are what matters.
#
################################################################################

IBUS_VERSION = 1.5.34
IBUS_SITE = https://github.com/ibus/ibus/releases/download/$(IBUS_VERSION)
IBUS_LICENSE = LGPL-2.1+
IBUS_LICENSE_FILES = COPYING
IBUS_INSTALL_STAGING = YES
# host-python3 for AM_PATH_PYTHON, which configure runs unconditionally and
# which rejects the /bin/false that --with-python used to name:
#
#   checking whether /bin/false version is >= 2.5... no
#   configure: error: Python interpreter is too old
#
# The only script python could run at build time is engine/gensimple.py,
# and its output simple.xml.in ships pre-generated in the tarball, so this
# is purely to get past the check. Nothing python reaches the target:
# --disable-python-library below keeps the bindings out.
#
# One thing configure derives from that interpreter has to be overridden.
# It auto-detects pygobject with no switch to turn it off, then asks the
# python it was given where the GI overrides live - and the host python
# answers with a host path, which ibus then installs the IBus.py override
# under, inside the staging tree:
#
#   ibus: installs files in <sysroot>//mnt/br/output/x86_64
#
# --with-python-overrides-dir exists for exactly this and takes a plain
# path; a target-relative one keeps the file inside the sysroot. It is a
# 300-line pure-python shim with no target python to load it, so where it
# lands does not matter, only that it lands somewhere sane.
IBUS_DEPENDENCIES = host-pkgconf host-python3 libglib2 dconf

# appindicator is the panel-icon integration for desktops that use
# libdbusmenu; it defaults on and requires dbusmenu-glib and dbusmenu-gtk3,
# neither of which is packaged:
#
#   configure: error: Package requirements (dbusmenu-glib-0.4) were not met
#
# GNOME shows input sources through gnome-shell's own indicator, not an
# appindicator, so nothing here wants it.
IBUS_CONF_OPTS = \
	--disable-gtk2 \
	--disable-gtk3 \
	--disable-gtk4 \
	--disable-xim \
	--disable-ui \
	--disable-setup \
	--disable-wayland \
	--disable-systemd-services \
	--disable-tests \
	--disable-appindicator \
	--disable-emoji-dict \
	--disable-unicode-dict \
	--disable-python-library \
	--with-python=$(HOST_DIR)/bin/python3 \
	--with-python-overrides-dir=/usr/lib/python3/dist-packages/gi/overrides

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
IBUS_CONF_OPTS += --enable-introspection
IBUS_DEPENDENCIES += gobject-introspection
else
IBUS_CONF_OPTS += --disable-introspection
endif

# tools/main.c ships pre-generated from main.vala, and it was generated with
# IBUS_WAYLAND defined - so it calls wl_display_connect() and friends
# unconditionally, whatever --disable-wayland says, and the link fails for
# want of libwayland-client:
#
#   main.c:(.text+0x1757): undefined reference to `wl_display_connect'
#
# The .vala guards that code with #if IBUS_WAYLAND, and valac is in the host
# tree, but automake only regenerates when the .vala is newer than the .c,
# and the tarball's timestamps say it is not. Drop the shipped C and the
# vala stamp so valac runs and the flags actually apply. Only tools/ needs
# this: ui/gtk3 is behind --disable-ui and engine/ has no wayland code.
define IBUS_REGENERATE_TOOLS_VALA
	rm -f $(@D)/tools/main.c $(@D)/tools/krcfile.c $(@D)/tools/ibus_vala.stamp
endef
IBUS_POST_PATCH_HOOKS += IBUS_REGENERATE_TOOLS_VALA

$(eval $(autotools-package))
