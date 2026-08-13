################################################################################
#
# typescript
#
# Host only: the tsc compiler, which decibels and the other TypeScript GNOME
# applications run over their sources at build time. Nothing on the target
# needs it - what ships is the JavaScript tsc produces, executed by gjs.
#
################################################################################

TYPESCRIPT_VERSION = 5.8.3
TYPESCRIPT_SOURCE = typescript-$(TYPESCRIPT_VERSION).tgz
TYPESCRIPT_SITE = https://registry.npmjs.org/typescript/-/
TYPESCRIPT_LICENSE = Apache-2.0
TYPESCRIPT_LICENSE_FILES = LICENSE.txt

HOST_TYPESCRIPT_DEPENDENCIES = host-nodejs

# The npm tarball holds everything under package/, so strip that rather than
# the version directory a release tarball would have.
TYPESCRIPT_STRIP_COMPONENTS = 1

# tsc is JavaScript: there is nothing to compile, only to place. bin/tsc is a
# two-line shim that requires ../lib/tsc.js, so the layout has to be kept and
# the entry point symlinked into host/bin rather than copied out of it.
define HOST_TYPESCRIPT_INSTALL_CMDS
	rm -rf $(HOST_DIR)/lib/node_modules/typescript
	$(INSTALL) -d $(HOST_DIR)/lib/node_modules/typescript
	cp -a $(@D)/bin $(@D)/lib $(HOST_DIR)/lib/node_modules/typescript/
	$(INSTALL) -d $(HOST_DIR)/bin
	ln -sf ../lib/node_modules/typescript/bin/tsc $(HOST_DIR)/bin/tsc
	ln -sf ../lib/node_modules/typescript/bin/tsserver $(HOST_DIR)/bin/tsserver
endef

$(eval $(host-generic-package))
