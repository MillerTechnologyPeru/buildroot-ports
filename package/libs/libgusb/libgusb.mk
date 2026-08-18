################################################################################
#
# libgusb
#
################################################################################

LIBGUSB_VERSION = 0.4.9
LIBGUSB_SOURCE = libgusb-$(LIBGUSB_VERSION).tar.gz
LIBGUSB_SITE = $(call github,hughsie,libgusb,$(LIBGUSB_VERSION))
LIBGUSB_LICENSE = LGPL-2.1+
LIBGUSB_LICENSE_FILES = COPYING
LIBGUSB_INSTALL_STAGING = YES
LIBGUSB_DEPENDENCIES = host-pkgconf libusb json-glib

LIBGUSB_CONF_OPTS = -Dtests=false -Ddocs=false -Dvapi=false

# colord's Colorhug-1.0.gir includes GUsb-1.0.gir, so once colord builds its
# introspection - which it does whenever gobject-introspection is in the
# configuration - libgusb has to have built its own:
#
#   Couldn't find include 'GUsb-1.0.gir'
#
# Follow the same rule colord does rather than forcing it off here.
ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LIBGUSB_CONF_OPTS += -Dintrospection=true
LIBGUSB_DEPENDENCIES += gobject-introspection
else
LIBGUSB_CONF_OPTS += -Dintrospection=false
endif

$(eval $(meson-package))
