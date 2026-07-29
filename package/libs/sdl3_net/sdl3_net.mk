################################################################################
#
# sdl3_net
#
# Satellite library for sdl3, so it is built with CMake like sdl3 itself
# rather than with the autotools setup the SDL2 counterpart uses.
#
################################################################################

SDL3_NET_VERSION = 3.2.0
SDL3_NET_SOURCE = SDL3_net-$(SDL3_NET_VERSION).tar.gz
SDL3_NET_SITE = https://github.com/libsdl-org/SDL_net/releases/download/release-$(SDL3_NET_VERSION)
SDL3_NET_LICENSE = Zlib
SDL3_NET_LICENSE_FILES = LICENSE.txt
SDL3_NET_CPE_ID_VENDOR = libsdl
SDL3_NET_CPE_ID_PRODUCT = sdl_net
SDL3_NET_INSTALL_STAGING = YES
SDL3_NET_DEPENDENCIES = sdl3 host-pkgconf

SDL3_NET_CONF_OPTS = \
	-DSDLNET_SAMPLES=OFF \
	-DSDLNET_INSTALL_MAN=OFF

$(eval $(cmake-package))
