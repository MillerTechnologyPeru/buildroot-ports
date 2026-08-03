################################################################################
#
# glslang
#
################################################################################

GLSLANG_VERSION = 16.4.0
GLSLANG_SITE = $(call github,KhronosGroup,glslang,$(GLSLANG_VERSION))
GLSLANG_LICENSE = BSD-3-Clause, BSD-2-Clause, MIT, Apache-2.0
GLSLANG_LICENSE_FILES = LICENSE.txt
GLSLANG_INSTALL_STAGING = YES
GLSLANG_DEPENDENCIES = host-pkgconf spirv-tools spirv-headers

GLSLANG_CONF_OPTS = \
	-DBUILD_SHARED_LIBS=ON \
	-DENABLE_OPT=ON \
	-DALLOW_EXTERNAL_SPIRV_TOOLS=ON \
	-DGLSLANG_TESTS=OFF \
	-DBUILD_EXTERNAL=OFF

# The host variant exists for the glslangValidator binary, not the library:
# mesa3d-demos compiles its Vulkan demos' shaders at build time and looks the
# tool up as a host program, so a target-only glslang leaves it configuring
# against nothing and stopping at
#
#   ERROR: Program 'glslangValidator' not found or not executable
#
# Static, and without the SPIR-V optimiser: nothing links against the host
# library, and the tool only has to emit SPIR-V for the demos, so this keeps
# the build to what is actually consumed.
HOST_GLSLANG_DEPENDENCIES = host-pkgconf host-spirv-tools host-spirv-headers

HOST_GLSLANG_CONF_OPTS = \
	-DBUILD_SHARED_LIBS=OFF \
	-DENABLE_OPT=OFF \
	-DGLSLANG_TESTS=OFF \
	-DBUILD_EXTERNAL=OFF

$(eval $(cmake-package))
$(eval $(host-cmake-package))
