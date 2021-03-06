DRUPAL_CORE_VERSION ?= 9.0.x
DRUPAL_MODULE_PATH ?= $(SCRIPT_BASE_PATH)
DRUPAL_INSTALL_PROFILE ?= minimal

ifeq ($(DRUPAL_MODULE_NAME),)
$(error "DRUPAL_MODULE_NAME argument not set")
endif

ifndef ($(DRUPAL_TEST_GROUPS))
	DRUPAL_TEST_GROUPS = $(DRUPAL_MODULE_NAME)
endif

ifeq ($(TEST_RUNNER),phpunit)
	TEST_RUNNER_ARGS += --group $(DRUPAL_MODULE_NAME)
endif

ifeq ($(TEST_RUNNER),core)
	TEST_RUNNER_ARGS += $(DRUPAL_TEST_GROUPS)
endif

install: $(DRUPAL_ROOT)/composer.json set-composer-repositories composer-install $(DRUSH) $(DRUPAL_ROOT)/sites/default/settings.php

$(DRUPAL_ROOT)/sites/default/settings.php:
	$(call step, Installing Drupal)
	$(call run_in_drupal, $(DRUSH) --yes -v site-install $(DRUPAL_INSTALL_PROFILE) --db-url="$(DRUPAL_DB_URL)")
	$(call run_in_drupal, $(DRUSH) en $(DRUPAL_MODULE_NAME) simpletest)

$(DRUSH):
	$(call step, Installing Drush)
	$(call run_in_drupal, $(COMPOSER) require drush/drush ^$(DRUSH_VERSION))

$(DRUPAL_ROOT)/composer.json:
	$(call step, Cloning Drupal core)
	git clone --depth 1 --branch "$(DRUPAL_CORE_VERSION)" http://git.drupal.org/project/drupal.git/ $(DRUPAL_ROOT)

PHONY += set-composer-repositories
set-composer-repositories:
	$(call step, Set Composer repositories)
	$(call run_in_drupal, $(COMPOSER) config repositories.0 path $(DRUPAL_MODULE_PATH))

PHONY += composer-install
composer-install:
	$(call step, Install composer dependencies)
	$(call run_in_drupal, $(COMPOSER) install)
	$(call run_in_drupal, $(COMPOSER) require drupal/$(DRUPAL_MODULE_NAME))
	$(call step, Upgrade phpunit)
	$(call run_in_drupal, $(COMPOSER) run-script drupal-phpunit-upgrade)

