################################################################################
#
# graphene
#
################################################################################

GRAPHENE_VERSION = 1.10.8
GRAPHENE_SITE = https://github.com/ebassi/graphene.git
GRAPHENE_SITE_METHOD = git
GRAPHENE_LICENSE = MIT
GRAPHENE_LICENSE_FILES = licenses/MIT.txt
GRAPHENE_INSTALL_STAGING = YES

GRAPHENE_DEPENDENCIES = host-python3
GRAPHENE_CONF_OPTS += -Dtests=false

ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
GRAPHENE_CONF_OPTS += -Dgobject_types=true
GRAPHENE_DEPENDENCIES += libglib2
else
GRAPHENE_CONF_OPTS += -Dgobject_types=false
endif

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
GRAPHENE_CONF_OPTS += -Dintrospection=enabled
GRAPHENE_DEPENDENCIES += gobject-introspection
else
GRAPHENE_CONF_OPTS += -Dintrospection=disabled
endif

$(eval $(meson-package))
