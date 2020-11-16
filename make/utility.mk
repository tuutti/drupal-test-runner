
PHONY += run-drush-server
run-drush-server:
ifeq ($(DRUPAL_BASE_URL),)
	$(error "DRUPAL_BASE_URL" argument not set)
endif
	$(call step, Starting Drupal web-server)
	$(call run_in_drupal, $(DRUSH) runserver $(DRUPAL_BASE_URL) 2>&1)
