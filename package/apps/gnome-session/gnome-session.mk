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
GNOME_SESSION_DEPENDENCIES = \
	host-pkgconf libglib2 upower json-glib elogind \
	gsettings-desktop-schemas gnome-desktop

# systemduserunitdir is set so meson does not go looking for systemd's own
# pkg-config file to ask where user units belong; it only decides an install
# path. That does not settle the larger problem: 47's meson.build takes
# libsystemd as required, and the session sources call sd_journal_send and
# sd_journal_stream_fd as well as the sd-login and sd-daemon calls elogind
# does provide. elogind ships libelogind.pc only and has no journal, so this
# package still needs a decision rather than an option.
GNOME_SESSION_CONF_OPTS = \
	-Dsystemduserunitdir=/usr/lib/systemd/user \
	-Ddocbook=false \
	-Dman=false

$(eval $(meson-package))
