ifeq ($(TEST_RUNNER_ROOT),)
	TEST_RUNNER_ROOT = $(DRUPAL_ROOT)
endif

ifeq ($(TEST_RUNNER),phpunit)
	PHPUNIT_CONFIG_FILE ?= $(TEST_RUNNER_ROOT)/phpunit.xml.dist
	TEST_RUNNER_BIN ?= $(TEST_RUNNER_ROOT)/vendor/bin/phpunit
endif

ifeq ($(TEST_RUNNER),core)
	TEST_RUNNER_BIN ?= cd $(TEST_RUNNER_ROOT) && $(PHP_BINARY) ./core/scripts/run-tests.sh
endif

PHONY += run-tests
run-tests:
	$(call step, Running $(TEST_RUNNER_BIN) $(TEST_RUNNER_ARGS))
	$(TEST_RUNNER_BIN) $(TEST_RUNNER_ARGS)
