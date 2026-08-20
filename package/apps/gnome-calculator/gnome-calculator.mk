################################################################################
#
# gnome-calculator
#
################################################################################

GNOME_CALCULATOR_VERSION = 47.3
GNOME_CALCULATOR_SOURCE = gnome-calculator-$(GNOME_CALCULATOR_VERSION).tar.xz
GNOME_CALCULATOR_SITE = https://download.gnome.org/sources/gnome-calculator/47
GNOME_CALCULATOR_LICENSE = GPL-3.0+
GNOME_CALCULATOR_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
GNOME_CALCULATOR_INSTALL_STAGING = YES
GNOME_CALCULATOR_DEPENDENCIES = host-pkgconf host-vala libgtk4 libadwaita gtksourceview5 libsoup3 libgee mpfr gmp mpc

# See epiphany: no yelp in the image, no host itstool to build the help.
GNOME_CALCULATOR_CONF_OPTS = -Dhelp=false

$(eval $(meson-package))
