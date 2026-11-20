################################################################################
#
# swift-sdl
#
################################################################################

# Upstream has no releases; this is master.
SWIFT_SDL_VERSION = 58752513dc459f5be5dc33a3b0e1b0423c67ba59
SWIFT_SDL_SITE = $(call github,PureSwift,SDL,$(SWIFT_SDL_VERSION))
SWIFT_SDL_LICENSE = MIT
SWIFT_SDL_LICENSE_FILES = LICENSE
SWIFT_SDL_INSTALL_STAGING = YES
# Nothing to run: a module map and a header, for the compiler.
SWIFT_SDL_INSTALL_TARGET = NO
SWIFT_SDL_DEPENDENCIES = swift sdl3

# Clang finds a C module as <resource dir>/<name>/module.modulemap. The
# module map names SDL3 as the library to link, so importing it is enough.
define SWIFT_SDL_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 -t $(STAGING_DIR)/usr/lib/swift/CSDL3 \
		$(@D)/Sources/CSDL3/module.modulemap \
		$(@D)/Sources/CSDL3/shim.h
endef

$(eval $(generic-package))
