# Packages live at package/<category>/<name>/<name>.mk, with a second level
# for the ones grouped under a shared engine directory (package/games/xash3d).
include $(sort $(wildcard $(BR2_EXTERNAL_SWIFTLINUXPORTS_PATH)/package/*/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_SWIFTLINUXPORTS_PATH)/package/*/*/*/*.mk))

# Buildroot's libical hard-codes -DICAL_GLIB=OFF, and there is no kconfig
# symbol to turn it back on, so evolution-data-server cannot configure:
#
#   The following required packages were not found:
#    - libical-glib>=3.0.7
#
# and without evolution-data-server there is no calendar or address book for
# gnome-calendar and Settings' online accounts.
#
# This file is included after every package has been defined (see the comment
# by BR2_EXTERNAL_MKS in Buildroot's Makefile), and both the configure options
# and the dependency list are expanded when the rules run rather than when
# they are declared, so appending here reaches libical without carrying a
# patched copy of it or a fork of the package.
ifeq ($(BR2_PACKAGE_LIBICAL)$(BR2_PACKAGE_GOBJECT_INTROSPECTION),yy)
LIBICAL_CONF_OPTS += -DICAL_GLIB=ON -DGOBJECT_INTROSPECTION=ON

# libical-glib generates its sources by running ical-glib-src-generator over
# the api/*.xml files, so a cross build needs one that runs here. libical
# expects that as a CMake export from a native build, not as a path to a
# binary - src/libical-glib/CMakeLists.txt includes the file and then calls
# the imported native-ical-glib-src-generator target - and without it stops
# at ICAL_GLIB_SRC_GENERATOR-NOTFOUND. That requirement is why Buildroot's
# libical hard-codes ICAL_GLIB=OFF.
#
# So declare a host build of the same package. inner-cmake-package is what
# cmake-package and host-cmake-package are themselves defined in terms of;
# calling it directly is the only way to add a host variant to a package
# whose own .mk does not, short of carrying a patched copy of it.
HOST_LIBICAL_DEPENDENCIES = host-perl host-libglib2 host-libxml2
HOST_LIBICAL_CONF_OPTS = \
	-DICAL_GLIB=ON \
	-DGOBJECT_INTROSPECTION=OFF \
	-DICAL_GLIB_VAPI=OFF \
	-DICAL_BUILD_DOCS=OFF \
	-DLIBICAL_BUILD_EXAMPLES=OFF \
	-DLIBICAL_BUILD_TESTING=OFF \
	-DWITH_CXX_BINDINGS=OFF \
	-DSHARED_ONLY=ON \
	-DUSE_BUILTIN_TZDATA=OFF
$(eval $(call inner-cmake-package,host-libical,HOST_LIBICAL,LIBICAL,host))

LIBICAL_CONF_OPTS += \
	-DIMPORT_ICAL_GLIB_SRC_GENERATOR=$(HOST_DIR)/lib/cmake/LibIcal/IcalGlibSrcGenerator.cmake

# Appending to LIBICAL_DEPENDENCIES would not order anything: pkg-generic.mk
# expands the dependency list as it reads the rules, which has already
# happened by the time this file is included, and Buildroot does not use
# .SECONDEXPANSION. State the ordering as a rule instead - prerequisites on an
# existing target are merged whenever they are added.
#
# It has to hang off the stamp, not the libical-configure convenience target:
# a plain "make" reaches the stamps through the package's own chain and never
# names that target, so a prerequisite there is simply never consulted.
$(LIBICAL_DIR)/.stamp_configured: | host-libical libglib2 gobject-introspection
endif
