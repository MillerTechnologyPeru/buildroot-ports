################################################################################
#
# gnome-online-accounts
#
################################################################################

GNOME_ONLINE_ACCOUNTS_VERSION = 3.52.10
GNOME_ONLINE_ACCOUNTS_SOURCE = gnome-online-accounts-$(GNOME_ONLINE_ACCOUNTS_VERSION).tar.xz
GNOME_ONLINE_ACCOUNTS_SITE = https://download.gnome.org/sources/gnome-online-accounts/3.52
GNOME_ONLINE_ACCOUNTS_LICENSE = LGPL-2.0+
GNOME_ONLINE_ACCOUNTS_LICENSE_FILES = COPYING
GNOME_ONLINE_ACCOUNTS_INSTALL_STAGING = YES
GNOME_ONLINE_ACCOUNTS_DEPENDENCIES = host-pkgconf libgtk4 libadwaita webkitgtk librest json-glib libsecret gcr4

GNOME_ONLINE_ACCOUNTS_CONF_OPTS = -Dgoabackend=true -Ddocumentation=false -Dman=false -Dvapi=false

# The Kerberos provider defaults on and, with goabackend, wants krb5 and
# libkeyutils at configure time:
#
#   meson.build:190:20: ERROR: Dependency "libkeyutils" not found
#
# It was finding krb5 only because something else had put it in the
# sysroot, and never finding keyutils. Make it follow BR2_PACKAGE_LIBKRB5
# and name both, so the provider is a decision rather than an accident of
# build order.
ifeq ($(BR2_PACKAGE_LIBKRB5),y)
GNOME_ONLINE_ACCOUNTS_CONF_OPTS += -Dkerberos=true
GNOME_ONLINE_ACCOUNTS_DEPENDENCIES += libkrb5 keyutils
else
GNOME_ONLINE_ACCOUNTS_CONF_OPTS += -Dkerberos=false
endif

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
GNOME_ONLINE_ACCOUNTS_CONF_OPTS += -Dintrospection=true
GNOME_ONLINE_ACCOUNTS_DEPENDENCIES += gobject-introspection
else
GNOME_ONLINE_ACCOUNTS_CONF_OPTS += -Dintrospection=false
endif

$(eval $(meson-package))
