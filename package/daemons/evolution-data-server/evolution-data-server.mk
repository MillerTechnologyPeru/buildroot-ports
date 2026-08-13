################################################################################
#
# evolution-data-server
#
# Needs libical built with its GLib bindings (ICAL_GLIB) - see the note in
# the GNOME frontend fragment.
#
################################################################################

EVOLUTION_DATA_SERVER_VERSION = 3.54.3
EVOLUTION_DATA_SERVER_SOURCE = evolution-data-server-$(EVOLUTION_DATA_SERVER_VERSION).tar.xz
EVOLUTION_DATA_SERVER_SITE = https://download.gnome.org/sources/evolution-data-server/3.54
EVOLUTION_DATA_SERVER_LICENSE = LGPL-2.1
EVOLUTION_DATA_SERVER_LICENSE_FILES = COPYING
EVOLUTION_DATA_SERVER_INSTALL_STAGING = YES
# GTK4 is on for libedataserverui4, which gnome-calendar links against; the
# GTK3 UI stays off.
EVOLUTION_DATA_SERVER_DEPENDENCIES = \
	host-pkgconf libical libsecret libsoup3 json-glib sqlite icu gcr4 libgtk4

EVOLUTION_DATA_SERVER_CONF_OPTS = \
	-DENABLE_GOA=OFF \
	-DENABLE_EXAMPLES=OFF \
	-DENABLE_TESTS=OFF \
	-DENABLE_GTK=OFF \
	-DENABLE_GTK4=ON \
	-DENABLE_OAUTH2_WEBKITGTK=OFF \
	-DENABLE_OAUTH2_WEBKITGTK4=OFF \
	-DENABLE_CANBERRA=OFF \
	-DENABLE_WEATHER=OFF \
	-DWITH_OPENLDAP=OFF \
	-DENABLE_SMIME=OFF \
	-DWITH_LIBDB=OFF \
	-DENABLE_VALA_BINDINGS=OFF \
	-DENABLE_DOT_LOCKING=OFF \
	-DENABLE_GTK_DOC=OFF

# data/CMakeLists.txt decodes the built-in Google OAuth 2.0 client id by
# compiling and running a helper, then reads the file that helper was supposed
# to write. A cross build cannot run it - CHECK_C_SOURCE_RUNS reports the
# try_run and moves on - but the file(READ) that follows is unconditional, so
# configure stops:
#
#   data/CMakeLists.txt:42 (file): file failed to open for reading
#   (No such file or directory): .../oauth2-google-client-id
#
# Passing an empty WITH_GOOGLE_CLIENT_ID does not avoid it; CMakeLists.txt
# substitutes its own value whenever the variable is empty. Create the file
# instead. Its content only prepends an x-scheme-handler entry to the OAuth2
# handler's desktop file, and this build has ENABLE_GOA=OFF, so there is
# nothing for that handler to do.
# Three of the configure checks are try_run(), which cross-compiling cannot
# answer, and CMake counts each unanswered one as an error and ends with
# "Configuring incomplete" however far it got. Two need real answers:
#
#   _correct_iconv     runs iconv-detect.c, which writes iconv-detect.h with
#                      the names this iconv gives the ISO charsets; camel
#                      includes that header, and a plain exit code would leave
#                      it missing. Generate it with the host compiler instead:
#                      build and target are both glibc, so the program's
#                      answer here is the answer there.
#   HAVE_LKSTRFTIME    asks whether strftime understands %l and %k. glibc does.
#
# _decoded is the OAuth2 client id decode below; it stays unanswered on
# purpose, so the empty file this hook creates is what gets read.
define EVOLUTION_DATA_SERVER_GENERATE_ICONV_DETECT
	$(HOSTCC) -DICONV_DETECT_BUILD_DIR='"$(@D)/"' \
		-o $(@D)/iconv-detect.host $(@D)/iconv-detect.c
	$(@D)/iconv-detect.host
	rm -f $(@D)/iconv-detect.host
endef
EVOLUTION_DATA_SERVER_PRE_CONFIGURE_HOOKS += EVOLUTION_DATA_SERVER_GENERATE_ICONV_DETECT

# gen-western-table generates a header during the build, so it has to run
# here, not on the target. Compile it with the host toolchain and hand the
# result to cmake; the patch that adds GEN_WESTERN_TABLE then leaves the
# target executable unbuilt. It needs nothing but glib and the configured
# header at the top of the build tree, so this stays a one-line compile.
# HOST_MAKE_ENV is what makes pkg-config answer for the host: a package's
# recipes run with PKG_CONFIG_SYSROOT_DIR and PKG_CONFIG_LIBDIR pointing into
# the target sysroot, so asking without it returns the target's glib and the
# host link then fails on the target libc.
define EVOLUTION_DATA_SERVER_BUILD_GEN_WESTERN_TABLE
	$(HOST_MAKE_ENV) sh -c '$(HOSTCC) $(HOST_CFLAGS) -I$(@D) \
		`$(HOST_DIR)/bin/pkg-config --cflags glib-2.0` \
		-o $(@D)/gen-western-table.host \
		$(@D)/src/addressbook/libebook-contacts/gen-western-table.c \
		`$(HOST_DIR)/bin/pkg-config --libs glib-2.0`'
endef
EVOLUTION_DATA_SERVER_PRE_BUILD_HOOKS += EVOLUTION_DATA_SERVER_BUILD_GEN_WESTERN_TABLE
EVOLUTION_DATA_SERVER_CONF_OPTS += -DGEN_WESTERN_TABLE=$(@D)/gen-western-table.host

# camel uses "bool" as an ordinary identifier - "gint bool = FALSE;" and the
# reads that follow it - which C23 does not allow, and this gcc defaults to
# C23:
#
#   camel-sexp.c:399:14: error: two or more data types in declaration
#   specifiers | gint bool = FALSE;
#
# Build it as the language it was written in rather than renaming the variable
# in every function that has one.
EVOLUTION_DATA_SERVER_CONF_OPTS += -DCMAKE_C_FLAGS="$(TARGET_CFLAGS) -std=gnu17"

EVOLUTION_DATA_SERVER_CONF_OPTS += \
	-D_correct_iconv_EXITCODE=0 \
	-DHAVE_LKSTRFTIME_EXITCODE=0 \
	-D_decoded_EXITCODE=FAILED_TO_RUN

define EVOLUTION_DATA_SERVER_STUB_OAUTH2_CLIENT_ID
	touch $(@D)/oauth2-google-client-id
endef
EVOLUTION_DATA_SERVER_PRE_CONFIGURE_HOOKS += EVOLUTION_DATA_SERVER_STUB_OAUTH2_CLIENT_ID

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
EVOLUTION_DATA_SERVER_CONF_OPTS += -DENABLE_INTROSPECTION=ON
EVOLUTION_DATA_SERVER_DEPENDENCIES += gobject-introspection
else
EVOLUTION_DATA_SERVER_CONF_OPTS += -DENABLE_INTROSPECTION=OFF
endif

$(eval $(cmake-package))
