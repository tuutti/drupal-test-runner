EXISTING_CONFIG ?= false
INSTALL_TARGETS ?= composer-install $(DRUSH) site-install
DRUPAL_ROOT = $(SCRIPT_BASE_PATH)

ifeq ($(EXISTING_CONFIG),true)
	SITE_INSTALL_ARGS += --existing-config
	INSTALL_TARGETS += config-import
else
	SITE_INSTALL_ARGS += $(or $(DRUPAL_INSTALL_PROFILE),minimal)
endif

# Add test groups if defined.
ifneq ($(DRUPAL_TEST_GROUPS),)

ifeq ($(TEST_RUNNER),phpunit)
	TEST_RUNNER_ARGS += --group $(DRUPAL_TEST_GROUPS)
endif

ifeq ($(TEST_RUNNER),core)
	TEST_RUNNER_ARGS += $(DRUPAL_TEST_GROUPS)
endif

endif

install: $(INSTALL_TARGETS)

PHONY += site-install
site-install:
	$(call step, Installing Drupal)
	$(call run_in_drupal, $(DRUSH) --yes -v site-install --db-url="$(DRUPAL_DB_URL)" $(SITE_INSTALL_ARGS))
	$(call run_in_drupal, $(DRUSH) --yes en simpletest)

composer-install:
	$(call step, Install composer dependencies)
	$(call run_in_drupal, $(COMPOSER) install)

config-import:
	$(call step, Import config)
	$(call run_in_drupal, $(DRUSH) --yes cim)

$(DRUSH):
	$(call step, Installing Drush)
	$(call run_in_drupal, $(COMPOSER) require drush/drush)
