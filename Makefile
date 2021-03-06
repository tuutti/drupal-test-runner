PHONY :=
COMPOSER := $(shell which composer.phar 2>/dev/null || which composer 2>/dev/null)
# Allowed values = contrib, composer-project
# this determines what makefile we use to install project and dependencies
INSTALLER_TYPE ?= contrib
# Allowed values = phpunit, core
TEST_RUNNER ?= phpunit
PHP_BINARY ?= $(shell which php 2>/dev/null)
DRUPAL_DB_URL ?= $(SIMPLETEST_DB)

ifeq ($(SCRIPT_BASE_PATH),)
$(error "SCRIPT_BASE_PATH argument not set")
endif

DRUPAL_ROOT ?= $(SCRIPT_BASE_PATH)/../drupal

ifeq ($(DRUPAL_BASE_URL),)
	DRUPAL_BASE_URL ?= $(SIMPLETEST_BASE_URL)
endif

ifeq ($(TEST_RUNNER),core)
	# Make sure test runner uses correct PHP binary.
	TEST_RUNNER_ARGS ?= --color --verbose --php $(PHP_BINARY)
ifneq ($(DRUPAL_BASE_URL),)
	TEST_RUNNER_ARGS += --url $(DRUPAL_BASE_URL)
endif
# Filter by testsuites. For example PHPUnit-Unit,PHPUnit-Kernel.
ifneq ($(DRUPAL_TESTSUITES),)
	TEST_RUNNER_ARGS += --types $(DRUPAL_TESTSUITES)
endif
endif

ifeq ($(TEST_RUNNER),phpunit)
	TEST_RUNNER_ARGS ?= -c $(PHPUNIT_CONFIG_FILE)
# Filter by testsuites. For example unit,kernel.
ifdef ($(DRUPAL_TESTSUITES))
	TEST_RUNNER_ARGS += --testsuite $(DRUPAL_TESTSUITES)
endif
endif

DRUSH = $(DRUPAL_ROOT)/vendor/bin/drush
DRUSH_VERSION ?= 10.0

include make/$(INSTALLER_TYPE).mk
include make/tests.mk
include make/utility.mk

ifeq ($(DRUPAL_DB_URL),)
$(error "DRUPAL_DB_URL argument not set")
endif

define run_in_drupal
	@cd $(DRUPAL_ROOT) && $(1)
endef

define step
	@printf "\n\033[0;31m>>>\033[0;33m$(1)\033[0m\n\n"
endef

.PHONY: $(PHONY)
