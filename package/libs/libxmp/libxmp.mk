################################################################################
#
# libxmp
#
# Needed by sdl3_mixer for MOD playback. The release tarball ships a
# configure script, so this is the one satellite dependency here that is
# not built with CMake.
#
################################################################################

LIBXMP_VERSION = 4.7.2
LIBXMP_SOURCE = libxmp-$(LIBXMP_VERSION).tar.gz
LIBXMP_SITE = https://github.com/libxmp/libxmp/releases/download/libxmp-$(LIBXMP_VERSION)
LIBXMP_LICENSE = MIT
LIBXMP_LICENSE_FILES = docs/COPYING
LIBXMP_INSTALL_STAGING = YES
LIBXMP_DEPENDENCIES = host-pkgconf

$(eval $(autotools-package))
