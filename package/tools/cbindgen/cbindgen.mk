################################################################################
#
# cbindgen
#
################################################################################

CBINDGEN_VERSION = 0.29.4
CBINDGEN_SITE = $(call github,mozilla,cbindgen,$(CBINDGEN_VERSION))
CBINDGEN_LICENSE = MPL-2.0
CBINDGEN_LICENSE_FILES = LICENSE

# Host only. It generates C headers from Rust sources at build time and
# nothing runs it on the target, so there is no target variant - mozjs128 is
# what needs it (see package/libs/mozjs128), and its configure refuses to
# proceed without one at least 0.26.0.
$(eval $(host-cargo-package))
