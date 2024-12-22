################################################################################
#
# libgtk4
#
################################################################################

LIBGTK4_VERSION_MAJOR = 4.9
LIBGTK4_VERSION = $(LIBGTK4_VERSION_MAJOR).4
LIBGTK4_SOURCE = gtk-$(LIBGTK4_VERSION).tar.xz
LIBGTK4_SITE = https://download.gnome.org/sources/gtk/$(LIBGTK4_VERSION_MAJOR)
LIBGTK4_LICENSE = LGPL-2.0+
LIBGTK4_LICENSE_FILES = COPYING
LIBGTK4_CPE_ID_VENDOR = gnome
LIBGTK4_CPE_ID_PRODUCT = gtk
LIBGTK4_INSTALL_STAGING = YES

LIBGTK4_DEPENDENCIES = host-pkgconf \
	libglib2 \
	cairo \
	pango \
	gdk-pixbuf \
	libepoxy \
	harfbuzz \
	libpng \
	libjpeg \
	sqlite \
	graphene \
	gstreamer1 \
	gst1-plugins-base \
	gst1-plugins-bad \

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
LIBGTK4_CONF_OPTS += -Dintrospection=enabled
LIBGTK4_DEPENDENCIES += gobject-introspection
else
LIBGTK4_CONF_OPTS += -Dintrospection=disabled
endif

ifeq ($(BR2_PACKAGE_WAYLAND),y)
LIBGTK4_DEPENDENCIES += wayland wayland-protocols libxkbcommon
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXCURSOR),y)
LIBGTK4_DEPENDENCIES += xlib_libXcursor
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXFIXES),y)
LIBGTK4_DEPENDENCIES += xlib_libXfixes
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXCOMPOSITE),y)
LIBGTK4_DEPENDENCIES += xlib_libXcomposite
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXDAMAGE),y)
LIBGTK4_DEPENDENCIES += xlib_libXdamage
endif

ifeq ($(BR2_PACKAGE_CUPS),y)
LIBGTK4_DEPENDENCIES += cups
endif

ifeq ($(BR2_PACKAGE_LIBGTK4_DEMO),y)
LIBGTK4_CONF_OPTS += -Ddemos=true
LIBGTK4_DEPENDENCIES += hicolor-icon-theme shared-mime-info
else
LIBGTK4_CONF_OPTS += -Ddemos=false
endif

define LIBGTK4_COMPILE_GLIB_SCHEMAS
	$(HOST_DIR)/bin/glib-compile-schemas \
		$(TARGET_DIR)/usr/share/glib-2.0/schemas
endef

LIBGTK4_POST_INSTALL_TARGET_HOOKS += LIBGTK4_COMPILE_GLIB_SCHEMAS

# gtk+ >= 3.10 can build a native version of gtk-update-icon-cache if
# --enable-gtk2-dependency=no is set when invoking './configure'.
#
# Unfortunately, if the target toolchain is based on uClibc, the macro
# AM_GLIB_GNU_GETTEXT will detect the libintl built for the target and
# will add '-lintl' to the default list of libraries for the linker (used
# for both native and target builds).
#
# But no native version of libintl is available (the functions are
# provided by glibc). So gtk-update-icon-cache will not build.
#
# As a workaround, we build gtk-update-icon-cache on our own, set
# --enable-gtk2-dependency=yes and force './configure' to use our version.

HOST_LIBGTK4_DEPENDENCIES = host-pkgconf 

HOST_LIBGTK4_CFLAGS = \
	`$(HOST_MAKE_ENV) $(PKG_CONFIG_HOST_BINARY) --cflags --libs gdk-pixbuf-2.0` \
	`$(HOST_MAKE_ENV) $(PKG_CONFIG_HOST_BINARY) --cflags --libs gio-2.0`

define HOST_LIBGTK4_CONFIGURE_CMDS
	echo "#define GETTEXT_PACKAGE \"gtk30\"" >> $(@D)/gtk/config.h
	echo "#define HAVE_UNISTD_H 1" >> $(@D)/gtk/config.h
	echo "#define HAVE_FTW_H 1" >> $(@D)/gtk/config.h
endef

define HOST_LIBGTK4_BUILD_CMDS
	$(HOSTCC) $(HOST_CFLAGS) $(HOST_LDFLAGS) \
		$(@D)/gtk/updateiconcache.c \
		$(HOST_LIBGTK4_CFLAGS) \
		-o $(@D)/gtk/gtk-update-icon-cache
	$(HOSTCC) $(HOST_CFLAGS) $(HOST_LDFLAGS) \
		$(@D)/gtk/encodesymbolic.c \
		$(HOST_LIBGTK4_CFLAGS) \
		-o $(@D)/gtk/gtk-encode-symbolic-svg
endef

define HOST_LIBGTK4_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/gtk/gtk-update-icon-cache \
		$(HOST_DIR)/bin/gtk-update-icon-cache
	$(INSTALL) -D -m 0755 $(@D)/gtk/gtk-encode-symbolic-svg \
		$(HOST_DIR)/bin/gtk-encode-symbolic-svg
endef

# Create icon-theme.cache for each of the icon directories/themes
# It's not strictly necessary but speeds up lookups
define LIBGTK4_UPDATE_ICON_CACHE
	[ ! -d $(TARGET_DIR)/usr/share/icons ] || \
		find $(TARGET_DIR)/usr/share/icons -maxdepth 1 -mindepth 1 -type d \
			-exec $(HOST_DIR)/bin/gtk-update-icon-cache {} \;
endef
LIBGTK4_TARGET_FINALIZE_HOOKS += LIBGTK4_UPDATE_ICON_CACHE

$(eval $(meson-package))
$(eval $(host-generic-package))
