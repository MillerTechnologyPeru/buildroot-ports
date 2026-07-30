################################################################################
#
# sdl3_ttf
#
# Satellite library for sdl3, so it is built with CMake like sdl3 itself
# rather than with the autotools setup the SDL2 counterpart uses.
#
################################################################################

SDL3_TTF_VERSION = 3.2.2
SDL3_TTF_SOURCE = SDL3_ttf-$(SDL3_TTF_VERSION).tar.gz
SDL3_TTF_SITE = https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(SDL3_TTF_VERSION)
SDL3_TTF_LICENSE = Zlib
SDL3_TTF_LICENSE_FILES = LICENSE.txt
SDL3_TTF_CPE_ID_VENDOR = libsdl
SDL3_TTF_CPE_ID_PRODUCT = sdl_ttf
SDL3_TTF_INSTALL_STAGING = YES
SDL3_TTF_DEPENDENCIES = sdl3 freetype host-pkgconf

# STRICT makes the build fail when a dependency we asked for cannot be
# found, instead of silently dropping the feature.
SDL3_TTF_CONF_OPTS = \
	-DSDLTTF_VENDORED=OFF \
	-DSDLTTF_STRICT=ON \
	-DSDLTTF_SAMPLES=OFF \
	-DSDLTTF_INSTALL_MAN=OFF

# plutosvg is what renders OpenType-SVG glyphs, i.e. colour emoji.
ifeq ($(BR2_PACKAGE_PLUTOSVG),y)
SDL3_TTF_CONF_OPTS += -DSDLTTF_PLUTOSVG=ON
SDL3_TTF_DEPENDENCIES += plutosvg
else
SDL3_TTF_CONF_OPTS += -DSDLTTF_PLUTOSVG=OFF
endif

ifeq ($(BR2_PACKAGE_HARFBUZZ),y)
SDL3_TTF_CONF_OPTS += -DSDLTTF_HARFBUZZ=ON
SDL3_TTF_DEPENDENCIES += harfbuzz
else
SDL3_TTF_CONF_OPTS += -DSDLTTF_HARFBUZZ=OFF
endif

$(eval $(cmake-package))
