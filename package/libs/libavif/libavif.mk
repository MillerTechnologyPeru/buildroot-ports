################################################################################
#
# libavif
#
# Needed by sdl3_image for AVIF support. dav1d provides decoding; Buildroot
# has no AV1 encoder, so encoding is unavailable at runtime.
#
################################################################################

LIBAVIF_VERSION = 1.4.2
LIBAVIF_SITE = $(call github,AOMediaCodec,libavif,v$(LIBAVIF_VERSION))
LIBAVIF_LICENSE = BSD-2-Clause
LIBAVIF_LICENSE_FILES = LICENSE
LIBAVIF_INSTALL_STAGING = YES
LIBAVIF_DEPENDENCIES = host-pkgconf dav1d

# zlib, libpng and jpeg are only used by the apps and the test suite, and
# libsharpyuv only by the encoder, which has no codec to drive here.
LIBAVIF_CONF_OPTS = \
	-DAVIF_CODEC_DAV1D=SYSTEM \
	-DAVIF_LIBSHARPYUV=OFF \
	-DAVIF_ZLIBPNG=OFF \
	-DAVIF_JPEG=OFF \
	-DAVIF_BUILD_APPS=OFF \
	-DAVIF_BUILD_EXAMPLES=OFF \
	-DAVIF_BUILD_TESTS=OFF \
	-DAVIF_BUILD_MAN_PAGES=OFF

# libyuv only adds faster colour conversion paths.
ifeq ($(BR2_PACKAGE_LIBYUV),y)
LIBAVIF_CONF_OPTS += -DAVIF_LIBYUV=SYSTEM
LIBAVIF_DEPENDENCIES += libyuv
else
LIBAVIF_CONF_OPTS += -DAVIF_LIBYUV=OFF
endif

$(eval $(cmake-package))
