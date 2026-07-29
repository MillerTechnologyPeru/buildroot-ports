################################################################################
#
# python-gbinder
#
# Upstream calls itself gbinder-python; the directory follows Buildroot's
# python-<module> naming, so the tarball name is set explicitly.
#
# setup.py cythonises gbinder.pyx and reads its compiler and linker flags
# by shelling out to a bare "pkg-config libgbinder". That resolves to
# Buildroot's own pkg-config wrapper, which defaults to the staging
# sysroot, so the extension links against the target libgbinder rather
# than anything on the build host.
#
################################################################################

PYTHON_GBINDER_VERSION = 1.3.1
PYTHON_GBINDER_SOURCE = gbinder-python-$(PYTHON_GBINDER_VERSION).tar.gz
PYTHON_GBINDER_SITE = $(call github,erfanoabdi,gbinder-python,$(PYTHON_GBINDER_VERSION))
PYTHON_GBINDER_LICENSE = GPL-3.0
PYTHON_GBINDER_LICENSE_FILES = LICENSE
PYTHON_GBINDER_SETUP_TYPE = setuptools
PYTHON_GBINDER_DEPENDENCIES = host-pkgconf host-python-cython libgbinder

$(eval $(python-package))
