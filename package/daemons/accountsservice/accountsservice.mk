################################################################################
#
# accountsservice
#
################################################################################

ACCOUNTSSERVICE_VERSION = 23.13.9
ACCOUNTSSERVICE_SOURCE = accountsservice-$(ACCOUNTSSERVICE_VERSION).tar.xz
ACCOUNTSSERVICE_SITE = https://www.freedesktop.org/software/accountsservice
ACCOUNTSSERVICE_LICENSE = GPL-3.0+
ACCOUNTSSERVICE_LICENSE_FILES = COPYING
ACCOUNTSSERVICE_INSTALL_STAGING = YES
ACCOUNTSSERVICE_DEPENDENCIES = host-pkgconf polkit dbus elogind

# systemdsystemunitdir=no is what turns the unit install off. Left empty - the
# default - meson looks the directory up from systemd's pkg-config file and
# asserts when there is none:
#
#   meson.build:185:2: ERROR: Assert failed: systemd required but not found,
#   please provide a valid systemd user unit dir or disable it
#
# This image runs elogind under OpenRC, which is what -Delogind=true below
# selects, so there is no unit to install anywhere.
ACCOUNTSSERVICE_CONF_OPTS = \
	-Delogind=true \
	-Dsystemdsystemunitdir=no \
	-Dadmin_group=wheel \
	-Ddocbook=false \
	-Dgtk_doc=false \
	-Dvapi=false

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
ACCOUNTSSERVICE_CONF_OPTS += -Dintrospection=true
ACCOUNTSSERVICE_DEPENDENCIES += gobject-introspection
else
ACCOUNTSSERVICE_CONF_OPTS += -Dintrospection=false
endif

$(eval $(meson-package))
