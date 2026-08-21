################################################################################
#
# dconf
#
################################################################################

DCONF_VERSION = 0.40.0
DCONF_SOURCE = dconf-$(DCONF_VERSION).tar.xz
DCONF_SITE = https://download.gnome.org/sources/dconf/0.40
DCONF_LICENSE = LGPL-2.1+
DCONF_LICENSE_FILES = COPYING
DCONF_INSTALL_STAGING = YES
DCONF_DEPENDENCIES = host-pkgconf libglib2

DCONF_CONF_OPTS = \
	-Dbash_completion=false \
	-Dman=false \
	-Dvapi=false

# The host build is for its "dconf compile" command, which other packages
# need at build time to turn a directory of settings into a dconf database -
# gdm's data/dconf/meson.build calls find_program('dconf') for exactly that,
# unconditionally, and stops the configure without it:
#
#   data/dconf/meson.build:18:4: ERROR: Program 'dconf' not found or not
#     executable
HOST_DCONF_DEPENDENCIES = host-pkgconf host-libglib2

HOST_DCONF_CONF_OPTS = \
	-Dbash_completion=false \
	-Dman=false \
	-Dvapi=false

$(eval $(meson-package))
$(eval $(host-meson-package))
