################################################################################
#
# nanosaur2
#
# Pinned to a commit rather than a tag: the only tag, v2.1.0, predates the
# move to SDL3, and building it would mean carrying SDL2 for one package.
# The tree is fetched with git because the game data and the Pomme submodule
# (the Mac Toolbox reimplementation the port runs on) are both needed, and
# the release tarball has neither.
#
# There are no install rules in the CMake project - it is set up to leave a
# runnable game in the build directory - so the executable and the data are
# installed by hand below. The game finds the data through the build-time
# path added by the patch.
#
################################################################################

NANOSAUR2_VERSION = 56cac5bc849a8eb90b3fa84e3826b2cadc1d4855
NANOSAUR2_SITE = https://github.com/jorio/Nanosaur2.git
NANOSAUR2_SITE_METHOD = git
NANOSAUR2_GIT_SUBMODULES = YES

# The game, its assets and the original manuals are CC-BY-NC-SA-4.0; Pomme,
# vendored as a submodule, is MIT. The NonCommercial clause is why the
# sources are kept out of the legal-info archive.
NANOSAUR2_LICENSE = CC-BY-NC-SA-4.0, MIT (Pomme)
NANOSAUR2_LICENSE_FILES = LICENSE.md extern/Pomme/LICENSE.md
NANOSAUR2_REDISTRIBUTE = NO

NANOSAUR2_DEPENDENCIES = sdl3 libgl

NANOSAUR2_SUPPORTS_IN_SOURCE_BUILD = NO

NANOSAUR2_DATA_DIR = /usr/share/nanosaur2/Data

NANOSAUR2_CONF_OPTS = \
	-DBUILD_SDL_FROM_SOURCE=OFF \
	-DGAME_DATA_DIR=$(NANOSAUR2_DATA_DIR)

define NANOSAUR2_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(NANOSAUR2_BUILDDIR)/Nanosaur2 \
		$(TARGET_DIR)/usr/bin/nanosaur2
	$(INSTALL) -d $(TARGET_DIR)$(NANOSAUR2_DATA_DIR)
	cp -dpfr $(@D)/Data/. $(TARGET_DIR)$(NANOSAUR2_DATA_DIR)
endef

$(eval $(cmake-package))
