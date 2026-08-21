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
# host-xlib_libxcvt for the cvt program. The native backend runs it at build
# time, through gen-default-modes.py, to compute the default display modes
# it compiles in - and the script calls it by name from PATH, so the copy
# has to run on the build machine:
#
#   src/meson.build:1005:8: ERROR: Program 'cvt' not found or not executable
#
# startup-notification: -Dstartup_notification=true below, and it applies
# whenever there are X11 clients - which Xwayland provides even with the
# native X11 backend off - so meson asks for the library:
#
#   meson.build:310:32: ERROR: Dependency "libstartup-notification-1.0"
#   not found
# xlib_libICE and xlib_libSM are what the session registration below is made
# of, and libxcb/libxkbcommon/xlib_libXtst cover the rest of what -Dx11=true
# asks for beyond the Xwayland set. All of them are in the tree already,
# brought in by Xwayland support, but a dependency that only holds because
# something else pulled it in is not one.
MUTTER_DEPENDENCIES = \
	host-pkgconf graphene libgtk4 libei libdisplay-info colord lcms2 \
	libinput libdrm libxkbcommon wayland wayland-protocols pipewire \
	libwacom elogind gsettings-desktop-schemas xkeyboard-config \
	host-wayland host-xlib_libxcvt startup-notification \
	xlib_libICE xlib_libSM xlib_libXtst libxcb

# x11=true is not about running mutter as an X11 window manager: this image is
# Wayland only and launches it with --wayland. It is about
# meta_context_main_notify_ready(), which registers the compositor with
# gnome-session over XSMP and sits inside #ifdef HAVE_X11:
#
#   if (!context_main->options.sm.disable)
#     meta_session_init (context, ...);
#
# With x11=false that call is compiled out, so the shell never registers and
# gnome-session gives up on it after its timeout:
#
#   WARNING: Application 'org.gnome.Shell.desktop' failed to register before
#     timeout
#   gsm-manager.c:283:on_required_app_failure: Unrecoverable failure in
#     required component org.gnome.Shell.desktop
#
# which is the "Oh no! Something has gone wrong." screen, with the shell itself
# running perfectly well behind it.
MUTTER_CONF_OPTS = \
	-Degl_device=true \
	-Dnative_backend=true \
	-Dwayland=true \
	-Dxwayland=true \
	-Dx11=true \
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
