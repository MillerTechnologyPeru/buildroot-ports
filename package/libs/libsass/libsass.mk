################################################################################
#
# libsass
#
# Host only: it exists here for host-sassc, which libadwaita and the other
# GNOME stylesheet consumers run at build time to compile their .scss. Nothing
# on the target links against it.
#
################################################################################

LIBSASS_VERSION = 3.6.6
LIBSASS_SITE = $(call github,sass,libsass,$(LIBSASS_VERSION))
LIBSASS_LICENSE = MIT
LIBSASS_LICENSE_FILES = LICENSE

# The GitHub archive carries configure.ac but no configure.
HOST_LIBSASS_AUTORECONF = YES
HOST_LIBSASS_DEPENDENCIES = host-pkgconf

# AC_INIT takes the version from m4_esyscmd_s([./version.sh]), and that script
# asks git, then a VERSION file, then gives up and answers "[na]" - which is
# what a release archive gets, since it has neither. Write the file the script
# looks for; the version is already known here.
define HOST_LIBSASS_WRITE_VERSION
	echo "$(LIBSASS_VERSION)" > $(@D)/VERSION
endef
HOST_LIBSASS_POST_EXTRACT_HOOKS += HOST_LIBSASS_WRITE_VERSION

$(eval $(host-autotools-package))
