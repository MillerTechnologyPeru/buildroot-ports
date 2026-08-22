################################################################################
#
# gnome-backgrounds
#
# The wallpapers gsettings-desktop-schemas already points at. Its compiled
# schema names them by absolute path,
#
#   file:///usr/share/backgrounds/gnome/adwaita-timed.xml
#   file:///usr/share/backgrounds/gnome/adwaita-d.jpg
#   file:///usr/share/backgrounds/gnome/adwaita-l.jpg
#
# and without the files the shell has nothing to draw and falls back to a flat
# colour. Nothing fails and nothing is logged; the desktop just comes up plain.
#
# Data only - no compilation - but it is 38 MB of it, which is most of what
# this package costs.
#
################################################################################

GNOME_BACKGROUNDS_VERSION = 48.0
GNOME_BACKGROUNDS_SOURCE = gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION).tar.xz
GNOME_BACKGROUNDS_SITE = https://download.gnome.org/sources/gnome-backgrounds/48
GNOME_BACKGROUNDS_LICENSE = CC-BY-SA-3.0, CC-BY-2.0, GPL-2.0+
GNOME_BACKGROUNDS_LICENSE_FILES = COPYING
GNOME_BACKGROUNDS_DEPENDENCIES = host-pkgconf

$(eval $(meson-package))
