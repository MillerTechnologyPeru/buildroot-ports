################################################################################
#
# blueprint-compiler
#
################################################################################

BLUEPRINT_COMPILER_VERSION = 0.16.0
BLUEPRINT_COMPILER_SOURCE = blueprint-compiler-v$(BLUEPRINT_COMPILER_VERSION).tar.gz
BLUEPRINT_COMPILER_SITE = https://gitlab.gnome.org/jwestman/blueprint-compiler/-/archive/v$(BLUEPRINT_COMPILER_VERSION)
BLUEPRINT_COMPILER_LICENSE = LGPL-3.0+
BLUEPRINT_COMPILER_LICENSE_FILES = COPYING

# Host only: .blp files are compiled to GTK .ui at build time and nothing on
# the target ever calls this.
#
# PyGObject is needed even for batch-compile, which never looks a type up:
# main imports interactive_port, which imports decompiler, which imports gir,
# and that module imports gi at the top. So a compiler run that needs nothing
# from introspection still fails without it:
#
#   File ".../blueprintcompiler/gir.py", line 25, in <module>
#     import gi
#   ModuleNotFoundError: No module named 'gi'
#
# host-python-pygobject brings host-gobject-introspection with it, which is
# where the GIRepository typelib gir.py loads next comes from.
HOST_BLUEPRINT_COMPILER_DEPENDENCIES = host-python3 host-python-pygobject

# docs is a plain boolean rather than a feature, and building them wants
# sphinx-build, which is required:true inside that branch. It defaults to
# false; saying so keeps a future default flip from pulling Sphinx into the
# host build.
HOST_BLUEPRINT_COMPILER_CONF_OPTS = -Ddocs=false

# blueprint-compiler resolves every widget name against a GIR typelib. It runs
# on the build machine, so on its own it searches HOST_DIR/lib/girepository-1.0
# - where there is no Gtk, only the host's own GLib and GIRepository - and any
# .blp that names a Gtk widget fails:
#
#   error: Namespace Gtk was not imported
#     23 |      ShortcutsShortcut {
#        |      ^^^^^^^^^^^^^^^^^
#
# Gtk-4.0.typelib and Adw-1.typelib are the target's, in the staging sysroot.
# GI_TYPELIB_PATH prepends to the search path rather than replacing it, so the
# host typelibs the compiler also needs stay reachable, and reading a typelib
# is metadata only - nothing dlopen()s the target libraries it describes.
#
# Rather than have every package with a .blp set that variable in its own
# NINJA_ENV, the installed entrypoint is wrapped to set it: it is a build
# tool for target packages, and the target typelibs are the only ones it
# will ever be asked about here.
define HOST_BLUEPRINT_COMPILER_WRAP_FOR_TARGET_TYPELIBS
	mv $(HOST_DIR)/bin/blueprint-compiler $(HOST_DIR)/bin/blueprint-compiler.real
	printf '%s\n' \
		'#!/bin/sh' \
		'# See blueprint-compiler.mk: point the compiler at the target typelibs.' \
		'GI_TYPELIB_PATH="$(STAGING_DIR)/usr/lib/girepository-1.0$${GI_TYPELIB_PATH:+:$$GI_TYPELIB_PATH}"' \
		'export GI_TYPELIB_PATH' \
		'exec "$$(dirname "$$0")/blueprint-compiler.real" "$$@"' \
		> $(HOST_DIR)/bin/blueprint-compiler
	chmod 0755 $(HOST_DIR)/bin/blueprint-compiler
endef
HOST_BLUEPRINT_COMPILER_POST_INSTALL_HOOKS += HOST_BLUEPRINT_COMPILER_WRAP_FOR_TARGET_TYPELIBS

$(eval $(host-meson-package))
