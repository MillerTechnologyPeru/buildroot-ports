################################################################################
#
# epiphany
#
################################################################################

EPIPHANY_VERSION = 47.7
EPIPHANY_SOURCE = epiphany-$(EPIPHANY_VERSION).tar.xz
EPIPHANY_SITE = https://download.gnome.org/sources/epiphany/47
EPIPHANY_LICENSE = GPL-3.0+
EPIPHANY_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
EPIPHANY_INSTALL_STAGING = YES
EPIPHANY_DEPENDENCIES = host-pkgconf host-desktop-file-utils libgtk4 libadwaita webkitgtk json-glib libsoup3 gcr4 libportal iso-codes gsettings-desktop-schemas nettle libarchive sqlite

# yelp is not in this image, so the translated help would be installed with
# nothing able to display it - and building it needs a host itstool, which
# Buildroot does not carry.
EPIPHANY_CONF_OPTS = -Dunit_tests=disabled -Ddeveloper_mode=false -Dhelp=false

$(eval $(meson-package))
