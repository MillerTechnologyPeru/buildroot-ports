################################################################################
#
# libhandy
#
################################################################################

LIBHANDY_VERSION_MAJOR = 1.8
LIBHANDY_VERSION = $(LIBHANDY_VERSION_MAJOR).3
LIBHANDY_SOURCE = libhandy-$(LIBHANDY_VERSION).tar.xz
LIBHANDY_SITE = https://download.gnome.org/sources/libhandy/$(LIBHANDY_VERSION_MAJOR)
LIBHANDY_LICENSE = LGPL-2.1+
LIBHANDY_LICENSE_FILES = COPYING
LIBHANDY_INSTALL_STAGING = YES
LIBHANDY_DEPENDENCIES = host-pkgconf libgtk3 libfribidi

# introspection is a feature (enabled/disabled), vapi a boolean.
LIBHANDY_CONF_OPTS = \
	-Dvapi=false \
	-Dgtk_doc=false \
	-Dtests=false \
	-Dexamples=false \
	-Dglade_catalog=disabled

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LIBHANDY_CONF_OPTS += -Dintrospection=enabled
LIBHANDY_DEPENDENCIES += gobject-introspection
else
LIBHANDY_CONF_OPTS += -Dintrospection=disabled
endif

$(eval $(meson-package))
