################################################################################
#
# perry
#
################################################################################

# Upstream has no releases; this commit is pull request 404's, on its way to master.
PERRY_VERSION = 1d4e8ded5c4996cbccf274333aa4da899d542d8c
PERRY_SITE = $(call github,MillerTechnologyPeru,Perry,$(PERRY_VERSION))
PERRY_LICENSE = MIT
PERRY_LICENSE_FILES = LICENSE
PERRY_DEPENDENCIES = \
	host-cmake host-ninja host-pkgconf swift swift-foundation \
	sdl3 cairo fontconfig freetype libxml2 libpng jpeg giflib webp libheif \
	zlib bzip2 xz lz4 brotli expat sqlite openblas dbus

# Every provider that builds on Linux, by SwiftPM: all of Perry's but
# JavaScriptCore's and WPE WebKit's web extension, which need WebKit, which
# Buildroot doesn't build for PowerPC; Security's, over swift-crypto, whose
# BoringSSL builds for little-endian machines only ("Unknown target CPU");
# and Metal's, which no PowerPC Mac program calls. Nor Swift: Darwin's Swift runtime and the frameworks in
# Perry's Darwin directory (SwiftUI, Combine and the other Swift overlays)
# are compiled on a Mac, and no PowerPC Mac program is written in Swift. The loader,
# Carbon's provider and the C libraries the providers link (SQLite with
# Apple's options, lzfse, swift-cmark) are built by Perry's own scripts with
# the cross compiler.
PERRY_PRODUCTS = \
	PerrySystem Perryobjc Perrydispatch PerryFoundation Perryxml2 Perryz \
	PerryCXX PerryStdCXX PerryLowHeap PerryExecShim PerryOpenAL \
	PerryOpenGL PerryOpenCL Perrysteam_api Perrybz2 PerryBom Perryxar \
	Perrycurl Perryexpat Perrysqlite3 Perryiconv Perryresolv Perryicucore \
	Perrycompression PerryCFNetwork \
	PerryUniformTypeIdentifiers PerryAccelerate PerryAudioToolbox \
	PerryUserNotifications PerryAVFoundation PerrySystemConfiguration \
	PerryNetwork PerryIOKit PerryCoreTelephony PerryStoreKit \
	PerryVideoToolbox PerryCarPlay PerryCallKit PerryIntents \
	PerryDeviceCheck PerryWatchConnectivity PerryMetricKit \
	PerryBackgroundTasks PerryLocalAuthentication PerryPushKit \
	PerryCoreSpotlight PerryGameKit PerryGameController PerryMediaPlayer \
	PerryCoreLocation PerryCoreBluetooth PerryCoreWLAN PerryMapKit \
	PerryMapKitAppKit PerryCloudKit PerryCoreData PerryCoreGraphics \
	PerryQuartzCore PerryUIKit PerryAppKit

PERRY_PREFIX = $(@D)/.toolchains/ppc-sysroot
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

define PERRY_BUILD_CMDS
	cd $(@D) && PATH=$(BR_PATH) PPC_CC=$(TARGET_CC) PPC_PREFIX=$(PERRY_PREFIX) \
		Scripts/build-ppc-sysroot.sh
	cd $(@D) && PPC_CC=$(TARGET_CC) Scripts/build-ppc-loader.sh
	cd $(@D) && PPC_CC=$(TARGET_CC) Scripts/build-ppc-carbon.sh
	$(foreach product,$(PERRY_PRODUCTS),
		cd $(@D) && $(PERRY_SWIFTPM_ENV) \
		$(SWIFT_NATIVE_PATH)/swift build \
			--build-system native \
			--destination $(SWIFT_DESTINATION_FILE) \
			--configuration release \
			-j $(PARALLEL_JOBS) \
			--product $(product) \
			-Xcc -I$(PERRY_PREFIX)/usr/include \
			-Xlinker -L$(PERRY_PREFIX)/usr/lib
	)
endef

# perry finds its providers in its own directory (after
# PERRY_LIBRARY_PATH), which /proc/self/exe names through the symbolic link.
define PERRY_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/.build/ppc/bin/perry $(TARGET_DIR)/usr/lib/perry/perry
	$(INSTALL) -D -m 0755 -t $(TARGET_DIR)/usr/lib/perry \
		$(@D)/.build/ppc/bin/libPerryCarbon.so \
		$(PERRY_PREFIX)/usr/lib/libperry-sqlite3.so \
		$(foreach product,$(PERRY_PRODUCTS),$(PERRY_SWIFTPM_DIR)/lib$(product).so)
	ln -sf ../lib/perry/perry $(TARGET_DIR)/usr/bin/perry
endef

$(eval $(generic-package))
