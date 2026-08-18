################################################################################
#
# tecla
#
################################################################################

TECLA_VERSION = 47.0
TECLA_SOURCE = tecla-$(TECLA_VERSION).tar.xz
TECLA_SITE = https://download.gnome.org/sources/tecla/47
TECLA_LICENSE = GPL-2.0+
TECLA_LICENSE_FILES = LICENSE
TECLA_INSTALL_STAGING = YES
TECLA_DEPENDENCIES = host-pkgconf libgtk4 libadwaita libxkbcommon

$(eval $(meson-package))
