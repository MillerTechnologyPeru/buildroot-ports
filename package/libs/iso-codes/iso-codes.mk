################################################################################
#
# iso-codes
#
################################################################################
ISO_CODES_VERSION = v4.17.0
ISO_CODES_SITE = https://salsa.debian.org/iso-codes-team/iso-codes.git
ISO_CODES_SITE_METHOD = git
ISO_CODES_LICENSE = LGPL-2.1+
ISO_CODES_LICENSE_FILES = COPYING
ISO_CODES_INSTALL_STAGING = YES
ISO_CODES_DEPENDENCIES = \
	host-pkgconf

$(eval $(autotools-package))
