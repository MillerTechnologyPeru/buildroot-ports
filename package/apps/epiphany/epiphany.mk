################################################################################
#
# epiphany
#
################################################################################

EPIPHANY_VERSION = 47.7
EPIPHANY_SOURCE = epiphany-$(EPIPHANY_VERSION).tar.xz
EPIPHANY_SITE = https://download.gnome.org/sources/epiphany/47
EPIPHANY_LICENSE = GPL-3.0+
EPIPHANY_LICENSE_FILES = COPYING
EPIPHANY_DEPENDENCIES = host-pkgconf host-desktop-file-utils libgtk4 libadwaita webkitgtk json-glib libsoup3 gcr4 libportal iso-codes gsettings-desktop-schemas nettle libarchive sqlite

# yelp is not in this image, so the translated help would be installed with
# nothing able to display it - and building it needs a host itstool, which
# Buildroot does not carry.
EPIPHANY_CONF_OPTS = -Dunit_tests=disabled -Ddeveloper_mode=false -Dhelp=false

$(eval $(meson-package))
