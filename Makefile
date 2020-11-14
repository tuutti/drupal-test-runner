PHONY :=
COMPOSER := $(shell which composer.phar 2>/dev/null || which composer 2>/dev/null)
# Call drush to see if it fails (if we're running Drush launcher for example) and fallback
# to vendor/bin/drush target to indicate that drush needs to be installed with composer.
DRUSH := $(shell drush > /dev/null 2>&1 && which drush 2>/dev/null || echo "$(ROOT)/vendor/bin/drush")
# Allowed values = contrib, project
# this determines what makefile we use to install project and dependencies
TEST_TYPE ?= contrib
# Allowed values = phpunit, core
TEST_RUNNER ?= phpunit
PHP_BINARY ?= $(shell which php 2>/dev/null)
DRUPAL_DB_URL ?= $(SIMPLETEST_DB)

ifeq ($(TEST_RUNNER),core)
	TEST_RUNNER_ARGS ?= --color --verbose
ifdef ($(DRUPAL_BASE_URL))
	TEST_RUNNER_ARGS += --url $(DRUPAL_BASE_URL)
else ifdef ($(SIMPLETEST_BASE_URL))
	TEST_RUNNER_ARGS += --url $(SIMPLETEST_BASE_URL)
endif
# Filter by testsuites. For example PHPUnit-Unit,PHPUnit-Kernel.
ifdef ($(DRUPAL_TESTSUITES))
	TEST_RUNNER_ARGS += --types $(DRUPAL_TESTSUITES)
endif
	TEST_RUNNER_BIN ?= cd $(DRUPAL_ROOT) && $(PHP_BINARY) ./core/scripts/run-tests.sh
endif

ifeq ($(TEST_RUNNER),phpunit)
	TEST_RUNNER_BIN ?= $(DRUPAL_ROOT)/vendor/bin/phpunit
	PHPUNIT_CONFIG_FILE ?= $(DRUPAL_ROOT)/phpunit.xml.dist
	TEST_RUNNER_ARGS ?= -c $(PHPUNIT_CONFIG_FILE)
# Filter by testsuites. For example unit,kernel.
ifdef ($(DRUPAL_TESTSUITES))
	TEST_RUNNER_ARGS += --testsuite $(DRUPAL_TESTSUITES)
endif
endif

include make/$(TEST_TYPE).mk
include make/tests.mk

ifeq ($(DRUPAL_DB_URL),)
$(error "DRUPAL_DB_URL argument not set")
endif

define run_in_drupal
	cd $(DRUPAL_ROOT) && $(1)
endef

define step
	@printf "\n\033[0;31m>>>\033[0;33m$(1)\033[0m\n\n"
endef

.PHONY: $(PHONY)
