################################################################################
#
# tinysparql
#
################################################################################

TINYSPARQL_VERSION = 3.8.2
TINYSPARQL_SOURCE = tinysparql-$(TINYSPARQL_VERSION).tar.xz
TINYSPARQL_SITE = https://download.gnome.org/sources/tinysparql/3.8
TINYSPARQL_LICENSE = LGPL-2.1+
TINYSPARQL_LICENSE_FILES = COPYING.LGPL
TINYSPARQL_INSTALL_STAGING = YES
TINYSPARQL_DEPENDENCIES = host-pkgconf json-glib libsoup3 sqlite icu

# systemd_user_services defaults on and, absent systemd, needs a directory
# named or the option off:
#
#   meson.build:293:6: ERROR: systemd user services were enabled, but
#   systemd was not found
#
# vapi defaults enabled and would run vapigen, which the host tree does not
# have; nothing here consumes Vala bindings.
TINYSPARQL_CONF_OPTS = -Dman=false -Ddocs=false -Dtests=false \
	-Dsystemd_user_services=false -Dvapi=disabled

# Two of configure's checks compile a probe and run it, which a cross build
# cannot, so both take their answer from the cross file's [properties]:
#
#   sqlite3_has_fts5 - upstream's own escape hatch. It wants the string
#   'true' or 'false', compared as such. sqlite is built with FTS5 here
#   (BR2_PACKAGE_SQLITE_ENABLE_FTS5, selected from Config.in), and
#   tinysparql refuses to build against one without it, so this is only
#   ever true.
#
#   strftime_year_modifier - the 0001 patch's addition, on the same model.
#   The probe finds the strftime conversion that prints a four-digit year
#   for years before 1000; on glibc, which every arch here uses, that is
#   %4Y (confirmed by running the probe on glibc 2.41).
TINYSPARQL_MESON_EXTRA_PROPERTIES = \
	sqlite3_has_fts5='true' \
	strftime_year_modifier='%4Y'

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
TINYSPARQL_CONF_OPTS += -Dintrospection=enabled
TINYSPARQL_DEPENDENCIES += gobject-introspection
else
TINYSPARQL_CONF_OPTS += -Dintrospection=disabled
endif

$(eval $(meson-package))
