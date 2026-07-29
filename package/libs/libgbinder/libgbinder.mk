################################################################################
#
# libgbinder
#
# Same hand-written Makefile framework as libglibutil, driven the same way.
# The test/ subdirectory holds the binder-client/-dump/-service/-watch
# helpers; they are diagnostic tools rather than anything waydroid calls,
# so they are left unbuilt.
#
################################################################################

LIBGBINDER_VERSION = 1.1.52
LIBGBINDER_SITE = $(call github,mer-hybris,libgbinder,$(LIBGBINDER_VERSION))
LIBGBINDER_LICENSE = BSD-3-Clause
LIBGBINDER_LICENSE_FILES = LICENSE
LIBGBINDER_INSTALL_STAGING = YES
LIBGBINDER_DEPENDENCIES = host-pkgconf libglib2 libglibutil

define LIBGBINDER_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) KEEP_SYMBOLS=1 release pkgconfig
endef

define LIBGBINDER_INSTALL_STAGING_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) KEEP_SYMBOLS=1 \
		DESTDIR=$(STAGING_DIR) install-dev
endef

define LIBGBINDER_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) KEEP_SYMBOLS=1 \
		DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
