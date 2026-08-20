################################################################################
#
# gnome-control-center
#
################################################################################

GNOME_CONTROL_CENTER_VERSION = 47.7
GNOME_CONTROL_CENTER_SOURCE = gnome-control-center-$(GNOME_CONTROL_CENTER_VERSION).tar.xz
GNOME_CONTROL_CENTER_SITE = https://download.gnome.org/sources/gnome-control-center/47
GNOME_CONTROL_CENTER_LICENSE = GPL-2.0+
GNOME_CONTROL_CENTER_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
GNOME_CONTROL_CENTER_INSTALL_STAGING = YES
GNOME_CONTROL_CENTER_DEPENDENCIES = host-pkgconf libgtk4 libadwaita accountsservice colord-gtk cups gnome-bluetooth gnome-desktop gnome-online-accounts gnome-settings-daemon gsound libgtop libgudev libnma libpwquality libwacom libxml2 modem-manager network-manager polkit pulseaudio udisks2 upower ibus libkrb5 tecla samba4

GNOME_CONTROL_CENTER_CONF_OPTS = -Ddocumentation=false -Dtests=false -Dibus=true -Dsnap=false -Dmalcontent=false

# meson.build checks that polkit's gettext ITS files exist by running
# build-aux/meson/find_xdg_file.py, which walks XDG_DATA_DIRS on the build
# machine - a host-side lookup for what is a target file:
#
#   ERROR: Command `.../find_xdg_file.py gettext/its/polkit.its` failed
#
# The files are in the sysroot; point the search there. Nothing else in
# configure reads XDG_DATA_DIRS, so this only affects that check.
GNOME_CONTROL_CENTER_CONF_ENV = XDG_DATA_DIRS=$(STAGING_DIR)/usr/share

$(eval $(meson-package))
