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
IBUS_DEPENDENCIES = host-pkgconf host-python3 libglib2 dconf

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
	--disable-emoji-dict \
	--disable-unicode-dict \
	--disable-python-library \
	--with-python=$(HOST_DIR)/bin/python3

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
IBUS_CONF_OPTS += --enable-introspection
IBUS_DEPENDENCIES += gobject-introspection
else
IBUS_CONF_OPTS += --disable-introspection
endif

$(eval $(autotools-package))
