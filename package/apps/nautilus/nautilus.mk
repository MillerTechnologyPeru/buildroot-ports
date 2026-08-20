################################################################################
#
# nautilus
#
################################################################################

NAUTILUS_VERSION = 47.6
NAUTILUS_SOURCE = nautilus-$(NAUTILUS_VERSION).tar.xz
NAUTILUS_SITE = https://download.gnome.org/sources/nautilus/47
NAUTILUS_LICENSE = GPL-3.0+
NAUTILUS_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
NAUTILUS_INSTALL_STAGING = YES
NAUTILUS_DEPENDENCIES = host-pkgconf host-desktop-file-utils libgtk4 libadwaita gnome-autoar gexiv2 tinysparql gnome-desktop gsettings-desktop-schemas

# cloudproviders is the sidebar's cloud-account integration - Nextcloud,
# Dropbox and the like announcing themselves over D-Bus. It defaults on and
# wants libcloudproviders:
#
#   meson.build:132:19: ERROR: Dependency "cloudproviders" not found
#
# No such provider is in the image, so there is nothing for it to show.
NAUTILUS_CONF_OPTS = -Ddocs=false -Dtests=none -Dextensions=false -Dselinux=false -Dpackagekit=false -Dcloudproviders=false

$(eval $(meson-package))
