################################################################################
#
# perry
#
################################################################################

# Upstream has no releases; this commit is master's, with JavaScriptCore's
# provider over WPE WebKit's, its pixels' bytes kept in order on PowerPC,
# its Foundation building on armv7, and Carbon moving into Swift.
PERRY_VERSION = 3bb66979822a2782e87e45de9d18f48ec6105c4e
PERRY_SITE = $(call github,MillerTechnologyPeru,Perry,$(PERRY_VERSION))
PERRY_LICENSE = MIT
PERRY_LICENSE_FILES = LICENSE
PERRY_DEPENDENCIES = \
	host-cmake host-ninja host-pkgconf swift swift-foundation \
	sdl3 cairo fontconfig freetype libxml2 libpng jpeg giflib webp libheif \
	zlib bzip2 xz lz4 brotli expat sqlite dbus

# The providers, built by SwiftPM, for what each architecture's programs
# call. No Swift: Darwin's Swift runtime and the frameworks in Perry's
# Darwin directory (SwiftUI, Combine and the other Swift overlays) are
# compiled on a Mac; so is armv7's libc++, a Mach-O library linked by
# Apple's ld64.
ifeq ($(BR2_powerpc),y)
# 32-bit PowerPC: PowerPC Mac programs, Mac OS X 10.3 to 10.5, so the
# providers of what Mac OS X 10.5 has and nothing later: no libc++,
# libcompression, UniformTypeIdentifiers, OpenCL, AVFoundation, Network or
# the rest. libdispatch (10.6) is the exception, as Foundation's and
# libSystem's providers are built on it. Not Security, over swift-crypto,
# whose BoringSSL builds for little-endian machines only ("Unknown target
# CPU"), nor Core Data, over CoreModel, whose typed-throws async functions
# crash Swift 6.4.2's code generation for PowerPC (an assertion in
# IRGenFunction::createErrorResultSlot). The loader, which translates
# between Darwin's ppc calling convention and Linux's, and Carbon's provider
# are built by Perry's own scripts.
PERRY_LOADER = perry
PERRY_PRODUCTS = \
	PerrySystem Perryobjc Perrydispatch PerryFoundation PerryCFNetwork \
	Perryxml2 Perryz Perrybz2 Perryexpat Perrysqlite3 Perryiconv \
	Perryresolv Perryncurses Perryicucore Perryxar Perrycurl PerryStdCXX PerryBom \
	PerryOpenAL PerryAudioToolbox PerryAccelerate PerrySystemConfiguration \
	PerryIOKit PerryOpenGL PerryCoreGraphics PerryQuartzCore PerryAppKit
define PERRY_BUILD_LOADER
	cd $(@D) && PPC_CC=$(TARGET_CC) Scripts/build-ppc-loader.sh
	cd $(@D) && PPC_CC=$(TARGET_CC) Scripts/build-ppc-carbon.sh
