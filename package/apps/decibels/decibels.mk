################################################################################
#
# decibels
#
################################################################################

DECIBELS_VERSION = 48.0
DECIBELS_SOURCE = decibels-$(DECIBELS_VERSION).tar.xz
DECIBELS_SITE = https://download.gnome.org/sources/decibels/48
DECIBELS_LICENSE = GPL-3.0+
DECIBELS_LICENSE_FILES = COPYING
# host-desktop-file-utils for gnome.post_install(update_desktop_database: true),
# which resolves update-desktop-database when meson configures. Several other
# apps here already depend on it, so the tool does get built - but decibels
# configures before any of them, and a dependency that is only satisfied by
# build order is not one.
DECIBELS_DEPENDENCIES = host-pkgconf host-typescript host-blueprint-compiler host-desktop-file-utils libgtk4 libadwaita gjs gst1-plugins-base gst1-plugins-good

DECIBELS_CONF_OPTS = 

$(eval $(meson-package))
