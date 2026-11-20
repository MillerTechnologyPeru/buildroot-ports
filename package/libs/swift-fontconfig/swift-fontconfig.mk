################################################################################
#
# swift-fontconfig
#
################################################################################

# Upstream has no releases; this is master.
SWIFT_FONTCONFIG_VERSION = 02b7b628cfff1406731dde5e912e020f0f6f00c1
SWIFT_FONTCONFIG_SITE = $(call github,PureSwift,FontConfig,$(SWIFT_FONTCONFIG_VERSION))
SWIFT_FONTCONFIG_LICENSE = MIT
SWIFT_FONTCONFIG_LICENSE_FILES = LICENSE
SWIFT_FONTCONFIG_INSTALL_STAGING = YES
SWIFT_FONTCONFIG_DEPENDENCIES = swift swift-foundation fontconfig freetype

SWIFT_FONTCONFIG_BUILDDIR = $(@D)/build

# Where the Swift resource directory keeps a platform's libraries, and its
# modules for one architecture.
SWIFT_FONTCONFIG_LIBDIR = usr/lib/swift/$(SWIFT_LIB_SUBDIR)
SWIFT_FONTCONFIG_MODULEDIR = $(SWIFT_FONTCONFIG_LIBDIR)/$(SWIFT_TARGET_ARCH)

# The package is a SwiftPM one with no CMake build, and SwiftPM only links
# static libraries into what it builds. The module is one directory of Swift
# sources over a C module, so it is compiled directly into a shared library
# that names itself for autolinking, as the CMake-built Swift packages do.
#
# The C module (CFontConfig) is found in the source tree here; remove a copy
# staged by an earlier build first, or the compiler sees it defined twice.
#
# -no-toolchain-stdlib-rpath: the driver would otherwise give the library a
# run path to the staging tree's Swift libraries. On the target they are in
# /usr/lib, which the loader searches anyway.
define SWIFT_FONTCONFIG_BUILD_CMDS
	rm -rf $(STAGING_DIR)/usr/lib/swift/CFontConfig
	mkdir -p $(SWIFT_FONTCONFIG_BUILDDIR)
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_NATIVE_PATH)/swiftc $(call qstrip,$(SWIFTC_FLAGS)) \
		-no-toolchain-stdlib-rpath \
		-emit-library -emit-module -parse-as-library -swift-version 6 \
		$(if $(BR2_ENABLE_RUNTIME_DEBUG),-Onone -g,-O) \
		-module-name FontConfig -module-link-name FontConfig \
		-emit-module-path $(SWIFT_FONTCONFIG_BUILDDIR)/FontConfig.swiftmodule \
		-o $(SWIFT_FONTCONFIG_BUILDDIR)/libFontConfig.so \
		-I $(@D)/Sources \
		-Xcc -I$(STAGING_DIR)/usr/include/freetype2 \
		$(@D)/Sources/FontConfig/*.swift
endef

# The module is built without library evolution, so what imports it needs
# the C module too: Clang finds it as <resource dir>/CFontConfig.
define SWIFT_FONTCONFIG_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(SWIFT_FONTCONFIG_BUILDDIR)/libFontConfig.so \
		$(STAGING_DIR)/$(SWIFT_FONTCONFIG_LIBDIR)/libFontConfig.so
	$(INSTALL) -D -m 0644 $(SWIFT_FONTCONFIG_BUILDDIR)/FontConfig.swiftmodule \
		$(STAGING_DIR)/$(SWIFT_FONTCONFIG_MODULEDIR)/FontConfig.swiftmodule
	$(INSTALL) -D -m 0644 -t $(STAGING_DIR)/usr/lib/swift/CFontConfig \
		$(@D)/Sources/CFontConfig/module.modulemap \
		$(@D)/Sources/CFontConfig/shim.h
endef

define SWIFT_FONTCONFIG_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(SWIFT_FONTCONFIG_BUILDDIR)/libFontConfig.so \
		$(TARGET_DIR)/usr/lib/libFontConfig.so
endef

$(eval $(generic-package))
