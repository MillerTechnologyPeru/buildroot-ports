################################################################################
#
# wine-prebuilt
#
# Upstream's WoW64 build: 64-bit Wine that runs 32-bit Windows programs
# through Windows-side WoW64 rather than 32-bit Unix libraries - which is
# what lets the identical tarball serve x86_64 (native) and aarch64
# (through box64). Installed whole under /usr/wine/prebuilt, the same
# self-contained layout the reference distributions use for their Wine
# variants.
#
################################################################################

WINE_PREBUILT_VERSION = 11.0
WINE_PREBUILT_SITE = https://github.com/Kron4ek/Wine-Builds/releases/download/$(WINE_PREBUILT_VERSION)
WINE_PREBUILT_SOURCE = wine-$(WINE_PREBUILT_VERSION)-amd64-wow64.tar.xz
WINE_PREBUILT_LICENSE = LGPL-2.1+ (prebuilt upstream release)

# These binaries being the wrong architecture is the point of the package:
# on aarch64 they are x86-64 on purpose, run through box64. Buildroot's
# check-bin-arch does not know that and fails the install the first time an
# arm64 image carries this package -
#
#   ERROR: architecture for "/usr/wine/prebuilt/bin/wrc" is "Advanced Micro
#   Devices X86-64", should be "AArch64"
#
# - which no x86_64 image could ever show, since there the architectures
# happen to agree. Exclude the tree the package owns and nothing else.
WINE_PREBUILT_BIN_ARCH_EXCLUDE = /usr/wine/prebuilt

define WINE_PREBUILT_EXTRACT_CMDS
	mkdir -p $(@D)/dist
	$(XZCAT) $(WINE_PREBUILT_DL_DIR)/$(WINE_PREBUILT_SOURCE) | \
		$(TAR) --strip-components=1 -C $(@D)/dist -xf -
endef

define WINE_PREBUILT_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/wine/prebuilt
	cp -a $(@D)/dist/. $(TARGET_DIR)/usr/wine/prebuilt/
endef

$(eval $(generic-package))
