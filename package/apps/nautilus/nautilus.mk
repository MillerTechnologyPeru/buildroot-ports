################################################################################
#
# nautilus
#
################################################################################

NAUTILUS_VERSION = 47.6
NAUTILUS_SOURCE = nautilus-$(NAUTILUS_VERSION).tar.xz
NAUTILUS_SITE = https://download.gnome.org/sources/nautilus/47
NAUTILUS_LICENSE = GPL-3.0+
NAUTILUS_LICENSE_FILES = COPYING
NAUTILUS_DEPENDENCIES = host-pkgconf host-desktop-file-utils libgtk4 libadwaita gnome-autoar gexiv2 tinysparql gnome-desktop gsettings-desktop-schemas

# cloudproviders is the sidebar's cloud-account integration - Nextcloud,
# Dropbox and the like announcing themselves over D-Bus. It defaults on and
# wants libcloudproviders:
#
#   meson.build:132:19: ERROR: Dependency "cloudproviders" not found
#
# No such provider is in the image, so there is nothing for it to show.
NAUTILUS_CONF_OPTS = -Ddocs=false -Dtests=none -Dextensions=false -Dselinux=false -Dpackagekit=false -Dcloudproviders=false

$(eval $(meson-package))
