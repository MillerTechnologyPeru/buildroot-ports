################################################################################
#
# showtime
#
################################################################################

SHOWTIME_VERSION = 48.1
SHOWTIME_SOURCE = showtime-$(SHOWTIME_VERSION).tar.xz
SHOWTIME_SITE = https://download.gnome.org/sources/showtime/48
SHOWTIME_LICENSE = GPL-3.0+
SHOWTIME_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
SHOWTIME_INSTALL_STAGING = YES
SHOWTIME_DEPENDENCIES = host-pkgconf host-blueprint-compiler libgtk4 libadwaita python3 python-gobject gst1-plugins-base gst1-plugins-good

SHOWTIME_CONF_OPTS = 

$(eval $(meson-package))
