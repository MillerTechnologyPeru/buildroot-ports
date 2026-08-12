################################################################################
#
# sassc
#
# Host only: the Sass compiler that libadwaita runs over its .scss sources at
# build time. libadwaita 1.6 ships the stylesheet as .scss only - the single
# .css in src/stylesheet is empty.css - and falls back to a meson wrap
# subproject when it cannot find sassc, which Buildroot disables.
#
################################################################################

SASSC_VERSION = 3.6.2
SASSC_SITE = $(call github,sass,sassc,$(SASSC_VERSION))
SASSC_LICENSE = MIT
SASSC_LICENSE_FILES = LICENSE

# The GitHub archive carries configure.ac but no configure.
HOST_SASSC_AUTORECONF = YES
HOST_SASSC_DEPENDENCIES = host-pkgconf host-libsass

# Same missing-VERSION problem as host-libsass; see that package.
define HOST_SASSC_WRITE_VERSION
	echo "$(SASSC_VERSION)" > $(@D)/VERSION
endef
HOST_SASSC_POST_EXTRACT_HOOKS += HOST_SASSC_WRITE_VERSION

$(eval $(host-autotools-package))
