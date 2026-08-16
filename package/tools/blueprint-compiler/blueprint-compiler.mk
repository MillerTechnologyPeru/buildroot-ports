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

$(eval $(host-meson-package))
