################################################################################
#
# libretro-genesis-plus-gx
#
# Pinned by commit: the libretro cores are rolling repositories without
# release tags. Cores install under /usr/lib/libretro, where retroarch's
# libretro_directory points.
#
################################################################################

LIBRETRO_GENESIS_PLUS_GX_VERSION = b9c2316441978d4015ba30e9a95d9b0e6f8ee981
LIBRETRO_GENESIS_PLUS_GX_SITE = $(call github,libretro,Genesis-Plus-GX,$(LIBRETRO_GENESIS_PLUS_GX_VERSION))
LIBRETRO_GENESIS_PLUS_GX_LICENSE = Genesis Plus GX (non-commercial)
LIBRETRO_GENESIS_PLUS_GX_LICENSE_FILES = LICENSE.txt

define LIBRETRO_GENESIS_PLUS_GX_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) -f Makefile.libretro platform=unix \
		CC="$(TARGET_CC)" CXX="$(TARGET_CXX)" AR="$(TARGET_AR)"
endef

define LIBRETRO_GENESIS_PLUS_GX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/genesis_plus_gx_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/genesis_plus_gx_libretro.so
endef

$(eval $(generic-package))
