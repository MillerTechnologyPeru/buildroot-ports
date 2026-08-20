################################################################################
#
# gnome-console
#
################################################################################

GNOME_CONSOLE_VERSION = 47.2.1
GNOME_CONSOLE_SOURCE = gnome-console-$(GNOME_CONSOLE_VERSION).tar.xz
GNOME_CONSOLE_SITE = https://download.gnome.org/sources/gnome-console/47
GNOME_CONSOLE_LICENSE = GPL-3.0+
GNOME_CONSOLE_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
GNOME_CONSOLE_INSTALL_STAGING = YES
GNOME_CONSOLE_DEPENDENCIES = host-pkgconf host-desktop-file-utils libgtk4 libadwaita vte4 libgtop gsettings-desktop-schemas

GNOME_CONSOLE_CONF_OPTS = -Dtests=false

$(eval $(meson-package))
