################################################################################
#
# elogind
#
# The logind piece of the GNOME-on-OpenRC plan (see
# sdk/defconfig/frontend/gnome.config): mutter and gnome-shell require an
# org.freedesktop.login1 provider, and elogind is that provider on every
# systemd-free distro that ships GNOME. Versions track systemd's numbering.
#
# cgroup controller: elogind can manage its own cgroup hierarchy; the
# "unified" default matches the cgroupfs-v2 mount this image already does
# for podman.
#
################################################################################

ELOGIND_VERSION = 257.16
ELOGIND_SITE = $(call github,elogind,elogind,v$(ELOGIND_VERSION))
ELOGIND_LICENSE = LGPL-2.1+ (library), GPL-2.0+ (daemon)
ELOGIND_LICENSE_FILES = LICENSES/LGPL-2.1-or-later.txt LICENSES/GPL-2.0-or-later.txt
ELOGIND_INSTALL_STAGING = YES
# host-python-jinja2 renders the .in templates - libelogind.pc, logind.conf and
# the rest - through tools/meson-render-jinja2.py during the build:
#
#   File ".../tools/meson-render-jinja2.py", line 10, in <module>
#     import jinja2
#   ModuleNotFoundError: No module named 'jinja2'
#
# It is a build-time generator only; nothing on the target imports jinja2.
ELOGIND_DEPENDENCIES = host-pkgconf host-gperf host-python-jinja2 libcap udev dbus

ELOGIND_CONF_OPTS = \
	-Dmode=release \
	-Dcgroup-controller=elogind \
	-Ddefault-hierarchy=unified \
	-Dman=disabled \
	-Dhtml=disabled \
	-Dselinux=disabled \
	-Dacl=disabled \
	-Dsmack=false \
	-Dutmp=false \
	-Dbashcompletiondir=no \
	-Dzshcompletiondir=no

# Session registration happens through pam_elogind: without PAM in the
# login path, logind knows no sessions and a compositor cannot attach.
# The GNOME frontend fragment enables linux-pam; elogind follows it.
ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
# /usr/lib/security, not /lib/security: linux-pam does not override its
# securedir, so with --prefix=/usr its modules install there, and that is the
# only directory it searches for a module named without a path. Installing
# beside it is not optional - /lib is a real directory here, not a symlink
# into /usr, because BR2_ROOTFS_MERGED_USR is off.
#
# The session line in /etc/pam.d/login is "optional", so getting this wrong
# does not fail the login; it logs and carries on with the session never
# registered:
#
#   login: PAM unable to dlopen(/usr/lib/security/pam_elogind.so):
#     cannot open shared object file: No such file or directory
#   login: PAM adding faulty module: /usr/lib/security/pam_elogind.so
#
# which surfaces much later as the compositor refusing to start:
#
#   Failed to setup: Could not get session ID: User 1000 has no sessions
ELOGIND_CONF_OPTS += -Dpam=enabled -Dpamlibdir=/usr/lib/security
ELOGIND_DEPENDENCIES += linux-pam
else
ELOGIND_CONF_OPTS += -Dpam=disabled
endif

# elogind is built as a drop-in for the parts of libsystemd it implements -
# sd-login, sd-daemon, sd-bus, and journal stubs - and installs its headers
# under include/elogind/systemd/ so that #include <systemd/sd-login.h>
# resolves through its own Cflags. The one thing it does not do is answer to
# libsystemd's pkg-config name, so a package that asks for that stops dead:
#
#   meson.build:124:17: ERROR: Dependency "libsystemd" not found
#
# gnome-session 47 takes it as required with no option, and every sd_*
# symbol it calls (sixteen of them, journal included) is exported by this
# libelogind. Rather than teach each such package a new name, install a
# libsystemd.pc beside libelogind.pc that resolves to the same library. It
# is only written to staging: nothing on the target dlopen()s a .pc file.
define ELOGIND_INSTALL_LIBSYSTEMD_PC
	sed -e 's/^Name: elogind$$/Name: libsystemd/' \
	    -e 's/^Description: .*/Description: elogind, answering for libsystemd/' \
	    $(STAGING_DIR)/usr/lib/pkgconfig/libelogind.pc \
	    > $(STAGING_DIR)/usr/lib/pkgconfig/libsystemd.pc
endef
ELOGIND_POST_INSTALL_STAGING_HOOKS += ELOGIND_INSTALL_LIBSYSTEMD_PC

$(eval $(meson-package))
