################################################################################
#
# decibels
#
################################################################################

DECIBELS_VERSION = 48.0
DECIBELS_SOURCE = decibels-$(DECIBELS_VERSION).tar.xz
DECIBELS_SITE = https://download.gnome.org/sources/decibels/48
DECIBELS_LICENSE = GPL-3.0+
DECIBELS_LICENSE_FILES = COPYING
# host-desktop-file-utils for gnome.post_install(update_desktop_database: true),
# which resolves update-desktop-database when meson configures. Several other
# apps here already depend on it, so the tool does get built - but decibels
# configures before any of them, and a dependency that is only satisfied by
# build order is not one.
DECIBELS_DEPENDENCIES = host-pkgconf host-typescript host-blueprint-compiler host-desktop-file-utils libgtk4 libadwaita gjs gst1-plugins-base gst1-plugins-good

# blueprint-compiler resolves every widget name against a GIR typelib, and it
# runs on the build machine, so it searches HOST_DIR/lib/girepository-1.0 -
# where there is no Gtk, only the host's own GLib and GIRepository:
#
#   error: Namespace Gtk was not imported
#     23 |      ShortcutsShortcut {
#        |      ^^^^^^^^^^^^^^^^^
#     hint: Did you mean `xft`?
#
# Gtk-4.0.typelib and Adw-1.typelib are the target's, in the staging sysroot.
# GI_TYPELIB_PATH prepends to the search path rather than replacing it, so the
# host typelibs the compiler also needs stay reachable. Reading a typelib is
# metadata only - nothing dlopen()s the target libraries it describes - so a
# target typelib is safe to consult from a host tool.
#
# Meson packages take their build environment from NINJA_ENV; MAKE_ENV is not
# consulted for the build step (see pkg-meson.mk).
DECIBELS_NINJA_ENV = GI_TYPELIB_PATH=$(STAGING_DIR)/usr/lib/girepository-1.0

DECIBELS_CONF_OPTS =

$(eval $(meson-package))
