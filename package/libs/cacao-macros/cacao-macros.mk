################################################################################
#
# cacao-macros
#
################################################################################

# Cacao's compiler plugin, which implements the @Entry macro. A plugin runs
# inside the compiler, so this is a host package: it is built for the build
# machine, from the same source as the cacao package. Keep the version in
# step with cacao's.
CACAO_MACROS_VERSION = b1e5882a0ac583ad165cee0c2d01d4a0db94bb7e
CACAO_MACROS_SITE = $(call github,PureSwift,Cacao,$(CACAO_MACROS_VERSION))
CACAO_MACROS_SOURCE = cacao-$(CACAO_MACROS_VERSION).tar.gz
CACAO_MACROS_DL_SUBDIR = cacao
CACAO_MACROS_LICENSE = MIT
CACAO_MACROS_LICENSE_FILES = LICENSE
HOST_CACAO_MACROS_DEPENDENCIES = host-swift

# The host toolchain's swift-syntax, which it ships for building macros, and
# the directory beside it where the compiler looks for plugins without
# being told.
HOST_CACAO_MACROS_SWIFT_HOST_DIR = $(SWIFT_NATIVE_PATH)/../lib/swift/host

# One source file over swift-syntax, compiled directly: upstream's CMake
# build of the plugin wants a swift-syntax checkout, which the toolchain's
# copy makes unnecessary.
#
# CACAO_MACROS_LIBRARY leaves out the entry point a plugin executable has;
# the compiler loads the library and finds the macro by name. The run path
# is to the swift-syntax libraries, one directory up from the plugins.
define HOST_CACAO_MACROS_BUILD_CMDS
	mkdir -p $(@D)/build
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_NATIVE_PATH)/swiftc \
		-emit-library -parse-as-library -swift-version 6 -O \
		-D CACAO_MACROS_LIBRARY \
		-module-name CacaoMacros \
		-I $(HOST_CACAO_MACROS_SWIFT_HOST_DIR) \
		-L $(HOST_CACAO_MACROS_SWIFT_HOST_DIR) \
		-lSwiftSyntax -lSwiftSyntaxMacros -lSwiftDiagnostics \
		-Xlinker -rpath -Xlinker '$$ORIGIN/..' \
		-o $(@D)/build/libCacaoMacros.so \
		$(@D)/Sources/CacaoMacros/EntryMacro.swift
endef

define HOST_CACAO_MACROS_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/build/libCacaoMacros.so \
		$(HOST_CACAO_MACROS_SWIFT_HOST_DIR)/plugins/libCacaoMacros.so
endef

$(eval $(host-generic-package))
