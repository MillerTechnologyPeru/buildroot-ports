################################################################################
#
# cacao
#
################################################################################

# Upstream has no releases of the SwiftUI implementation; this is develop.
CACAO_VERSION = e245c79481eb89c6670b7b208529500c10953ed6
CACAO_SITE = $(call github,PureSwift,Cacao,$(CACAO_VERSION))
CACAO_LICENSE = MIT
CACAO_LICENSE_FILES = LICENSE
CACAO_INSTALL_STAGING = YES
CACAO_SUPPORTS_IN_SOURCE_BUILD = NO
# host-cacao-macros is not needed to build Cacao; it is here so that whatever
# builds against Cacao can use the @Entry macro.
CACAO_DEPENDENCIES = \
	host-cmake host-ninja host-pkgconf host-cacao-macros \
	swift swift-foundation silica swift-sdl sdl3 wayland

CACAO_BUILDDIR = $(@D)/build

CACAO_LIBDIR = usr/lib/swift/$(SWIFT_LIB_SUBDIR)

CACAO_LIBRARIES = \
	Cacao CacaoCompositor CacaoHost CacaoRender CacaoSDL \
	CacaoScrollPhysics CacaoWayland Combine SwiftUI

# Loading Silica's Cairo backend loads the Cairo module and its C modules,
# whose headers cairo and FreeType install in their own directories.
#
# -no-toolchain-stdlib-rpath: the driver would otherwise give the library a
# run path to the staging tree's Swift libraries. On the target they are in
# /usr/lib, which the loader searches anyway.
CACAO_SWIFT_FLAGS = \
	$(call qstrip,$(SWIFTC_FLAGS)) \
	-no-toolchain-stdlib-rpath \
	-Xcc -I$(STAGING_DIR)/usr/include/cairo \
	-Xcc -I$(STAGING_DIR)/usr/include/freetype2

# CacaoWayland is C, built with the Swift toolchain's clang like the C
# parts of the other Swift packages.
CACAO_C_FLAGS = \
	-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) \
	$(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include \
	-B$(STAGING_DIR)/usr/lib \
	-B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
	-L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))

ifeq ($(BR2_PACKAGE_CACAO_DEMO),y)
CACAO_CONF_OPTS += -DCACAO_BUILD_DEMO=ON
else
CACAO_CONF_OPTS += -DCACAO_BUILD_DEMO=OFF
endif

# Configured by hand rather than with the cmake-package infrastructure,
# whose toolchain file would hand the project the GCC cross compiler.
#
# SWIFT_SYSTEM_NAME and SWIFT_SYSTEM_ARCH name the resource directory's
# platform and architecture directories, which the project would otherwise
# take from the machine doing the build.
define CACAO_CONFIGURE_CMDS
	rm -f $(CACAO_BUILDDIR)/CMakeCache.txt
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(BR2_CMAKE) -S $(@D) -B $(CACAO_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=$(SWIFT_CMAKE_PROCESSOR) \
		-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
		-DCMAKE_C_FLAGS="$(CACAO_C_FLAGS)" \
		-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_Swift_COMPILER=$(SWIFT_NATIVE_PATH)/swiftc \
		-DCMAKE_Swift_FLAGS="$(CACAO_SWIFT_FLAGS)" \
		-DCMAKE_Swift_FLAGS_DEBUG="" \
		-DCMAKE_Swift_FLAGS_RELEASE="" \
		-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \
		-DCMAKE_FIND_ROOT_PATH=$(STAGING_DIR) \
		-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
		-DSDL3_DIR=$(STAGING_DIR)/usr/lib/cmake/SDL3 \
		-DPKG_CONFIG_EXECUTABLE=$(PKG_CONFIG_HOST_BINARY) \
		-DSWIFT_SYSTEM_NAME=$(SWIFT_LIB_SUBDIR) \
		-DSWIFT_SYSTEM_ARCH=$(SWIFT_TARGET_ARCH) \
		-DBUILD_SHARED_LIBS=ON \
		-DCACAO_BUILD_HOST=ON \
		-DCACAO_BUILD_SWIFTUI=ON \
		-DCACAO_BUILD_MACROS=OFF \
		$(CACAO_CONF_OPTS)
endef

define CACAO_BUILD_CMDS
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(BR2_CMAKE) --build $(CACAO_BUILDDIR) -j $(PARALLEL_JOBS)
endef

define CACAO_INSTALL_STAGING_CMDS
	DESTDIR=$(STAGING_DIR) $(BR2_CMAKE) --install $(CACAO_BUILDDIR)
endef

# The libraries only: modules are for the compiler.
define CACAO_INSTALL_TARGET_CMDS
	$(foreach library,$(CACAO_LIBRARIES),\
		$(INSTALL) -D -m 0755 \
			$(STAGING_DIR)/$(CACAO_LIBDIR)/lib$(library).so \
			$(TARGET_DIR)/usr/lib/lib$(library).so$(sep))
	$(if $(BR2_PACKAGE_CACAO_DEMO),\
		$(INSTALL) -D -m 0755 $(STAGING_DIR)/usr/bin/CacaoDemo \
			$(TARGET_DIR)/usr/bin/CacaoDemo)
endef

$(eval $(generic-package))
