################################################################################
#
# sdl3_mixer
#
# Satellite library for sdl3, so it is built with CMake like sdl3 itself
# rather than with the autotools setup the SDL2 counterpart uses.
#
################################################################################

SDL3_MIXER_VERSION = 3.2.4
SDL3_MIXER_SOURCE = SDL3_mixer-$(SDL3_MIXER_VERSION).tar.gz
SDL3_MIXER_SITE = https://github.com/libsdl-org/SDL_mixer/releases/download/release-$(SDL3_MIXER_VERSION)
SDL3_MIXER_LICENSE = Zlib
SDL3_MIXER_LICENSE_FILES = LICENSE.txt
SDL3_MIXER_CPE_ID_VENDOR = libsdl
SDL3_MIXER_CPE_ID_PRODUCT = sdl_mixer
SDL3_MIXER_INSTALL_STAGING = YES
SDL3_MIXER_DEPENDENCIES = sdl3 host-pkgconf

# AIFF, AU, VOC and WAVE, plus the bundled dr_flac, dr_mp3, stb_vorbis and
# timidity decoders, need no dependency and are left enabled by default.
# STRICT makes the build fail when a decoder we asked for cannot find its
# library, instead of silently dropping it. DEPS_SHARED=OFF links the
# decoder libraries directly rather than dlopen()ing them at runtime.
# GME needs game-music-emu and MOD needs libxmp; neither is packaged by
# Buildroot.
SDL3_MIXER_CONF_OPTS = \
	-DSDLMIXER_VENDORED=OFF \
	-DSDLMIXER_DEPS_SHARED=OFF \
	-DSDLMIXER_STRICT=ON \
	-DSDLMIXER_TESTS=OFF \
	-DSDLMIXER_EXAMPLES=OFF \
	-DSDLMIXER_INSTALL_MAN=OFF \
	-DSDLMIXER_GME=OFF \
	-DSDLMIXER_MOD=OFF

ifeq ($(BR2_PACKAGE_FLAC),y)
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_FLAC_LIBFLAC=ON
SDL3_MIXER_DEPENDENCIES += flac
else
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_FLAC_LIBFLAC=OFF
endif

ifeq ($(BR2_PACKAGE_MPG123),y)
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_MP3_MPG123=ON
SDL3_MIXER_DEPENDENCIES += mpg123
else
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_MP3_MPG123=OFF
endif

ifeq ($(BR2_PACKAGE_FLUIDSYNTH),y)
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_MIDI_FLUIDSYNTH=ON
SDL3_MIXER_DEPENDENCIES += fluidsynth
else
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_MIDI_FLUIDSYNTH=OFF
endif

# Opus is decoded through opusfile, which pulls in opus and libogg.
ifeq ($(BR2_PACKAGE_OPUSFILE),y)
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_OPUS=ON
SDL3_MIXER_DEPENDENCIES += opusfile
else
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_OPUS=OFF
endif

ifeq ($(BR2_PACKAGE_WAVPACK),y)
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_WAVPACK=ON
SDL3_MIXER_DEPENDENCIES += wavpack
else
SDL3_MIXER_CONF_OPTS += -DSDLMIXER_WAVPACK=OFF
endif

# Ogg Vorbis comes from either vorbisfile or tremor, never both; upstream
# errors out when the two are enabled together. tremor is the integer-only
# decoder, so it is only used when libvorbis is absent.
ifeq ($(BR2_PACKAGE_LIBVORBIS),y)
SDL3_MIXER_CONF_OPTS += \
	-DSDLMIXER_VORBIS_VORBISFILE=ON \
	-DSDLMIXER_VORBIS_TREMOR=OFF
SDL3_MIXER_DEPENDENCIES += libvorbis
else ifeq ($(BR2_PACKAGE_TREMOR),y)
SDL3_MIXER_CONF_OPTS += \
	-DSDLMIXER_VORBIS_VORBISFILE=OFF \
	-DSDLMIXER_VORBIS_TREMOR=ON
SDL3_MIXER_DEPENDENCIES += tremor
else
SDL3_MIXER_CONF_OPTS += \
	-DSDLMIXER_VORBIS_VORBISFILE=OFF \
	-DSDLMIXER_VORBIS_TREMOR=OFF
endif

$(eval $(cmake-package))