endef
PERRY_EXTRA_LIBRARIES = $(@D)/.build/ppc/bin/libPerryCarbon.so
PERRY_LOADER_FILE = $(@D)/.build/ppc/bin/perry
else ifeq ($(BR2_arm)$(BR2_i386),y)
# 32-bit ARM and x86: a 32-bit program runs as its own 32-bit process,
# perry32, which perry runs for it: built in the 32-bit companion, whose
# /usr/lib/perry becomes the image's /usr/lib32/perry, and linked beside
# perry there (post-build-lib32.sh). perry32 is linked at a fixed address
# far above the programs, which are not position independent.
PERRY_LOADER = perry32
PERRY_LOADER_SOURCES = \
	$(wildcard $(@D)/Sources/PerryLoaderCore/*.c) \
	$(wildcard $(@D)/Sources/PerryLoaderCore/*.S) \
	$(@D)/Sources/PerryInterface/interface.c \
	$(wildcard $(@D)/Sources/PerryLoader/*.c)
PERRY_C_CFLAGS = -fPIC -O1 -g -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 \
	-I$(@D)/Sources/PerryInterface/include
ifeq ($(BR2_arm),y)
# armv7 iOS programs, Objective-C and C only, and the providers of what
# iOS 10, the last iOS to run armv7 programs, has, and nothing else: no Mac
# frameworks (AppKit, CoreWLAN) or libraries iOS has no API for (libcurl,
# libxar, Bom); nothing later than iOS 10 (Network, CarPlay, DeviceCheck,
# MetricKit, BackgroundTasks); no LowHeap, a heap above 4 GB; no Metal,
# which iOS has only on arm64. Darwin's armv7 code treats r9 as scratch,
# which Linux's keeps across calls, so nothing of Perry's keeps a value in
# it (-ffixed-r9).
PERRY_PRODUCTS = \
	PerrySystem Perryobjc Perrydispatch PerryFoundation PerryCFNetwork \
	Perryxml2 Perryz Perrybz2 Perryexpat Perrysqlite3 Perryiconv \
	Perryresolv Perryicucore Perrycompression PerryCXX PerryStdCXX \
	PerryUIKit PerryCoreGraphics PerryQuartzCore PerrySecurity \
	PerryCoreData PerryUniformTypeIdentifiers PerryAccelerate PerryOpenAL \
	PerryAudioToolbox PerryAVFoundation PerryVideoToolbox PerryMediaPlayer \
	PerrySystemConfiguration PerryCoreTelephony PerryStoreKit PerryGameKit \
	PerryGameController PerryCoreLocation PerryCoreBluetooth PerryMapKit \
	PerryCloudKit PerryUserNotifications PerryCallKit PerryIntents \
	PerryWatchConnectivity PerryCoreSpotlight PerryModelIO \
	PerryLocalAuthentication PerryPushKit
PERRY_TARGET_CFLAGS = -ffixed-r9
PERRY_ARCH_CFLAGS = -march=armv7-a -mfloat-abi=hard -ffixed-r9
else
# i386 Mac programs, which macOS ran until 10.14, and the providers of what
# macOS 10.14 has for them, and nothing later or 64-bit only: no Metal,
# Model I/O, UniformTypeIdentifiers (macOS 11), DeviceCheck, PushKit or
# the iOS frameworks; no LowHeap, a heap above 4 GB; no JavaScriptCore or
# web extension, whose WebKit the 32-bit companion does not have. Darwin
# returns small structures in eax:edx, where Linux's i386 ABI returns them
# through a pointer (-freg-struct-return). Carbon's and QuickTime's
# providers are C, built here as Perry's i386 scripts build them.
PERRY_PRODUCTS = \
	PerrySystem Perryobjc Perrydispatch PerryFoundation PerryCFNetwork \
	Perryxml2 Perryz Perrybz2 Perryexpat Perrysqlite3 Perryiconv \
	Perryresolv Perryncurses Perryicucore Perryxar Perrycurl Perrycompression PerryCXX \
	PerryStdCXX PerryBom PerryExecShim PerryOpenAL PerryAudioToolbox \
	PerryAccelerate PerrySystemConfiguration PerryIOKit PerryOpenGL \
	PerryOpenCL PerryCoreGraphics PerryQuartzCore PerryAppKit \
	PerrySecurity PerryCoreData PerryAVFoundation PerryVideoToolbox \
	PerryNetwork PerryUserNotifications PerryGameKit PerryGameController \
	PerryMediaPlayer PerryCoreLocation PerryCoreBluetooth PerryCoreWLAN \
	PerryMapKit PerryMapKitAppKit PerryCloudKit PerryStoreKit \
	PerryLocalAuthentication PerryCoreSpotlight PerryIntents Perrysteam_api
PERRY_TARGET_CFLAGS = -freg-struct-return -msse2 -mfpmath=sse
PERRY_ARCH_CFLAGS = -march=i686 -msse2 -mfpmath=sse
PERRY_EXTRA_LIBRARIES = \
	$(@D)/.build/c/libPerryCarbon.so \
	$(@D)/.build/c/libPerryQuickTime.so
define PERRY_BUILD_C_PROVIDERS
	mkdir -p $(@D)/.build/c
	$(TARGET_CC) $(PERRY_ARCH_CFLAGS) $(PERRY_C_CFLAGS) -freg-struct-return \
		-I$(@D)/Sources/CPerryCarbon/include \
		-I$(STAGING_DIR)/usr/include/freetype2 -shared \
		$(wildcard $(@D)/Sources/CPerryCarbon/*.c) \
		-o $(@D)/.build/c/libPerryCarbon.so -lm -lpthread -lfreetype -Wl,-z,defs
	$(TARGET_CC) $(PERRY_ARCH_CFLAGS) $(PERRY_C_CFLAGS) -freg-struct-return \
		-I$(@D)/Sources/PerryQuickTime -shared \
		$(wildcard $(@D)/Sources/PerryQuickTime/*.c) \
		-o $(@D)/.build/c/libPerryQuickTime.so -lm -lpthread -ldl -Wl,-z,defs
endef
endif
define PERRY_BUILD_LOADER
	mkdir -p $(@D)/.build/loader
	$(foreach source,$(PERRY_LOADER_SOURCES),
		$(TARGET_CC) $(PERRY_ARCH_CFLAGS) $(PERRY_C_CFLAGS) \
			-I$(@D)/Sources/PerryLoaderCore/include \
			-c $(source) -o $(@D)/.build/loader/$(notdir $(source)).o
	)
	$(TARGET_CC) -no-pie -Wl,-Ttext-segment=0x70000000 \
		$(foreach source,$(PERRY_LOADER_SOURCES),$(@D)/.build/loader/$(notdir $(source)).o) \
		-o $(@D)/.build/loader/perry32 -ldl -lpthread
	$(PERRY_BUILD_C_PROVIDERS)
endef
PERRY_LOADER_FILE = $(@D)/.build/loader/perry32
else
# 64-bit (arm64, x86_64): arm64 iOS and Mac programs, and x86_64 Mac ones,
# with every provider but Carbon's, which is PowerPC's. JavaScriptCore's
# is WPE WebKit's JavaScriptCore, which perry selects where WPE WebKit can
# be built (EGL, GLES), and which swift-linux's patch makes export its C API
# and install its headers. The loader is SwiftPM's perry.
PERRY_LOADER = perry
PERRY_PRODUCTS = \
	PerrySystem Perryobjc Perrydispatch PerryFoundation Perryxml2 Perryz \
	PerryCXX PerryStdCXX PerryExecShim PerryOpenAL Perrybz2 PerryBom \
	Perryxar Perrycurl Perryexpat Perrysqlite3 Perryiconv Perryresolv Perryncurses \
	Perryicucore Perrycompression PerryCFNetwork \
	PerryUniformTypeIdentifiers PerryAccelerate PerryAudioToolbox \
	PerryUserNotifications PerryAVFoundation PerrySystemConfiguration \
	PerryNetwork PerryCoreTelephony PerryStoreKit PerryVideoToolbox \
	PerryCarPlay PerryCallKit PerryIntents PerryDeviceCheck \
	PerryWatchConnectivity PerryMetricKit PerryBackgroundTasks \
	PerryLocalAuthentication PerryPushKit PerryCoreSpotlight PerryGameKit \
	PerryGameController PerryMediaPlayer PerryCoreLocation \
	PerryCoreBluetooth PerryCoreWLAN PerryMapKit PerryCloudKit \
	PerryCoreGraphics PerryQuartzCore PerryAppKit PerryMapKitAppKit \
	PerryIOKit Perrysteam_api PerryOpenGL PerryOpenCL PerryLowHeap \
	PerrySecurity PerryCoreData PerryUIKit PerryMetal PerryModelIO \
	PerryWebExtension
ifeq ($(BR2_PACKAGE_WPEWEBKIT),y)
PERRY_PRODUCTS += PerryJavaScriptCore
PERRY_DEPENDENCIES += wpewebkit
PERRY_SWIFTPM_ENV_EXTRA = PERRY_JAVASCRIPTCORE=wpe
endif
define PERRY_BUILD_LOADER
	cd $(@D) && $(PERRY_SWIFTPM_ENV) $(PERRY_SWIFTPM) --product perry
endef
PERRY_LOADER_FILE = $(PERRY_SWIFTPM_DIR)/perry
endif

# Accelerate's provider is BLAS and LAPACK over OpenBLAS, which Buildroot
# offers only for the CPUs it has a target for: without it, no Accelerate.
ifeq ($(BR2_PACKAGE_OPENBLAS),y)
PERRY_DEPENDENCIES += openblas
else
PERRY_PRODUCTS := $(filter-out PerryAccelerate,$(PERRY_PRODUCTS))
endif

PERRY_PREFIX = $(@D)/.toolchains/sysroot
PERRY_SWIFTPM_DIR = $(@D)/.build/release

# The SwiftPM destination file, which a tree seeded from a toolchain release
# lacks (swift.mk), written before the build as pkg-swift.mk's packages do.
PERRY_PRE_BUILD_HOOKS += SWIFT_GENERATE_DESTINATION_FILE

# A copy of it with the architecture's flags in its target-only lists: SwiftPM
# also builds the macros and plugins for the build machine, whose compiler
# rejects them ("unsupported option '-ffixed-r9' for target
# 'x86_64-unknown-linux-gnu'") if they are given by -Xcc.
PERRY_DESTINATION = $(@D)/.build/destination.json
define PERRY_WRITE_DESTINATION
	mkdir -p $(@D)/.build
	sed -e 's|"extra-cc-flags":\[|"extra-cc-flags":[$(foreach flag,$(PERRY_TARGET_CFLAGS), "$(flag)",)|' \
		-e 's|"extra-swiftc-flags":\[|"extra-swiftc-flags":[$(foreach flag,$(PERRY_TARGET_CFLAGS), "-Xcc", "$(flag)",)|' \
		$(SWIFT_DESTINATION_FILE) > $(PERRY_DESTINATION)
endef
PERRY_PRE_BUILD_HOOKS += PERRY_WRITE_DESTINATION

# SwiftPM's native build system is named because the swift-build backend,
# the default from Swift 6.4, ignores --destination.
#
# SwiftPM reads .pc files itself rather than running pkg-config, so it is
# pointed at the staging tree's: left to its own search it found the host's
# libxml-2.0.pc, and linked the build machine's libxml2.
PERRY_SWIFTPM_ENV = \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) \
	PKG_CONFIG_LIBDIR=$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig \
	PKG_CONFIG_PATH=$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig \
	$(PERRY_SWIFTPM_ENV_EXTRA)

PERRY_SWIFTPM = \
	$(SWIFT_NATIVE_PATH)/swift build \
		--build-system native \
		--destination $(PERRY_DESTINATION) \
		--configuration release \
		-j $(PARALLEL_JOBS) \
		-Xcc -I$(PERRY_PREFIX)/usr/include \
		-Xlinker -L$(PERRY_PREFIX)/usr/lib

# The C libraries the providers link that Buildroot has no package for, or
# not built as Perry's are (SQLite with Apple's options, lzfse, swift-cmark),
# by Perry's script for them, which takes any architecture's cross compiler
# despite its name.
define PERRY_BUILD_CMDS
	cd $(@D) && PATH=$(BR_PATH) PPC_CC=$(TARGET_CC) PPC_PREFIX=$(PERRY_PREFIX) \
		Scripts/build-ppc-sysroot.sh
	$(PERRY_BUILD_LOADER)
	$(foreach product,$(PERRY_PRODUCTS),
		cd $(@D) && $(PERRY_SWIFTPM_ENV) $(PERRY_SWIFTPM) --product $(product)
	)
endef

# perry finds its providers in its own directory (after
# PERRY_LIBRARY_PATH), which /proc/self/exe names through the symbolic
# link; perry32, in a 32-bit companion, in its own too, which becomes
# /usr/lib32/perry.
define PERRY_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(PERRY_LOADER_FILE) $(TARGET_DIR)/usr/lib/perry/$(PERRY_LOADER)
	$(INSTALL) -D -m 0755 -t $(TARGET_DIR)/usr/lib/perry \
		$(PERRY_EXTRA_LIBRARIES) \
		$(PERRY_PREFIX)/usr/lib/libperry-sqlite3.so \
		$(foreach product,$(PERRY_PRODUCTS),$(PERRY_SWIFTPM_DIR)/lib$(product).so)
	ln -sf ../lib/perry/$(PERRY_LOADER) $(TARGET_DIR)/usr/bin/$(PERRY_LOADER)
endef

$(eval $(generic-package))
