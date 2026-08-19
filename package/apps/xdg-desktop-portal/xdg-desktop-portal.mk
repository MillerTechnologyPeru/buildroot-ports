################################################################################
#
# xdg-desktop-portal
#
################################################################################

XDG_DESKTOP_PORTAL_VERSION = 1.18.4
XDG_DESKTOP_PORTAL_SITE = $(call github,flatpak,xdg-desktop-portal,$(XDG_DESKTOP_PORTAL_VERSION))
XDG_DESKTOP_PORTAL_LICENSE = LGPL-2.1+
XDG_DESKTOP_PORTAL_LICENSE_FILES = COPYING
# The backends build against it: meson.build generates an
# xdg-desktop-portal.pc carrying the interfaces and portal directories, and
# both xdg-desktop-portal-gnome and -gtk take it as a required dependency.
# Without staging it lands only in target/usr/share/pkgconfig, where no
# cross build looks:
#
#   src/meson.build:4:25: ERROR: Dependency "xdg-desktop-portal" not found
#     (tried pkg-config and cmake)
XDG_DESKTOP_PORTAL_INSTALL_STAGING = YES
XDG_DESKTOP_PORTAL_DEPENDENCIES = \
	host-pkgconf libglib2 json-glib libfuse3 pipewire bubblewrap

# Icon validation runs in a Bubblewrap sandbox, and src/meson.build bakes the
# absolute path of bwrap into validate-icon as -DHELPER="...". So the path
# recorded has to be the one the target will use, /usr/bin/bwrap, while
# find_program looks on the build machine, where there is no bwrap at all:
#
#   meson.build:117:8: ERROR: Program 'bwrap' not found or not executable
#
# Name it in the cross file's [binaries] section, which is what that section
# is for. Pointing it at the staging copy would configure cleanly and then
# bake a build-machine path into a target binary.
#
# Left enabled rather than turned off with -Dsandboxed-image-validation=false:
# the sandbox is what contains image parsing, which upstream calls out as a
# common attack vector, and bubblewrap is in the image anyway.
XDG_DESKTOP_PORTAL_MESON_EXTRA_BINARIES = bwrap='/usr/bin/bwrap'

XDG_DESKTOP_PORTAL_CONF_OPTS = \
	-Dflatpak-interfaces=disabled \
	-Dgeoclue=disabled \
	-Dsystemd=disabled \
	-Ddocbook-docs=disabled \
	-Dman-pages=disabled \
	-Dpytest=disabled \
	-Dinstalled-tests=false

# The .pc carries an interfaces_dir pointing at the D-Bus interface XML, and
# both backends generate their GDBus code from files found through it:
#
#   ninja: error: '/usr/share/dbus-1/interfaces/org.freedesktop.impl.portal.Access.xml',
#     needed by 'src/xdg-desktop-portal-dbus.c', missing and no known rule to make it
#
# pkg-config only applies PKG_CONFIG_SYSROOT_DIR to the -I and -L flags it
# emits, never to a --variable query, so meson's get_variable(pkgconfig:
# 'interfaces_dir') gets the target's absolute path and looks for the XML on
# the build machine. Point prefix at staging in the staging copy of the .pc,
# where the XML really is.
#
# Safe to rewrite wholesale because this .pc has no Libs: or Cflags: lines at
# all - it exists only to carry these variables - so nothing's compile or link
# flags move with it. The target copy is left alone.
define XDG_DESKTOP_PORTAL_FIX_STAGING_PC_PREFIX
	$(SED) 's|^prefix=/usr$$|prefix=$(STAGING_DIR)/usr|' \
		$(STAGING_DIR)/usr/share/pkgconfig/xdg-desktop-portal.pc
endef
XDG_DESKTOP_PORTAL_POST_INSTALL_STAGING_HOOKS += XDG_DESKTOP_PORTAL_FIX_STAGING_PC_PREFIX

$(eval $(meson-package))
