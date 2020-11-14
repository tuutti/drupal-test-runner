PHONY += run-tests
run-tests:
	$(call step, Running $(TEST_RUNNER_BIN) $(TEST_RUNNER_ARGS))
	@$(TEST_RUNNER_BIN) $(TEST_RUNNER_ARGS)
