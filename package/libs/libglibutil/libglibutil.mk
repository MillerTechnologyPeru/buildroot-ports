################################################################################
#
# libglibutil
#
# Hand-written Makefile, no configure. It builds separate debug and release
# trees and "all" builds both, so only the release target is asked for. The
# pkgconfig target generates the .pc, which install-dev then copies.
#
# KEEP_SYMBOLS=1 leaves the strip to Buildroot, which strips the target
# copy itself and keeps the staging copy debuggable. CC, CFLAGS, LDFLAGS
# and PKG_CONFIG all come in from TARGET_CONFIGURE_OPTS: the Makefile takes
# CC with ?= and folds $(CFLAGS)/$(LDFLAGS) into its own flags, so the
# cross toolchain and target flags are picked up as-is.
#
################################################################################

LIBGLIBUTIL_VERSION = 1.0.82
LIBGLIBUTIL_SITE = $(call github,sailfishos,libglibutil,$(LIBGLIBUTIL_VERSION))
LIBGLIBUTIL_LICENSE = BSD-3-Clause
LIBGLIBUTIL_LICENSE_FILES = LICENSE
LIBGLIBUTIL_INSTALL_STAGING = YES
LIBGLIBUTIL_DEPENDENCIES = host-pkgconf libglib2

define LIBGLIBUTIL_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) KEEP_SYMBOLS=1 release pkgconfig
endef

# install-dev is the headers and .pc on top of install; the target only
# needs the shared library itself.
define LIBGLIBUTIL_INSTALL_STAGING_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) KEEP_SYMBOLS=1 \
		DESTDIR=$(STAGING_DIR) install-dev
endef

define LIBGLIBUTIL_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) KEEP_SYMBOLS=1 \
		DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
