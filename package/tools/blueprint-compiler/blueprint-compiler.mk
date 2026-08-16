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
HOST_BLUEPRINT_COMPILER_DEPENDENCIES = host-python3

# docs is a plain boolean rather than a feature, and building them wants
# sphinx-build, which is required:true inside that branch. It defaults to
# false; saying so keeps a future default flip from pulling Sphinx into the
# host build.
HOST_BLUEPRINT_COMPILER_CONF_OPTS = -Ddocs=false

$(eval $(host-meson-package))
