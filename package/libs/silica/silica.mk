################################################################################
#
# silica
#
################################################################################

# Upstream's releases predate its CMake build; this is master.
SILICA_VERSION = e67e2709a5004f99a14c7d5af78c5390c020d3c6
SILICA_SITE = $(call github,PureSwift,Silica,$(SILICA_VERSION))
SILICA_LICENSE = MIT
SILICA_LICENSE_FILES = LICENSE
SILICA_INSTALL_STAGING = YES
SILICA_SUPPORTS_IN_SOURCE_BUILD = NO
SILICA_DEPENDENCIES = \
	host-cmake host-ninja swift swift-foundation swift-cairo swift-fontconfig

SILICA_BUILDDIR = $(@D)/build

SILICA_LIBDIR = usr/lib/swift/$(SWIFT_LIB_SUBDIR)

# Loading the Cairo module loads its C modules, whose headers cairo and
# FreeType install in their own directories.
#
# -no-toolchain-stdlib-rpath: the driver would otherwise give the library a
# run path to the staging tree's Swift libraries. On the target they are in
# /usr/lib, which the loader searches anyway.
SILICA_SWIFT_FLAGS = \
	$(call qstrip,$(SWIFTC_FLAGS)) \
	-no-toolchain-stdlib-rpath \
	-Xcc -I$(STAGING_DIR)/usr/include/cairo \
	-Xcc -I$(STAGING_DIR)/usr/include/freetype2

# The project is all Swift, so the Swift toolchain's CMake flags are enough;
# Buildroot's own CMake toolchain file would hand it the GCC cross compiler.
#
# SWIFT_SYSTEM_NAME and SWIFT_SYSTEM_ARCH name the resource directory's
# platform and architecture directories, which the project would otherwise
# take from the machine doing the build.
define SILICA_CONFIGURE_CMDS
	rm -f $(SILICA_BUILDDIR)/CMakeCache.txt
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(BR2_CMAKE) -S $(@D) -B $(SILICA_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=$(SWIFT_CMAKE_PROCESSOR) \
		-DCMAKE_Swift_COMPILER=$(SWIFT_NATIVE_PATH)/swiftc \
		-DCMAKE_Swift_FLAGS="$(SILICA_SWIFT_FLAGS)" \
		-DCMAKE_Swift_FLAGS_DEBUG="" \
		-DCMAKE_Swift_FLAGS_RELEASE="" \
		-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \
		-DSWIFT_SYSTEM_NAME=$(SWIFT_LIB_SUBDIR) \
		-DSWIFT_SYSTEM_ARCH=$(SWIFT_TARGET_ARCH) \
		-DBUILD_SHARED_LIBS=ON \
		-DSILICA_BUILD_CAIRO=ON
endef

define SILICA_BUILD_CMDS
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(BR2_CMAKE) --build $(SILICA_BUILDDIR) -j $(PARALLEL_JOBS)
endef

define SILICA_INSTALL_STAGING_CMDS
	DESTDIR=$(STAGING_DIR) $(BR2_CMAKE) --install $(SILICA_BUILDDIR)
endef

# The libraries only: modules are for the compiler.
define SILICA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 -t $(TARGET_DIR)/usr/lib \
		$(STAGING_DIR)/$(SILICA_LIBDIR)/libSilica.so \
		$(STAGING_DIR)/$(SILICA_LIBDIR)/libSilicaCairo.so
endef

$(eval $(generic-package))
