################################################################################
#
# libadwaita
#
# The stylesheet is shipped as .scss and compiled at build time, so this needs
# host-sassc: 1.6's src/stylesheet has exactly one .css in it, empty.css. When
# sassc is missing, meson reaches for a wrap subproject, which Buildroot turns
# off, and configure stops with "Subproject sassc is buildable: NO".
#
################################################################################

LIBADWAITA_VERSION = 1.6.10
LIBADWAITA_SOURCE = libadwaita-$(LIBADWAITA_VERSION).tar.xz
LIBADWAITA_SITE = https://download.gnome.org/sources/libadwaita/1.6
LIBADWAITA_LICENSE = LGPL-2.1+
LIBADWAITA_LICENSE_FILES = COPYING
LIBADWAITA_INSTALL_STAGING = YES
LIBADWAITA_DEPENDENCIES = host-pkgconf host-sassc libgtk4 appstream

LIBADWAITA_CONF_OPTS = \
	-Dexamples=false \
	-Dtests=false \
	-Dvapi=false \
	-Dgtk_doc=false

# gnome-shell drives everything through GObject introspection typelibs, so
# build them whenever the config carries gobject-introspection.
ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LIBADWAITA_CONF_OPTS += -Dintrospection=enabled
LIBADWAITA_DEPENDENCIES += gobject-introspection
else
LIBADWAITA_CONF_OPTS += -Dintrospection=disabled
endif

$(eval $(meson-package))
