################################################################################
#
# xar
#
################################################################################

XAR_VERSION = 1.6.1
XAR_SITE = $(call github,mackyle,xar,xar-$(XAR_VERSION))
# The repository's real content (XarKit, XarCMPlugIn, xarmdimport, xarql) is
# Apple/Cocoa-only; the portable library and CLI tool are the "xar" subdir.
XAR_SUBDIR = xar
XAR_LICENSE = BSD-3-Clause
XAR_LICENSE_FILES = xar/LICENSE
XAR_DEPENDENCIES = host-autoconf libxml2 openssl zlib
XAR_INSTALL_STAGING = YES

# ./configure is not checked in, only configure.ac, and upstream's own
# autogen.sh runs plain autoconf - never automake or autoheader. There is no
# Makefile.am (Makefile.in is hand-maintained) and include/config.h.in is
# checked in rather than generated, which turns out to be load-bearing:
# XAR_AUTORECONF's full "autoreconf -f -i" fails outright, because autoheader
# chokes on several AC_DEFINE names that are never given a literal template
# in configure.ac:
#
#   autoheader: warning: missing template: HAVE_ASPRINTF
#   autoreconf: error: /usr/bin/autoheader failed with exit status: 1
#
# Running plain autoconf, as upstream does, regenerates configure from the
# (patched) configure.ac without ever invoking autoheader.
define XAR_RUN_AUTOCONF
	cd $(@D) && autoconf
endef
XAR_PRE_CONFIGURE_HOOKS += XAR_RUN_AUTOCONF

# 0001 fixes the libcrypto probe against OpenSSL 1.1+/3.x - see the patch
# for why. xml2-config is not on PATH in a cross build, so point configure
# at the staged copy Buildroot's CONFIG_SCRIPTS fixup installs.
XAR_CONF_OPTS = --with-xml2-config=$(STAGING_DIR)/usr/bin/xml2-config

$(eval $(autotools-package))
