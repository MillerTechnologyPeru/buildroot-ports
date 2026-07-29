################################################################################
#
# sdl3_image
#
# Satellite library for sdl3, so it is built with CMake like sdl3 itself
# rather than with the autotools setup the SDL2 counterpart uses.
#
################################################################################

SDL3_IMAGE_VERSION = 3.4.4
SDL3_IMAGE_SOURCE = SDL3_image-$(SDL3_IMAGE_VERSION).tar.gz
SDL3_IMAGE_SITE = https://github.com/libsdl-org/SDL_image/releases/download/release-$(SDL3_IMAGE_VERSION)
SDL3_IMAGE_LICENSE = Zlib
SDL3_IMAGE_LICENSE_FILES = LICENSE.txt
SDL3_IMAGE_CPE_ID_VENDOR = libsdl
SDL3_IMAGE_CPE_ID_PRODUCT = sdl_image
SDL3_IMAGE_INSTALL_STAGING = YES
SDL3_IMAGE_DEPENDENCIES = sdl3 host-pkgconf

# BMP, GIF, LBM, PCX, PNM, QOI, SVG, TGA, XCF, XPM and XV need no
# dependency, so they are left enabled by default. STRICT makes the build
# fail when a format we asked for cannot find its library, instead of
# silently dropping it. DEPS_SHARED=OFF links the image libraries
# directly rather than dlopen()ing them at runtime.
# AVIF is disabled because Buildroot has no libavif.
SDL3_IMAGE_CONF_OPTS = \
	-DSDLIMAGE_VENDORED=OFF \
	-DSDLIMAGE_DEPS_SHARED=OFF \
	-DSDLIMAGE_STRICT=ON \
	-DSDLIMAGE_SAMPLES=OFF \
	-DSDLIMAGE_TESTS=OFF \
	-DSDLIMAGE_INSTALL_MAN=OFF \
	-DSDLIMAGE_AVIF=OFF

# The bundled stb_image decoder handles JPEG with no external library, so
# it is only needed when libjpeg is unavailable.
ifeq ($(BR2_PACKAGE_JPEG),y)
SDL3_IMAGE_CONF_OPTS += \
	-DSDLIMAGE_BACKEND_STB=OFF \
	-DSDLIMAGE_JPG=ON
SDL3_IMAGE_DEPENDENCIES += jpeg
else
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_BACKEND_STB=ON
endif

# PNG loading falls back to the decoder in SDL3 itself; libpng only adds
# APNG support and PNG saving.
ifeq ($(BR2_PACKAGE_LIBPNG),y)
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_PNG_LIBPNG=ON
SDL3_IMAGE_DEPENDENCIES += libpng
else
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_PNG_LIBPNG=OFF
endif

ifeq ($(BR2_PACKAGE_TIFF),y)
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_TIF=ON
SDL3_IMAGE_DEPENDENCIES += tiff
else
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_TIF=OFF
endif

# libwebp, libwebpdemux and libwebpmux are all required.
ifeq ($(BR2_PACKAGE_WEBP_DEMUX)$(BR2_PACKAGE_WEBP_MUX),yy)
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_WEBP=ON
SDL3_IMAGE_DEPENDENCIES += webp
else
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_WEBP=OFF
endif

ifeq ($(BR2_PACKAGE_LIBJXL),y)
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_JXL=ON
SDL3_IMAGE_DEPENDENCIES += libjxl
else
SDL3_IMAGE_CONF_OPTS += -DSDLIMAGE_JXL=OFF
endif

$(eval $(cmake-package))
