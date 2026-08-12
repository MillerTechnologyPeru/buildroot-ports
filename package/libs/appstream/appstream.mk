################################################################################
#
# appstream
#
################################################################################

APPSTREAM_VERSION = 1.0.6
APPSTREAM_SOURCE = AppStream-$(APPSTREAM_VERSION).tar.xz
APPSTREAM_SITE = https://www.freedesktop.org/software/appstream/releases
APPSTREAM_LICENSE = LGPL-2.1+
APPSTREAM_LICENSE_FILES = COPYING
APPSTREAM_INSTALL_STAGING = YES

# The release tarball archives its entries as ./AppStream-<version>/..., so the
# leading ./ is the first path component and Buildroot's default strip of 1
# takes that instead of the directory, leaving the source one level down:
#
#   ERROR: Neither source directory '.../appstream-1.0.6/' nor build directory
#   '.../buildroot-build' contain a build file meson.build.
APPSTREAM_STRIP_COMPONENTS = 2
APPSTREAM_DEPENDENCIES = host-pkgconf libglib2 libxmlb libyaml libcurl

APPSTREAM_CONF_OPTS = \
	-Dstemming=false \
	-Dgir=false \
	-Dapidocs=false \
	-Ddocs=false \
	-Dcompose=false \
	-Dvapi=false \
	-Dsystemd=false \
	-Dsvg-support=false

$(eval $(meson-package))
