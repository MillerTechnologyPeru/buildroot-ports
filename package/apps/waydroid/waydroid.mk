################################################################################
#
# waydroid
#
# Pure Python, so nothing to compile: upstream's Makefile only copies
# waydroid.py plus its tools/ and data/ trees into /usr/lib/waydroid and
# symlinks /usr/bin/waydroid at them.
#
# USE_SYSTEMD=0 skips the unit; the container manager is started by
# S90waydroid instead. Nothing else needs patching for that - waydroid's
# handful of systemctl calls (checking for nfcd and apparmor) are all
# guarded by which("systemctl") and simply do not fire here.
#
# USE_DBUS_ACTIVATION=1 is kept on. It installs a D-Bus system service
# file, so dbus-daemon can also activate the manager on demand; that is
# dbus's own activation and has nothing to do with the init system, which
# is exactly why postmarketOS/Alpine keep it enabled next to their OpenRC
# service.
#
# USE_NFTABLES stays 0. It only rewrites LXC_USE_NFT in waydroid-net.sh,
# and the script's iptables path is what BR2_PACKAGE_IPTABLES gives us.
#
# Upstream installs no autostart entry for the session half - on a systemd
# image that is a user unit - so one is added here, as Alpine does.
#
# The images are not packaged. They are hundreds of MB of prebuilt Android
# fetched per-architecture, so "waydroid init" downloads them into
# /var/lib/waydroid at first run.
#
################################################################################

WAYDROID_VERSION = 1.6.3
WAYDROID_SITE = $(call github,waydroid,waydroid,$(WAYDROID_VERSION))
WAYDROID_LICENSE = GPL-3.0
WAYDROID_LICENSE_FILES = LICENSE

WAYDROID_DEPENDENCIES = \
	python3 \
	python-gbinder \
	dbus-python \
	python-gobject \
	lxc \
	dnsmasq \
	iptables \
	kmod

define WAYDROID_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		DESTDIR=$(TARGET_DIR) \
		USE_SYSTEMD=0 \
		USE_DBUS_ACTIVATION=1 \
		USE_NFTABLES=0 \
		install
	$(INSTALL) -D -m 0644 $(WAYDROID_PKGDIR)/files/waydroid-session.desktop \
		$(TARGET_DIR)/etc/xdg/autostart/waydroid-session.desktop
	$(INSTALL) -d $(TARGET_DIR)/var/lib/waydroid
endef

define WAYDROID_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(WAYDROID_PKGDIR)/files/S90waydroid \
		$(TARGET_DIR)/etc/init.d/S90waydroid
endef

# Android binder is the hard requirement: without the driver nothing else
# about waydroid matters, so selecting the package turns it on rather than
# leaving it to each board's defconfig.
#
# CONFIG_ANDROID is the parent menu symbol on kernels before 5.19 and does
# not exist after; enabling it is a no-op on newer ones. BINDERFS is what
# the container manager actually uses - probeBinderDriver() looks for a
# "binder" filesystem in /proc/filesystems, mounts it on /dev/binderfs and
# allocates the anbox-binder/-vndbinder/-hwbinder nodes through the
# BINDER_CTL_ADD ioctl. Only when binderfs is absent does it fall back to
# modprobing an out-of-tree binder_linux with a devices= parameter, which
# is not something this tree ships - so binderfs is the path to guarantee.
#
# KCONFIG_ENABLE_OPT leaves an option that is already =m alone, so a board
# kernel that builds binder as a module keeps it and waydroid's modprobe
# path still works; otherwise these land as =y, matching how the rest of
# this tree avoids depending on module autoloading. BINDER_DEVICES is set
# explicitly because an empty string is a valid kconfig value that leaves
# no static nodes at all.
#
# Note these fixups only take effect when Buildroot builds the kernel
# (BR2_LINUX_KERNEL=y). With an externally built kernel, CONFIG_ANDROID_-
# BINDER_IPC and CONFIG_ANDROID_BINDERFS have to be enabled over there.
#
# The rest: the images are ext4 loop mounts with an overlay on top, vold
# inside the container needs fuse, and LXC wants namespaces, cgroups and a
# veth pair on a bridge with NAT out.
define WAYDROID_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_ANDROID)
	$(call KCONFIG_ENABLE_OPT,CONFIG_ANDROID_BINDER_IPC)
	$(call KCONFIG_ENABLE_OPT,CONFIG_ANDROID_BINDERFS)
	$(call KCONFIG_SET_OPT,CONFIG_ANDROID_BINDER_DEVICES,"binder,hwbinder,vndbinder")
	$(call KCONFIG_ENABLE_OPT,CONFIG_BLK_DEV_LOOP)
	$(call KCONFIG_ENABLE_OPT,CONFIG_EXT4_FS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_OVERLAY_FS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FUSE_FS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_NAMESPACES)
	$(call KCONFIG_ENABLE_OPT,CONFIG_UTS_NS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_IPC_NS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_USER_NS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_PID_NS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_NET_NS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_CGROUPS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_CGROUP_DEVICE)
	$(call KCONFIG_ENABLE_OPT,CONFIG_CGROUP_FREEZER)
	$(call KCONFIG_ENABLE_OPT,CONFIG_CGROUP_SCHED)
	$(call KCONFIG_ENABLE_OPT,CONFIG_MEMCG)
	$(call KCONFIG_ENABLE_OPT,CONFIG_BRIDGE)
	$(call KCONFIG_ENABLE_OPT,CONFIG_VETH)
	$(call KCONFIG_ENABLE_OPT,CONFIG_NF_NAT)
	$(call KCONFIG_ENABLE_OPT,CONFIG_IP_NF_IPTABLES)
	$(call KCONFIG_ENABLE_OPT,CONFIG_IP_NF_FILTER)
	$(call KCONFIG_ENABLE_OPT,CONFIG_IP_NF_NAT)
	$(call KCONFIG_ENABLE_OPT,CONFIG_IP_NF_TARGET_MASQUERADE)
endef

$(eval $(generic-package))
