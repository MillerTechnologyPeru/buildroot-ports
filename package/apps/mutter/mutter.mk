################################################################################
#
# mutter
#
# The native (KMS) backend needs a logind provider: the meson dependency
# lookup accepts libelogind, which is why the elogind package installs
# staging libraries. Tests, profiler and docs off; remote desktop stays
# on (pipewire is in the image anyway); X11 support comes via Xwayland
# only - the standalone X11 backend is dropped.
#
################################################################################

MUTTER_VERSION = 47.10
MUTTER_SOURCE = mutter-$(MUTTER_VERSION).tar.xz
MUTTER_SITE = https://download.gnome.org/sources/mutter/47
MUTTER_LICENSE = GPL-2.0+
MUTTER_LICENSE_FILES = COPYING
MUTTER_INSTALL_STAGING = YES
# startup-notification: -Dstartup_notification=true below, and it applies
# whenever there are X11 clients - which Xwayland provides even with the
# native X11 backend off - so meson asks for the library:
#
#   meson.build:310:32: ERROR: Dependency "libstartup-notification-1.0"
#   not found
MUTTER_DEPENDENCIES = \
	host-pkgconf graphene libgtk4 libei libdisplay-info colord lcms2 \
	libinput libdrm libxkbcommon wayland wayland-protocols pipewire \
	libwacom elogind gsettings-desktop-schemas xkeyboard-config \
	host-wayland startup-notification

MUTTER_CONF_OPTS = \
	-Degl_device=true \
	-Dnative_backend=true \
	-Dwayland=true \
	-Dxwayland=true \
	-Dx11=false \
	-Dudev=true \
	-Dsystemd=false \
	-Dlibgnome_desktop=false \
	-Dsound_player=false \
	-Dstartup_notification=true \
	-Dremote_desktop=true \
	-Dprofiler=false \
	-Dtests=disabled \
	-Ddocs=false \
	-Dcogl_tests=false \
	-Dclutter_tests=false

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
MUTTER_CONF_OPTS += -Dintrospection=true
MUTTER_DEPENDENCIES += gobject-introspection
else
MUTTER_CONF_OPTS += -Dintrospection=false
endif

$(eval $(meson-package))
