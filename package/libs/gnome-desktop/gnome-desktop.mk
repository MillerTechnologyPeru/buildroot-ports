################################################################################
#
# gnome-desktop
#
################################################################################

GNOME_DESKTOP_VERSION = 44.5
GNOME_DESKTOP_SOURCE = gnome-desktop-$(GNOME_DESKTOP_VERSION).tar.xz
GNOME_DESKTOP_SITE = https://download.gnome.org/sources/gnome-desktop/44
GNOME_DESKTOP_LICENSE = GPL-2.0+, LGPL-2.1+ (libraries)
GNOME_DESKTOP_LICENSE_FILES = COPYING COPYING.LIB
GNOME_DESKTOP_INSTALL_STAGING = YES
GNOME_DESKTOP_DEPENDENCIES = host-pkgconf libgtk4 gdk-pixbuf gsettings-desktop-schemas iso-codes libseccomp xkeyboard-config

GNOME_DESKTOP_CONF_OPTS = -Dgtk_doc=false -Ddesktop_docs=false -Dinstalled_tests=false -Dbuild_gtk4=true -Ddebug_tools=false -Dudev=enabled

# The legacy libgnome-desktop-3.0 is the GTK 3 half of the library, and
# gnome-settings-daemon 47 still asks for it - alongside gtk+-3.0 - with no
# way to opt out:
#
#   meson.build:104:20: ERROR: Dependency "gnome-desktop-3.0" not found
#
# so on a configuration with GTK 3 it has to be built, and on one without
# it cannot be. Follow BR2_PACKAGE_LIBGTK3.
ifeq ($(BR2_PACKAGE_LIBGTK3),y)
GNOME_DESKTOP_CONF_OPTS += -Dlegacy_library=true
GNOME_DESKTOP_DEPENDENCIES += libgtk3
else
GNOME_DESKTOP_CONF_OPTS += -Dlegacy_library=false
endif

# gnome-shell drives everything through GObject introspection typelibs, so
# build them whenever the config carries gobject-introspection.
ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
GNOME_DESKTOP_CONF_OPTS += -Dintrospection=true
GNOME_DESKTOP_DEPENDENCIES += gobject-introspection
else
GNOME_DESKTOP_CONF_OPTS += -Dintrospection=false
endif

$(eval $(meson-package))
