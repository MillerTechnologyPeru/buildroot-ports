################################################################################
#
# xdg-desktop-portal
#
################################################################################

XDG_DESKTOP_PORTAL_VERSION = 1.18.4
XDG_DESKTOP_PORTAL_SITE = $(call github,flatpak,xdg-desktop-portal,$(XDG_DESKTOP_PORTAL_VERSION))
XDG_DESKTOP_PORTAL_LICENSE = LGPL-2.1+
XDG_DESKTOP_PORTAL_LICENSE_FILES = COPYING
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

$(eval $(meson-package))
