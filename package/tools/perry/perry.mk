################################################################################
#
# perry
#
################################################################################

# Upstream has no releases; this is master.
PERRY_VERSION = 0a7dfff33fbef9f25e31c2b648e2d83ba5e6f520
PERRY_SITE = $(call github,MillerTechnologyPeru,Perry,$(PERRY_VERSION))
PERRY_LICENSE = MIT
PERRY_LICENSE_FILES = LICENSE
PERRY_DEPENDENCIES = \
	host-cmake host-ninja host-pkgconf swift swift-foundation \
	sdl3 cairo fontconfig freetype libxml2 libpng jpeg giflib webp libheif \
	zlib bzip2 xz lz4 brotli expat sqlite openblas dbus

# The providers, built by SwiftPM. No Swift: Darwin's Swift runtime and the
# frameworks in Perry's Darwin directory (SwiftUI, Combine and the other
# Swift overlays) are compiled on a Mac; so is armv7's libc++, a Mach-O
# library linked by Apple's ld64.
PERRY_PRODUCTS_COMMON = \
	PerrySystem Perryobjc Perrydispatch PerryFoundation Perryxml2 Perryz \
	PerryCXX PerryStdCXX PerryExecShim PerryOpenAL Perrybz2 PerryBom \
	Perryxar Perrycurl Perryexpat Perrysqlite3 Perryiconv Perryresolv \
	Perryicucore Perrycompression PerryCFNetwork \
	PerryUniformTypeIdentifiers PerryAccelerate PerryAudioToolbox \
	PerryUserNotifications PerryAVFoundation PerrySystemConfiguration \
	PerryNetwork PerryCoreTelephony PerryStoreKit PerryVideoToolbox \
	PerryCarPlay PerryCallKit PerryIntents PerryDeviceCheck \
	PerryWatchConnectivity PerryMetricKit PerryBackgroundTasks \
	PerryLocalAuthentication PerryPushKit PerryCoreSpotlight PerryGameKit \
	PerryGameController PerryMediaPlayer PerryCoreLocation \
	PerryCoreBluetooth PerryCoreWLAN PerryMapKit PerryCloudKit \
	PerryCoreGraphics PerryQuartzCore

# The Mac's own frameworks, which iOS has not.
PERRY_PRODUCTS_MAC = \
	PerryAppKit PerryMapKitAppKit PerryIOKit Perrysteam_api PerryOpenGL \
	PerryOpenCL

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
	Perryresolv Perryicucore Perryxar Perrycurl PerryStdCXX PerryBom \
	PerryOpenAL PerryAudioToolbox PerryAccelerate PerrySystemConfiguration \
	PerryIOKit PerryOpenGL PerryCoreGraphics PerryQuartzCore PerryAppKit
define PERRY_BUILD_LOADER
	cd $(@D) && PPC_CC=$(TARGET_CC) Scripts/build-ppc-loader.sh
	cd $(@D) && PPC_CC=$(TARGET_CC) Scripts/build-ppc-carbon.sh
endef
PERRY_EXTRA_LIBRARIES = $(@D)/.build/ppc/bin/libPerryCarbon.so
PERRY_LOADER_FILE = $(@D)/.build/ppc/bin/perry
else ifeq ($(BR2_arm),y)
# 32-bit ARM: armv7 iOS programs, Objective-C and C only, run as their own
# 32-bit process, perry32, which perry runs for them: built in the 32-bit
# companion, whose /usr/lib/perry becomes the image's /usr/lib32/perry, and
# linked beside perry there (post-build-lib32.sh). The providers of what
# iOS 10, the last iOS to run armv7 programs, has, and nothing else: no Mac
# frameworks (AppKit, CoreWLAN) or libraries iOS has no API for (libcurl,
# libxar, Bom); nothing later than iOS 10 (Network, CarPlay, DeviceCheck,
# MetricKit, BackgroundTasks); no LowHeap, a heap above 4 GB; no Metal,
# which iOS has only on arm64. Darwin's armv7 code treats r9 as scratch,
# which Linux's keeps across calls, so nothing of Perry's keeps a value in
# it (-ffixed-r9); and perry32 is linked at a fixed address far above the
# programs, which are not position independent.
PERRY_LOADER = perry32
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
PERRY_SWIFTPM_FLAGS = -Xcc -ffixed-r9
PERRY_LOADER_CFLAGS = -march=armv7-a -mfloat-abi=hard -ffixed-r9
PERRY_LOADER_SOURCES = \
	$(wildcard $(@D)/Sources/PerryLoaderCore/*.c) \
	$(wildcard $(@D)/Sources/PerryLoaderCore/*.S) \
	$(@D)/Sources/PerryInterface/interface.c \
	$(wildcard $(@D)/Sources/PerryLoader/*.c)
define PERRY_BUILD_LOADER
	mkdir -p $(@D)/.build/loader
	$(foreach source,$(PERRY_LOADER_SOURCES),
		$(TARGET_CC) $(PERRY_LOADER_CFLAGS) -fPIC -O1 -g -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 \
			-I$(@D)/Sources/PerryLoaderCore/include -I$(@D)/Sources/PerryInterface/include \
			-c $(source) -o $(@D)/.build/loader/$(notdir $(source)).o
	)
	$(TARGET_CC) -no-pie -Wl,-Ttext-segment=0x70000000 \
		$(foreach source,$(PERRY_LOADER_SOURCES),$(@D)/.build/loader/$(notdir $(source)).o) \
		-o $(@D)/.build/loader/perry32 -ldl -lpthread
endef
PERRY_LOADER_FILE = $(@D)/.build/loader/perry32
else
# 64-bit (arm64, x86_64): arm64 iOS and Mac programs, and x86_64 Mac ones,
# with every provider but Carbon's, which is PowerPC's: JavaScriptCore's
# over webkitgtk's, which perry selects where its own dependencies are met
# (a GTK, EGL). The loader is SwiftPM's perry.
PERRY_LOADER = perry
PERRY_PRODUCTS = $(PERRY_PRODUCTS_COMMON) $(PERRY_PRODUCTS_MAC) PerryLowHeap \
	PerrySecurity PerryCoreData PerryUIKit PerryMetal PerryModelIO \
	PerryWebExtension
ifeq ($(BR2_PACKAGE_WEBKITGTK),y)
PERRY_PRODUCTS += PerryJavaScriptCore
PERRY_DEPENDENCIES += webkitgtk
endif
define PERRY_BUILD_LOADER
	cd $(@D) && $(PERRY_SWIFTPM_ENV) $(PERRY_SWIFTPM) --product perry
endef
PERRY_LOADER_FILE = $(PERRY_SWIFTPM_DIR)/perry
endif

PERRY_PREFIX = $(@D)/.toolchains/sysroot
PERRY_SWIFTPM_DIR = $(@D)/.build/release

# The SwiftPM destination file, which a tree seeded from a toolchain release
# lacks (swift.mk), written before the build as pkg-swift.mk's packages do.
PERRY_PRE_BUILD_HOOKS += SWIFT_GENERATE_DESTINATION_FILE

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
	PKG_CONFIG_PATH=$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig

PERRY_SWIFTPM = \
	$(SWIFT_NATIVE_PATH)/swift build \
		--build-system native \
		--destination $(SWIFT_DESTINATION_FILE) \
		--configuration release \
		-j $(PARALLEL_JOBS) \
		-Xcc -I$(PERRY_PREFIX)/usr/include \
		-Xlinker -L$(PERRY_PREFIX)/usr/lib \
		$(PERRY_SWIFTPM_FLAGS)

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
