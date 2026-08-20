################################################################################
#
# xdg-desktop-portal-gnome
#
################################################################################

XDG_DESKTOP_PORTAL_GNOME_VERSION = 47.3
XDG_DESKTOP_PORTAL_GNOME_SOURCE = xdg-desktop-portal-gnome-$(XDG_DESKTOP_PORTAL_GNOME_VERSION).tar.xz
XDG_DESKTOP_PORTAL_GNOME_SITE = https://download.gnome.org/sources/xdg-desktop-portal-gnome/47
XDG_DESKTOP_PORTAL_GNOME_LICENSE = LGPL-2.1+
XDG_DESKTOP_PORTAL_GNOME_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
XDG_DESKTOP_PORTAL_GNOME_INSTALL_STAGING = YES
XDG_DESKTOP_PORTAL_GNOME_DEPENDENCIES = \
	host-pkgconf xdg-desktop-portal libgtk4 libadwaita gnome-desktop \
	gsettings-desktop-schemas

$(eval $(meson-package))
