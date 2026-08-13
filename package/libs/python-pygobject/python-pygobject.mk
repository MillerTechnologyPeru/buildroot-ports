################################################################################
#
# python-pygobject
#
# Host only. libgweather runs gen_locations_variant.py during its build to
# turn Locations.xml into the GVariant blob it ships, and that script builds
# nested variants through gi.repository.GLib - meson refuses to configure
# without it:
#
#   meson.build:50:22: ERROR: python3 is missing modules: gi
#
# Nothing on the target imports gi, so there is no target variant here.
#
################################################################################

PYTHON_PYGOBJECT_VERSION = 3.50.0
PYTHON_PYGOBJECT_SOURCE = pygobject-$(PYTHON_PYGOBJECT_VERSION).tar.xz
PYTHON_PYGOBJECT_SITE = https://download.gnome.org/sources/pygobject/3.50
PYTHON_PYGOBJECT_LICENSE = LGPL-2.1+
PYTHON_PYGOBJECT_LICENSE_FILES = COPYING

HOST_PYTHON_PYGOBJECT_DEPENDENCIES = \
	host-python3 host-libglib2 host-gobject-introspection host-libffi

# pycairo would only add drawing bindings, which the generator scripts do not
# use, and tests are not worth building for a tool that runs once.
HOST_PYTHON_PYGOBJECT_CONF_OPTS = \
	-Dpycairo=disabled \
	-Dtests=false

$(eval $(host-meson-package))
