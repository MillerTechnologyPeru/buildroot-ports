################################################################################
#
# lzfse
#
################################################################################

# The tag carries the package name, so the version is "lzfse-1.0" rather than
# "1.0" and the tarball comes out as lzfse-lzfse-1.0.tar.gz. 1.0 is the only
# release; upstream has been quiet since, and this is the revision Apple's own
# consumers build against.
LZFSE_VERSION = lzfse-1.0
LZFSE_SITE = $(call github,lzfse,lzfse,$(LZFSE_VERSION))
LZFSE_LICENSE = BSD-3-Clause
LZFSE_LICENSE_FILES = LICENSE
LZFSE_INSTALL_STAGING = YES

# cmake_minimum_required(VERSION 2.8.6), which 4.x refuses outright:
#
#   Compatibility with CMake < 3.5 has been removed from CMake.
#
# Nothing in the file depends on the old behaviour - it is a single library,
# an executable and an install() - so raising the floor is enough.
#
# The tests are round-trip runs of the freshly built CLI over the source tree,
# which a cross build cannot execute anyway.
LZFSE_CONF_OPTS = \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DLZFSE_DISABLE_TESTS=ON

$(eval $(cmake-package))
