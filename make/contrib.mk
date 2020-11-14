DRUPAL_CORE ?= 9.0.x
DRUPAL_ROOT ?= $(shell pwd)/../drupal
DRUPAL_MODULE_PATH ?= $(shell pwd)

ifeq ($(DRUPAL_MODULE),)
$(error "DRUPAL_MODULE argument not set")
endif

ifndef ($(DRUPAL_TEST_GROUPS))
	DRUPAL_TEST_GROUPS = $(DRUPAL_MODULE)
endif

ifeq ($(TEST_RUNNER),phpunit)
	TEST_RUNNER_ARGS += --group $(DRUPAL_MODULE)
endif

ifeq ($(TEST_RUNNER),core)
	TEST_RUNNER_ARGS += $(DRUPAL_TEST_GROUPS)
endif

install: $(DRUPAL_ROOT)/composer.json $(DRUSH) set-composer-repositories composer-install $(DRUPAL_ROOT)/sites/default/settings.php

# Install drush if not already installed
$(DRUSH):
	$(call step, Installing Drush)
	$(call run_in_drupal, $(COMPOSER) require drush/drush)

$(DRUPAL_ROOT)/sites/default/settings.php:
	$(call step, Installing Drupal)
	$(call run_in_drupal, $(DRUSH) --yes -v site-install minimal --db-url="$(DRUPAL_DB_URL)")
	$(call run_in_drupal, $(DRUSH) en $(DRUPAL_MODULE) simpletest)

$(DRUPAL_ROOT)/composer.json:
	$(call step, Cloning Drupal core)
	git clone --depth 1 --branch "$(DRUPAL_CORE)" http://git.drupal.org/project/drupal.git/ $(DRUPAL_ROOT)

PHONY += set-composer-repositories
set-composer-repositories:
	$(call step, Set $(COMPOSER) repositories)
	$(call run_in_drupal, $(COMPOSER) config repositories.0 path $(DRUPAL_MODULE_PATH))

PHONY += set-composer-repositories
composer-install:
	$(call step, Install composer dependencies)
	$(call run_in_drupal, $(COMPOSER) install)
	$(call run_in_drupal, $(COMPOSER) require drupal/$(DRUPAL_MODULE))

