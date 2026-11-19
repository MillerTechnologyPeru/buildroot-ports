################################################################################
#
# es-theme-art-book-next
#
# The theme upstream ships as EmulationStation's default, at the same commit.
#
################################################################################

ES_THEME_ART_BOOK_NEXT_VERSION = 9a50ef366e750aabfab29e6915a2867607212971
ES_THEME_ART_BOOK_NEXT_SITE = $(call github,anthonycaccese,art-book-next-es,$(ES_THEME_ART_BOOK_NEXT_VERSION))
# Creative Commons BY-NC-SA 2.0 (non-commercial, attribution, share-alike),
# stated in the README; the repository has no separate license file.
ES_THEME_ART_BOOK_NEXT_LICENSE = CC-BY-NC-SA-2.0
ES_THEME_ART_BOOK_NEXT_LICENSE_FILES = README.md

ES_THEME_ART_BOOK_NEXT_THEME_DIR = /usr/share/emulationstation/themes/es-theme-art-book-next

# Keep only the default system artwork set, as upstream does: the other five
# (circuit, classic, nintendont, noir, outline) are about 250 MB together.
# Drop their entries from the theme's artwork menu too, so it offers only
# what is installed - "classic" has no menu entry. The source files of the
# artwork mask (resources/customizations) are design files, not theme data.
#
# This build of the frontend searches /etc/emulationstation/themes for
# system-wide themes, so link that to the installed location.
define ES_THEME_ART_BOOK_NEXT_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)$(ES_THEME_ART_BOOK_NEXT_THEME_DIR)
	$(INSTALL) -d $(TARGET_DIR)$(ES_THEME_ART_BOOK_NEXT_THEME_DIR)
	cp -a $(@D)/. $(TARGET_DIR)$(ES_THEME_ART_BOOK_NEXT_THEME_DIR)/
	rm -rf $(addprefix $(TARGET_DIR)$(ES_THEME_ART_BOOK_NEXT_THEME_DIR)/_inc/systems/artwork-,\
		circuit classic nintendont noir outline)
	rm -f $(addprefix $(TARGET_DIR)$(ES_THEME_ART_BOOK_NEXT_THEME_DIR)/resources/customizations/system-art-mask.,\
		psd afdesign)
	$(SED) '/<include name="\(noir\|nintendont\|circuit\|outline\)"/d' \
		$(TARGET_DIR)$(ES_THEME_ART_BOOK_NEXT_THEME_DIR)/theme.xml
	$(INSTALL) -d $(TARGET_DIR)/etc/emulationstation
	ln -sfn ../../usr/share/emulationstation/themes \
		$(TARGET_DIR)/etc/emulationstation/themes
endef

$(eval $(generic-package))
