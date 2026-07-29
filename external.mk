# Packages live at package/<category>/<name>/<name>.mk, with a second level
# for the ones grouped under a shared engine directory (package/games/xash3d).
include $(sort $(wildcard $(BR2_EXTERNAL_SWIFTLINUXPORTS_PATH)/package/*/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_SWIFTLINUXPORTS_PATH)/package/*/*/*/*.mk))
