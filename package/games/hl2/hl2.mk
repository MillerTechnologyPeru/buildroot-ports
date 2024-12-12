################################################################################
#
# source-engine configured for hl2
#
################################################################################
# Version: Commits on Dec 30, 2023
HL2_VERSION = 29985681a18508e78dc79ad863952f830be237b6
HL2_SITE = https://github.com/nillerusr/source-engine.git
HL2_SITE_METHOD = git
HL2_GIT_SUBMODULES = yes
HL2_CONF_OPTS = -T release --build-games=hl2 --prefix=/usr/bin/games/hl2
HL2_NEEDS_EXTERNAL_WAF = NO
HL2_LICENSE = SOURCE1SDK
HL2_LICENSE_FILE = LICENSE
HL2_DEPENDENCIES = sdl2 freetype fontconfig opus libpng libjpeg libedit openal bzip2 libcurl zlib

ifeq ($(BR2_PACKAGE_GL4ES),y)
    HL2_DEPENDENCIES += gl4es
endif

ifeq ($(BR2_aarch64),y)
    HL2_ARCH = arm64
else ifeq ($(BR2_arm),y)
    HL2_CONF_OPTS += --32bits
    HL2_ARCH = armv7l
else ifeq ($(BR2_x86_64),y)
    HL2_ARCH = x86_64
endif

$(eval $(waf-package))
