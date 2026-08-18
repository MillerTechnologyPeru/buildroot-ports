################################################################################
#
# colord
#
################################################################################

COLORD_VERSION = 1.4.8
COLORD_SOURCE = colord-$(COLORD_VERSION).tar.xz
COLORD_SITE = https://www.freedesktop.org/software/colord/releases
COLORD_LICENSE = GPL-2.0+, LGPL-2.1+ (libraries)
COLORD_LICENSE_FILES = COPYING
COLORD_INSTALL_STAGING = YES
COLORD_DEPENDENCIES = host-pkgconf host-lcms2 host-libglib2 lcms2 libgudev libgusb sqlite dbus

COLORD_CONF_OPTS = -Dman=false -Ddocs=false -Dbash_completion=false -Dsystemd=false -Dargyllcms_sensor=false -Dsession_example=false -Dtests=false -Dinstalled_tests=false -Dvapi=false -Dprint_profiles=false -Dlibcolordcompat=false -Ddaemon_user=colord

# data/profiles renders the standard ICC display profiles - sRGB, AdobeRGB,
# Rec709 - by running the cd-create-profile it just built, which is for the
# target. The 0002 patch adds a host_cd_create_profile option naming a
# build-machine copy to run instead; this is where that copy comes from.
#
# A host meson build of colord is not on the table - it asks for gusb, gudev
# and libudev unconditionally, and neither of the first two has a host
# variant - but the generator itself needs none of that: it links the
# colour, DOM and ICC halves of the library plus gio and lcms2. So compile
# exactly those sources for the host, straight from the tree. cd-edid.c is
# the one file in the library that touches gudev, and cd-create-profile does
# not call into it.
#
# HOST_MAKE_ENV is what makes pkg-config answer for the host: a package's
# recipes run with PKG_CONFIG_SYSROOT_DIR and PKG_CONFIG_LIBDIR pointing into
# the target sysroot, so asking without it returns the target's glib and the
# host link then fails on the target libc. Both generated headers the sources
# want - config.h and lib/colord/cd-version.h - are written by configure, so
# this runs after it.
#
# cd-edid.c has to come along after all: cd-icc.c calls the cd_edid_* getters
# for cd_icc_create_from_edid, so leaving it out fails the link. Its one use
# of udev - looking a monitor vendor up in the hwdb - is the #ifndef PNP_IDS
# fallback; with PNP_IDS defined it reads a text file instead and libudev is
# never called. The #include <libudev.h> is unconditional though, and the
# host tree has no such header, so an empty one is put on the include path
# to satisfy it. Nothing here runs the EDID code path; the symbols only have
# to resolve.
#
# The binary is compiled by this hook, which runs after configure so that
# config.h exists, and only needs to be there by the time ninja runs it. It
# stays in the build tree, so nothing about it reaches the host tree or the
# target.
COLORD_HOST_SRCS = \
	cd-buffer cd-color cd-context-lcms cd-dom cd-edid cd-enum cd-icc \
	cd-icc-store cd-icc-utils cd-interp-akima cd-interp cd-interp-linear \
	cd-it8 cd-it8-utils cd-math cd-quirk cd-spectrum cd-transform
define COLORD_BUILD_HOST_CREATE_PROFILE
	mkdir -p $(@D)/host-bin/include
	: > $(@D)/host-bin/include/libudev.h
	$(HOST_MAKE_ENV) $(HOSTCC) $(HOST_CFLAGS) \
		-DCD_COMPILATION -DG_LOG_DOMAIN='"Cd"' \
		-DLOCALSTATEDIR='"/var"' -DPNP_IDS='"/usr/share/hwdata/pnp.ids"' \
		-DPACKAGE_NAME='"colord"' -DPACKAGE_VERSION='"$(COLORD_VERSION)"' \
		-I$(@D)/host-bin/include \
		-I$(@D) -I$(@D)/lib -I$(@D)/lib/colord \
		-I$(@D)/buildroot-build -I$(@D)/buildroot-build/lib/colord \
		`$(HOST_MAKE_ENV) $(HOST_DIR)/bin/pkg-config --cflags gio-2.0 gio-unix-2.0 lcms2` \
		-o $(@D)/host-bin/cd-create-profile \
		$(@D)/client/cd-create-profile.c \
		$(foreach s,$(COLORD_HOST_SRCS),$(@D)/lib/colord/$(s).c) \
		`$(HOST_MAKE_ENV) $(HOST_DIR)/bin/pkg-config --libs gio-2.0 gio-unix-2.0 lcms2` \
		$(HOST_LDFLAGS) -lm
endef
COLORD_POST_CONFIGURE_HOOKS += COLORD_BUILD_HOST_CREATE_PROFILE
COLORD_CONF_OPTS += -Dhost_cd_create_profile=$(@D)/host-bin/cd-create-profile

# gnome-shell drives everything through GObject introspection typelibs, so
# build them whenever the config carries gobject-introspection.
ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
COLORD_CONF_OPTS += -Dintrospection=true
COLORD_DEPENDENCIES += gobject-introspection
else
COLORD_CONF_OPTS += -Dintrospection=false
endif

$(eval $(meson-package))
