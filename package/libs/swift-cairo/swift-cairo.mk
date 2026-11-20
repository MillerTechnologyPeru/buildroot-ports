################################################################################
#
# swift-cairo
#
################################################################################

# Upstream has no releases; this is master.
SWIFT_CAIRO_VERSION = af9fa9d203b0598d9a4697a05ba868bf87424d32
SWIFT_CAIRO_SITE = $(call github,PureSwift,Cairo,$(SWIFT_CAIRO_VERSION))
SWIFT_CAIRO_LICENSE = MIT
SWIFT_CAIRO_LICENSE_FILES = LICENSE
SWIFT_CAIRO_INSTALL_STAGING = YES
SWIFT_CAIRO_DEPENDENCIES = swift swift-foundation swift-fontconfig cairo freetype

SWIFT_CAIRO_BUILDDIR = $(@D)/build

SWIFT_CAIRO_LIBDIR = usr/lib/swift/$(SWIFT_LIB_SUBDIR)
SWIFT_CAIRO_MODULEDIR = $(SWIFT_CAIRO_LIBDIR)/$(SWIFT_TARGET_ARCH)

# cairo's headers and FreeType's, which the C modules include by name.
SWIFT_CAIRO_INCLUDES = \
	-Xcc -I$(STAGING_DIR)/usr/include/cairo \
	-Xcc -I$(STAGING_DIR)/usr/include/freetype2

# Compiled directly into a shared library, like swift-fontconfig (see there
# for why). It is built without library evolution: the sources do not
# compile with it.
#
# The C modules (CCairo, CFreeType) are found in the source tree here;
# remove copies staged by an earlier build first, or the compiler sees them
# defined twice. FontConfig and CFontConfig come from staging.
#
# -no-toolchain-stdlib-rpath: the driver would otherwise give the library a
# run path to the staging tree's Swift libraries. On the target they are in
# /usr/lib, which the loader searches anyway.
define SWIFT_CAIRO_BUILD_CMDS
	rm -rf $(STAGING_DIR)/usr/lib/swift/CCairo \
		$(STAGING_DIR)/usr/lib/swift/CFreeType
	mkdir -p $(SWIFT_CAIRO_BUILDDIR)
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_NATIVE_PATH)/swiftc $(call qstrip,$(SWIFTC_FLAGS)) \
		-no-toolchain-stdlib-rpath \
		-emit-library -emit-module -parse-as-library -swift-version 6 \
		$(if $(BR2_ENABLE_RUNTIME_DEBUG),-Onone -g,-O) \
		-module-name Cairo -module-link-name Cairo \
		-emit-module-path $(SWIFT_CAIRO_BUILDDIR)/Cairo.swiftmodule \
		-o $(SWIFT_CAIRO_BUILDDIR)/libCairo.so \
		-I $(@D)/Sources \
		$(SWIFT_CAIRO_INCLUDES) \
		$(@D)/Sources/Cairo/*.swift
endef

define SWIFT_CAIRO_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(SWIFT_CAIRO_BUILDDIR)/libCairo.so \
		$(STAGING_DIR)/$(SWIFT_CAIRO_LIBDIR)/libCairo.so
	$(INSTALL) -D -m 0644 $(SWIFT_CAIRO_BUILDDIR)/Cairo.swiftmodule \
		$(STAGING_DIR)/$(SWIFT_CAIRO_MODULEDIR)/Cairo.swiftmodule
	$(INSTALL) -D -m 0644 -t $(STAGING_DIR)/usr/lib/swift/CCairo \
		$(@D)/Sources/CCairo/module.modulemap \
		$(@D)/Sources/CCairo/shim.h
	$(INSTALL) -D -m 0644 -t $(STAGING_DIR)/usr/lib/swift/CFreeType \
		$(@D)/Sources/CFreeType/module.modulemap \
		$(@D)/Sources/CFreeType/shim.h
endef

define SWIFT_CAIRO_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(SWIFT_CAIRO_BUILDDIR)/libCairo.so \
		$(TARGET_DIR)/usr/lib/libCairo.so
endef

$(eval $(generic-package))
