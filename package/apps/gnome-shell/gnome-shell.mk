################################################################################
#
# gnome-shell
#
################################################################################

GNOME_SHELL_VERSION = 47.10
GNOME_SHELL_SOURCE = gnome-shell-$(GNOME_SHELL_VERSION).tar.xz
GNOME_SHELL_SITE = https://download.gnome.org/sources/gnome-shell/47
GNOME_SHELL_LICENSE = GPL-2.0+
GNOME_SHELL_LICENSE_FILES = COPYING
# Installed to staging for its GSettings schemas. Buildroot compiles the
# schema cache at target-finalize from the staging copies only - libglib2.mk
# removes $(TARGET_DIR)/usr/share/glib-2.0/schemas/*.xml first, "we use
# staging ones to compile them" - so a schema that reaches the target alone
# is deleted and never lands in gschemas.compiled. That is fatal at runtime:
#
#   gnome-session-binary: GLib-GIO-ERROR: Settings schema
#     'org.gnome.SessionManager' is not installed - aborting...
GNOME_SHELL_INSTALL_STAGING = YES
# gnome-autoar for the extensions-tool subproject - the gnome-extensions CLI,
# on by default - which unpacks extension bundles with it:
#
#   subprojects/extensions-tool/meson.build:32:13: ERROR: Dependency
#   "gnome-autoar-0" not found
GNOME_SHELL_DEPENDENCIES = \
	host-pkgconf mutter gjs gnome-desktop gcr4 evolution-data-server \
	ibus polkit libgtk4 gsettings-desktop-schemas host-python3 \
	host-libglib2 network-manager libsecret gnome-autoar

# gjs_path is the 0001 patch's option: gjs is not run at build time, its
# path is written into the D-Bus service files for the target to launch,
# so it must be the target's - and find_program() cannot see that under a
# cross build.
GNOME_SHELL_CONF_OPTS = \
	-Dgjs_path=/usr/bin/gjs \
	-Dsystemd=false \
	-Dnetworkmanager=true \
	-Dcamera_monitor=false \
	-Dextensions_app=false \
	-Dgtk_doc=false \
	-Dman=false \
	-Dtests=false \
	-Dportal_helper=false

# gnome-shell links libmutter's private libraries - libmutter-clutter-15,
# libmutter-cogl-15, libmutter-mtk-15 - which mutter installs into
# /usr/lib/mutter-15 rather than a directory the loader searches:
#
#   /usr/bin/gnome-shell: error while loading shared libraries:
#     libmutter-clutter-15.so.0: cannot open shared object file
#   gnome-session-binary: Unrecoverable failure in required component
#     org.gnome.Shell.desktop
#
# Upstream covers this with an rpath. meson.build builds it from
# mutter_dep.get_variable('typelibdir'), and libmutter-15.pc derives that
# from libdir - which pkg-config does sysroot-prefix, unlike a prefix-derived
# variable - so what gets baked in is the build machine's staging path.
# support/scripts/fix-rpath then strips it at target-finalize, correctly,
# because it points outside the target. The entry is not rewritten to the
# target path, it is dropped, and nothing is left to find these libraries by.
#
# libmutter-15.so carries the same rpath and keeps it, but DT_RUNPATH applies
# only to the object that holds it, so it does not answer for the executable's
# own NEEDED entries.
#
# Set it after the install, to the path the target will use. Anything under
# these two directories that links a private libmutter is covered, so a new
# helper does not silently miss out.
GNOME_SHELL_MUTTER_LIBDIR = /usr/lib/mutter-15
GNOME_SHELL_DEPENDENCIES += host-patchelf

define GNOME_SHELL_RPATH_MUTTER_PRIVATE_LIBS
	find $(TARGET_DIR)/usr/bin/gnome-shell $(TARGET_DIR)/usr/lib/gnome-shell \
		-type f 2>/dev/null | while read -r f; do \
		$(TARGET_CROSS)readelf -d "$$f" 2>/dev/null | \
			grep -q 'NEEDED.*libmutter-' || continue; \
		cur=$$($(HOST_DIR)/bin/patchelf --print-rpath "$$f" 2>/dev/null); \
		case ":$$cur:" in \
			*":$(GNOME_SHELL_MUTTER_LIBDIR):"*) continue ;; \
		esac; \
		$(HOST_DIR)/bin/patchelf --set-rpath \
			"$(GNOME_SHELL_MUTTER_LIBDIR)$${cur:+:$$cur}" "$$f"; \
	done
endef
GNOME_SHELL_POST_INSTALL_TARGET_HOOKS += GNOME_SHELL_RPATH_MUTTER_PRIVATE_LIBS

$(eval $(meson-package))
