################################################################################
#
# mozjs128
#
# SpiderMonkey standalone, the distro way: the Firefox ESR source tarball
# with js/src/configure (the flags below follow the Arch/Yocto mozjs128
# recipes). Needs the Rust host toolchain; the bundled ICU is used rather
# than the system one to decouple from Buildroot's ICU version. This is
# the single hardest cross-compile of the GNOME stack - expect the first
# build to need iteration.
#
################################################################################

MOZJS128_VERSION = 128.14.0
MOZJS128_SOURCE = firefox-$(MOZJS128_VERSION)esr.source.tar.xz
MOZJS128_SITE = https://ftp.mozilla.org/pub/firefox/releases/$(MOZJS128_VERSION)esr/source
MOZJS128_LICENSE = MPL-2.0
MOZJS128_LICENSE_FILES = LICENSE
MOZJS128_INSTALL_STAGING = YES
MOZJS128_DEPENDENCIES = host-pkgconf host-python3 host-rustc host-cbindgen zlib

# CBINDGEN is an environment option of its configure (see
# build/moz.configure/bindgen.configure), so name the host build's copy
# instead of leaving configure to search PATH.
# AS must be the compiler driver, not binutils as. Mozilla assembles its .S
# files with the same flags it compiles C with - preprocessor defines, include
# paths, -fPIC, and -Wa, to forward on - which only a driver understands.
# TARGET_CONFIGURE_OPTS sets AS=$(TARGET_CROSS)as, so the bundled ICU data
# stopped the build with:
#
#   x86_64-...-as -o icu_data.o -DNDEBUG=1 ... -Wa,--noexecstack -fPIC -c icu_data.S
#   x86_64-...-as: invalid option -- 'N'
#
# as bundles short options, so it read -DNDEBUG as -D -N -D -E -B -U -G and
# rejected the N. Override after TARGET_CONFIGURE_OPTS, which is what makes it
# win: the shell applies a command's assignments left to right.
MOZJS128_CONF_ENV = \
	CBINDGEN=$(HOST_DIR)/bin/cbindgen \
	$(TARGET_CONFIGURE_OPTS) \
	AS="$(TARGET_CC)" \
	RUSTC=$(HOST_DIR)/bin/rustc \
	CARGO=$(HOST_DIR)/bin/cargo \
	MOZBUILD_STATE_PATH=$(@D)/.mozbuild

MOZJS128_CONF_OPTS = \
	--host=$(shell $(HOSTCC) -dumpmachine) \
	--target=$(GNU_TARGET_NAME) \
	--prefix=/usr \
	--disable-debug \
	--disable-debug-symbols \
	--disable-jemalloc \
	--disable-strip \
	--disable-tests \
	--enable-optimize \
	--enable-shared-js \
	--disable-rust-simd \
	--with-intl-api \
	--without-system-icu \
	--with-system-zlib

define MOZJS128_CONFIGURE_CMDS
	mkdir -p $(@D)/buildroot-build $(@D)/.mozbuild
	cd $(@D)/buildroot-build && \
		$(MOZJS128_CONF_ENV) $(SHELL) $(@D)/js/src/configure \
			$(MOZJS128_CONF_OPTS)
endef

define MOZJS128_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/buildroot-build
endef

define MOZJS128_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/buildroot-build \
		DESTDIR=$(STAGING_DIR) install
endef

# The shared library is left in Mozilla's dist/bin, the directory its build
# collects shipped artifacts into, not beside the objects in js/src/build -
# which holds only libmozjs-128_so.list, the linker input list. It carries no
# SONAME, so the file name is what consumers record as NEEDED and this is the
# name to install it under.
define MOZJS128_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/buildroot-build/dist/bin/libmozjs-128.so \
		$(TARGET_DIR)/usr/lib/libmozjs-128.so
endef

$(eval $(generic-package))
