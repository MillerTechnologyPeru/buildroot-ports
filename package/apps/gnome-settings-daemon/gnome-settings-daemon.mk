################################################################################
#
# gnome-settings-daemon
#
# The volume-control helper (gvc, bundled in the tarball) talks libpulse:
# on this image the PulseAudio *client* library is served by
# pipewire-pulse, so the pulseaudio package is needed only for libpulse -
# its daemon stays disabled. Smartcard, cups and network-manager
# integrations off, matching the image.
#
################################################################################

GNOME_SETTINGS_DAEMON_VERSION = 47.2
GNOME_SETTINGS_DAEMON_SOURCE = gnome-settings-daemon-$(GNOME_SETTINGS_DAEMON_VERSION).tar.xz
GNOME_SETTINGS_DAEMON_SITE = https://download.gnome.org/sources/gnome-settings-daemon/47
GNOME_SETTINGS_DAEMON_LICENSE = GPL-2.0+
GNOME_SETTINGS_DAEMON_LICENSE_FILES = COPYING
# network-manager for libnm: gsd's meson.build asserts NetworkManager support
# on Linux, along with rfkill and ALSA -
#
#   Assert failed: rfkill is not optional on Linux platforms
#   Assert failed: NetworkManager support is not optional on Linux platforms
#
# so neither can be turned off here, and both were. libnm was already in the
# sysroot through the network fragment; naming it makes the ordering real.
GNOME_SETTINGS_DAEMON_DEPENDENCIES = \
	host-pkgconf colord libgweather geocode-glib gnome-desktop \
	libnotify libwacom upower polkit pulseaudio elogind \
	gsettings-desktop-schemas network-manager

# elogind is in the dependency list but was never asked for, so gsd defaulted
# to systemd-logind for session tracking. -Delogind=true is what makes it use
# the one that is actually running.
GNOME_SETTINGS_DAEMON_CONF_OPTS = \
	-Dsystemd=false \
	-Delogind=true \
	-Dsmartcard=false \
	-Dcups=false \
	-Dusb-protection=false \
	-Dwwan=false

$(eval $(meson-package))
