################################################################################
#
# gdm
#
# Present for libgdm, not for the display manager. gnome-shell's JavaScript
# imports the Gdm typelib unconditionally at startup - js/misc/dependencies.js
# does "import 'gi://Gdm?version=1.0'", and js/gdm/util.js, js/gdm/loginDialog.js,
# js/ui/unlockDialog.js and js/misc/systemActions.js each import it too - so
# without the typelib the shell aborts before it can draw anything:
#
#   Gjs-CRITICAL **: JS ERROR: Error: Requiring Gdm, version 1.0:
#     Typelib file for namespace 'Gdm', version '1.0' not found
#   gnome-session-binary: Unrecoverable failure in required component
#     org.gnome.Shell.desktop
#
# Nothing checks for it at build time - gnome-shell's meson.build does not
# mention gdm at all - so this only shows up at runtime, after mutter has
# already come up and announced itself.
#
# GDM has no option to build the library alone, so the daemon is built and
# installed with it. That is harmless here: no init script starts it, and this
# image logs in through agetty autologin instead (see the tty1 hook in
# sdk/board/common/rootfs-overlay/etc/profile.d/sway.sh).
#
################################################################################

GDM_VERSION = 47.0
GDM_SOURCE = gdm-$(GDM_VERSION).tar.xz
GDM_SITE = https://download.gnome.org/sources/gdm/47
GDM_LICENSE = GPL-2.0+
GDM_LICENSE_FILES = COPYING
# Installed to staging for the Gdm-1.0 typelib and libgdm itself.
GDM_INSTALL_STAGING = YES
# host-dconf for "dconf compile": data/dconf/meson.build builds the greeter's
# settings database with it at configure time, whether or not the greeter is
# ever used.
GDM_DEPENDENCIES = \
	host-pkgconf host-gobject-introspection host-dconf accountsservice \
	libgudev libglib2 udev elogind linux-pam gobject-introspection

# The daemon runs as its own user upstream. Nothing starts it here, but the
# install still refers to the account, and a package that invents files owned
# by a user the image does not have is worse than one that declares it.
GDM_USERS = gdm -1 gdm -1 * /var/lib/gdm - - GNOME Display Manager

# logind-provider defaults to systemd, and this image has elogind. The rest
# is turning off what a library-only consumer does not need: no journal to
# log to, no plymouth, no SELinux, no audit, no XDMCP, and no X11 session
# support on a Wayland-only image. systemdsystemunitdir/systemduserunitdir
# are set to "no" so meson does not go looking for systemd's pkg-config file
# to ask where units belong.
GDM_CONF_OPTS = \
	-Dlogind-provider=elogind \
	-Dsystemd-journal=false \
	-Dplymouth=disabled \
	-Dselinux=disabled \
	-Dlibaudit=disabled \
	-Dxdmcp=disabled \
	-Dx11-support=false \
	-Dwayland-support=true \
	-Dgdm-xsession=false \
	-Ddefault-pam-config=none \
	-Dsystemdsystemunitdir=no \
	-Dsystemduserunitdir=no

$(eval $(meson-package))
