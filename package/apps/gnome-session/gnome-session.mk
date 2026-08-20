################################################################################
#
# gnome-session
#
# 47 dropped the systemd_session and systemd_journal options that used to
# select the builtin session manager - they are simply unknown to meson now -
# and made libsystemd a hard dependency. See the note by CONF_OPTS.
#
################################################################################

GNOME_SESSION_VERSION = 47.0.1
GNOME_SESSION_SOURCE = gnome-session-$(GNOME_SESSION_VERSION).tar.xz
GNOME_SESSION_SITE = https://download.gnome.org/sources/gnome-session/47
GNOME_SESSION_LICENSE = GPL-2.0+
GNOME_SESSION_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
GNOME_SESSION_INSTALL_STAGING = YES
GNOME_SESSION_DEPENDENCIES = \
	host-pkgconf libglib2 upower json-glib elogind \
	gsettings-desktop-schemas gnome-desktop

# systemduserunitdir is set so meson does not go looking for systemd's own
# pkg-config file to ask where user units belong; it only decides an install
# path.
#
# 47's meson.build takes libsystemd as required, with no option. That is
# satisfied by elogind: this elogind exports every sd_* symbol the session
# calls - the sd-login and sd-daemon set, and sd_journal_send and
# sd_journal_stream_fd besides, which it implements as stubs since there is
# no journal - and its package installs a libsystemd.pc that resolves to
# libelogind, so meson's lookup by that name succeeds. All sixteen symbols
# were checked against libelogind.so before relying on this.
GNOME_SESSION_CONF_OPTS = \
	-Dsystemduserunitdir=/usr/lib/systemd/user \
	-Ddocbook=false \
	-Dman=false

$(eval $(meson-package))
