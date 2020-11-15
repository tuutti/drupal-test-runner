EXISTING_CONFIG ?= false
INSTALL_TARGETS ?= composer-install site-install
DRUPAL_ROOT = $(SCRIPT_BASE_PATH)

ifeq ($(EXISTING_CONFIG),true)
	SITE_INSTALL_ARGS += --existing-config
	INSTALL_TARGES =+ config-import
else
	SITE_INSTALL_ARGS += $(or $(DRUPAL_INSTALL_PROFILE),minimal)
endif

# Add test groups if defined.
ifndef ($(DRUPAL_TEST_GROUPS))

ifeq ($(TEST_RUNNER),phpunit)
	TEST_RUNNER_ARGS += --group $(DRUPAL_MODULE_NAME)
endif

ifeq ($(TEST_RUNNER),core)
	TEST_RUNNER_ARGS += $(DRUPAL_TEST_GROUPS)
endif
endif

install: $(INSTALL_TARGETS)

PHONY += site-install
site-install:
	$(call run_in_drupal, $(DRUSH) --yes -v site-install --db-url="$(DRUPAL_DB_URL)" $(SITE_INSTALL_ARGS))

composer-install:
	$(COMPOSER) install

config-import:
	$(call run_in_drupal, $(DRUSH) --yes cim)
