################################################################################
#
# gnome-disk-utility
#
################################################################################

GNOME_DISK_UTILITY_VERSION = 46.1
GNOME_DISK_UTILITY_SOURCE = gnome-disk-utility-$(GNOME_DISK_UTILITY_VERSION).tar.xz
GNOME_DISK_UTILITY_SITE = https://download.gnome.org/sources/gnome-disk-utility/46
GNOME_DISK_UTILITY_LICENSE = GPL-2.0+
GNOME_DISK_UTILITY_LICENSE_FILES = COPYING
# Disks 46 is a GTK 3 application on libhandy, not GTK 4 on libadwaita -
# meson.build asks for gtk+-3.0, libhandy-1, libcanberra-gtk3 and
# libnotify. The dependencies here named the wrong toolkit, and libhandy
# was not packaged at all, so configure fell back to a wrap:
#
#   ERROR: Subproject libhandy is buildable: NO
#
# The GTK 4 port is 51, still in beta as of writing.
GNOME_DISK_UTILITY_DEPENDENCIES = host-pkgconf host-desktop-file-utils libgtk3 libhandy libcanberra libnotify udisks2 libpwquality libsecret libdvdread xz elogind

# logind is a combo - libsystemd, libelogind or none - defaulting to
# libsystemd:
#
#   meson.build:90:15: ERROR: Dependency "libsystemd" not found
#
# The image runs elogind, whose libelogind carries the same sd-login API.
GNOME_DISK_UTILITY_CONF_OPTS = -Dman=false -Dlogind=libelogind

$(eval $(meson-package))
