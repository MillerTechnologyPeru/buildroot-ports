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
# The daemon is now used, not merely tolerated. S90gdm starts it on images
# that ship it, and the GNOME frontend no longer autologins: the greeter
# authenticates the user, which is also what makes screen locking work -
# gnome-shell disables locking outright when there is no display manager.
#
# PAM comes from the overlay rather than from GDM's own profiles. Every
# pam-* set upstream ships includes system-auth and system-session, which
# this image does not have.
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

# The daemon runs as its own user upstream, and the account owns files the
# install refers to, so the package declares it rather than inventing files
# owned by a user the image does not have.
#
# The home is the state directory on the data partition, not /var/lib/gdm.
# An image with a read-only root points /var/lib/gdm at /data/lib/gdm with an
# absolute symlink, and mkusers creates a user's home with "mkdir -p" against
# the target tree: an absolute symlink resolves outside that tree, so it would
# either escape into the build host or, when the target does not exist there,
# stop the image build with
#
#   mkdir: cannot create directory '.../target//var/lib/gdm': File exists
#
# Naming the real path keeps that inside the target tree, and gives the
# account a home it can actually write to once the data partition is mounted.
#
# The account is in video and input because the greeter is a Wayland
# compositor. logind hands mutter the KMS device over a file descriptor, so
# mode setting works without either group - but Mesa opens /dev/dri/card0 by
# path for itself, and that node is root:video:
#
#   libEGL warning: failed to open /dev/dri/card0: Permission denied
#   libEGL warning: egl: failed to create dri2 screen
#
# The compositor then runs with no GL and paints nothing: a greeter that is
# up, holds the display, and shows a black screen. The session user account
# is in these groups already, which is why a logged-in session renders and
# the greeter does not. Distributions that leave the account bare rely on
# udev's uaccess rules granting the active session an ACL on the device;
# naming the groups does not depend on that being wired up.
GDM_USERS = gdm -1 gdm -1 * /data/lib/gdm - video,input GNOME Display Manager

# logind-provider defaults to systemd, and this image has elogind. The rest
# is turning off what a library-only consumer does not need: no journal to
# log to, no plymouth, no SELinux, no audit, no XDMCP, and no X11 session
# support on a Wayland-only image. systemdsystemunitdir/systemduserunitdir
# are set to "no" so meson does not go looking for systemd's pkg-config file
# to ask where units belong.
#
# initial-vt is left at upstream's default of 1, which is what Alpine and
# postmarketOS ship - both run this daemon under OpenRC with elogind and
# carry no patch for it. The greeter was put on VT 7 here to stay clear of
# the console getty, but a greeter is only handed the DRM device once its
# session is the active one on the seat, and the active VT is the one the
# getty holds. S90gdm stops that getty instead, which is the arrangement
# every distribution shipping a display manager already uses.
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
	-Ddocs=false \
	-Dsystemdsystemunitdir=no \
	-Dsystemduserunitdir=no

$(eval $(meson-package))
