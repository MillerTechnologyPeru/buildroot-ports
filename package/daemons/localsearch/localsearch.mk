################################################################################
#
# localsearch
#
################################################################################

LOCALSEARCH_VERSION = 3.8.2
LOCALSEARCH_SOURCE = localsearch-$(LOCALSEARCH_VERSION).tar.xz
LOCALSEARCH_SITE = https://download.gnome.org/sources/localsearch/3.8
LOCALSEARCH_LICENSE = GPL-2.0+
LOCALSEARCH_LICENSE_FILES = COPYING
LOCALSEARCH_INSTALL_STAGING = YES
# dbus-1, gudev-1.0, gobject-introspection-1.0 and the icu pair are plain
# dependency() calls with no option behind them, so meson stops at the first
# one missing regardless of what is switched off here. Every one of them does
# get built by something else in this frontend - dbus by half the session,
# libgudev by colord and udisks2, icu by tinysparql - but a dependency that
# only holds because of build order is not one.
LOCALSEARCH_DEPENDENCIES = host-pkgconf tinysparql dbus libgudev icu \
	gobject-introspection libseccomp

# functional_tests and sandbox_tests both default on and build test-only
# modules - a mock volume monitor, extractor stubs - that nothing installs.
# The suite runs the built binaries against a private session bus, which a
# cross build cannot do at all.
LOCALSEARCH_CONF_OPTS = -Dman=false -Dbattery_detection=none \
	-Dfunctional_tests=false -Dsandbox_tests=false

# The raw-image extractor; gexiv2 is optional (the option is a feature that
# defaults to auto) so follow the config rather than force it. nautilus
# already selects gexiv2, which is why this built before it was declared.
ifeq ($(BR2_PACKAGE_GEXIV2),y)
LOCALSEARCH_CONF_OPTS += -Draw=enabled
LOCALSEARCH_DEPENDENCIES += gexiv2
else
LOCALSEARCH_CONF_OPTS += -Draw=disabled
endif

$(eval $(meson-package))
