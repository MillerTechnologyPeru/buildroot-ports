################################################################################
#
# super-video-golf
#
################################################################################

SUPER_VIDEO_GOLF_VERSION = golf-v1.18.2
SUPER_VIDEO_GOLF_SITE = https://github.com/fallahn/crogine.git
SUPER_VIDEO_GOLF_SITE_METHOD = git
SUPER_VIDEO_GOLF_GIT_SUBMODULES = NO
SUPER_VIDEO_GOLF_LICENSE = Zlib
SUPER_VIDEO_GOLF_LICENSE_FILE = readme.md

SUPER_VIDEO_GOLF_DEPENDENCIES += sdl2 opus openal freetype sqlite libcurl bullet libunwind tbb

SUPER_VIDEO_GOLF_SUPPORTS_IN_SOURCE_BUILD = NO

SUPER_VIDEO_GOLF_OPTS += -DBUILD_SAMPLES=ON

$(eval $(cmake-package))
