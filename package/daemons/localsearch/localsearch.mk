################################################################################
#
# localsearch
#
################################################################################

LOCALSEARCH_VERSION = 3.8.2
LOCALSEARCH_SOURCE = localsearch-$(LOCALSEARCH_VERSION).tar.xz
LOCALSEARCH_SITE = https://download.gnome.org/sources/localsearch/3.8
LOCALSEARCH_LICENSE = GPL-2.0+
LOCALSEARCH_LICENSE_FILES = COPYING
LOCALSEARCH_INSTALL_STAGING = YES
# dbus-1, gudev-1.0, gobject-introspection-1.0 and the icu pair are plain
# dependency() calls with no option behind them, so meson stops at the first
# one missing regardless of what is switched off here. Every one of them does
# get built by something else in this frontend - dbus by half the session,
# libgudev by colord and udisks2, icu by tinysparql - but a dependency that
# only holds because of build order is not one.
#
# gstreamer is not optional either: generic_media_extractor is a combo that
# defaults to 'gstreamer', and that branch errors out rather than falling
# back if the libraries are absent ("GStreamer media handler was enabled but
# required GStreamer libraries were not found"). gst1-plugins-base is what
# carries gstreamer-pbutils-1.0.
LOCALSEARCH_DEPENDENCIES = host-pkgconf tinysparql dbus libgudev icu \
	gobject-introspection libseccomp gstreamer1 gst1-plugins-base

# functional_tests and sandbox_tests both default on and build test-only
# modules - a mock volume monitor, extractor stubs - that nothing installs.
# The suite runs the built binaries against a private session bus, which a
# cross build cannot do at all.
#
# landlock is left off because this kernel does not carry it:
# sdk/board/x86_64/linux.fragment adds nothing for it and the built config
# has "# CONFIG_SECURITY_LANDLOCK is not set". Upstream only run-checks the
# kernel when the option is auto, and a cross build cannot run that probe:
#
#   meson.build:158:22: ERROR: Can not run test applications in this cross
#     environment.
#
# Saying "enabled" would skip the probe - upstream's own escape hatch for
# isolated build environments - but would compile in a sandbox the kernel
# cannot honour. "disabled" is the answer the probe would have reached: it
# errors out with "Landlock was auto-enabled in build options, but is
# disabled in the kernel". The seccomp sandbox is unaffected.
#
# systemd_user_services defaults on and takes the install directory from
# systemd.pc, so absent systemd it stops at configure:
#
#   meson.build:309:6: ERROR: Problem encountered: systemd user services were
#     enabled, but systemd was not found.
#
# This image runs OpenRC; the .service files would have nothing to read them.
LOCALSEARCH_CONF_OPTS = -Dman=false -Dbattery_detection=none \
	-Dfunctional_tests=false -Dsandbox_tests=false -Dlandlock=disabled \
	-Dsystemd_user_services=false

# The raw-image extractor; gexiv2 is optional (the option is a feature that
# defaults to auto) so follow the config rather than force it. nautilus
# already selects gexiv2, which is why this built before it was declared.
ifeq ($(BR2_PACKAGE_GEXIV2),y)
LOCALSEARCH_CONF_OPTS += -Draw=enabled
LOCALSEARCH_DEPENDENCIES += gexiv2
else
LOCALSEARCH_CONF_OPTS += -Draw=disabled
endif

$(eval $(meson-package))
