################################################################################
#
# gnome-calendar
#
################################################################################

GNOME_CALENDAR_VERSION = 47.0
GNOME_CALENDAR_SOURCE = gnome-calendar-$(GNOME_CALENDAR_VERSION).tar.xz
GNOME_CALENDAR_SITE = https://download.gnome.org/sources/gnome-calendar/47
GNOME_CALENDAR_LICENSE = GPL-3.0+
GNOME_CALENDAR_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
GNOME_CALENDAR_INSTALL_STAGING = YES
GNOME_CALENDAR_DEPENDENCIES = host-pkgconf libgtk4 libadwaita evolution-data-server libgweather geoclue2 libical gsettings-desktop-schemas

GNOME_CALENDAR_CONF_OPTS =

$(eval $(meson-package))
