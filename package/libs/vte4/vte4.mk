################################################################################
#
# vte4
#
################################################################################

VTE4_VERSION = 0.78.6
VTE4_SOURCE = vte-$(VTE4_VERSION).tar.xz
VTE4_SITE = https://download.gnome.org/sources/vte/0.78
VTE4_LICENSE = LGPL-3.0+
VTE4_LICENSE_FILES = COPYING.LGPL3
VTE4_INSTALL_STAGING = YES
# gnutls is what encrypts the scrollback vte writes to its on-disk stream
# (see src/vtestream-file.h). Turning the option off would leave everything
# that scrolls out of a terminal - passwords and keys included - sitting in
# that file as plain text, so it is enabled rather than switched off to get
# past a missing dependency.
VTE4_DEPENDENCIES = host-pkgconf libgtk4 pcre2 lz4 gnutls

# _systemd only governs src/systemd.cc, which puts spawned children into
# systemd scopes. There is no systemd on this image, so this is not a feature
# being given up.
VTE4_CONF_OPTS = -Dgtk3=false -Dgtk4=true -Dvapi=false -Ddocs=false -D_systemd=false

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
VTE4_CONF_OPTS += -Dgir=true
VTE4_DEPENDENCIES += gobject-introspection
else
VTE4_CONF_OPTS += -Dgir=false
endif

$(eval $(meson-package))
