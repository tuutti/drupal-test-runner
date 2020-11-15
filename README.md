# Drupal test runner

[![Tests](https://github.com/tuutti/drupal-test-runner/workflows/CI/badge.svg)](https://github.com/tuutti/drupal-test-runner/actions)

Provides a list of `make` commands to make testing Drupal easier.

## Requirements

- make (GNU)
- composer
- php
- composer

## Installation

`$ composer global require tuutti/drupal-test-runner ~1.0`

This will create `drupal-tr` command that works as a wrapper for our make commands. You can either call it directly
from composer's binary folder or add composer's global bin dir to your `$PATH` variable: `PATH="$PATH:$HOME/.composer/vendor/bin"`.

## Usage

### Shared variables

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `DRUPAL_DB_URL` | | Y | The database url, for example `mysql://drupal:drupal@localhost/drupal` |
| `TEST_TYPE` | `contrib` | Y | The test type (contrib or project) | 
| `TEST_RUNNER`| `phpunit` | Y | The test runner (phpunit or core) |
| `PHP_BINARY` | `$(which php)` | Y | Path to PHP binary |
| `DRUSH` | `$(which drush)`, fallbacks to `vendor/bin/drush` | Y | Path to drush binary |
| `DRUPAL_BASE_URL` | Fallbacks to `SIMPLETEST_BASE_URL` if set | N | The base url (required for functional tests) |
| `SIMPLETEST_BASE_URL` | | N | Same as `DRUPAL_BASE_URL` |

### PHPUnit specific variables

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `PHPUNIT_CONFIG_FILE` | `git root/phpunit.xml.dist` | N | Path to phpunit config file |
| `DRUPAL_TESTSUITES` | | N | Limit tests to certain types, like `unit` or `kernel` |

### Core's test runner specific variables

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `DRUPAL_TESTSUITES` | | N | Limit tests to certain types, like `PHPUnit-Kernel` |

`drupal-test-runner` provides two different installers `contrib` and `project`.

### 1. Contrib

### Test runner specific variables

| Variable name | Default value | Required | Descriptiion |
|---------------|---|---| -- |
| `DRUPAL_MODULE_NAME` | | Y | The name of module to test |
| `DRUPAL_ROOT` | `git root/../drupal` | N | The path where Drupal will be installed |
| `DRUPAL_CORE_VERSION` | 9.0.x | Y | The core version |
| `DRUPAL_MODULE_PATH` | `git root` | Y | Path to the module | 
| `DRUPAL_TEST_GROUPS` | `$DRUPAL_MODULE_NAME ` | Y | The test groups. Comma separated list of group names (from `@group` annotation) |

Example Github actions:

`.github/workflows/ci.yml`:
```yml
on: [push]
name: CI
env:
  MYSQL_ROOT_PASSWORD: drupal
  SIMPLETEST_DB: "mysql://drupal:drupal@mariadb:3306/drupal"
  SIMPLETEST_BASE_URL: "http://127.0.0.1:8080"
  DRUPAL_MODULE_NAME: "api_tools"
  DRUPAL_CORE_VERSION: 9.0.x
jobs:
  test-contrib:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: true
      matrix:
        php-version: ['7.4']
    container:
      image: ghcr.io/tuutti/drupal-php-docker:${{ matrix.php-version }}

    services:
      mariadb:
        image: mariadb:10.5
        env:
          MYSQL_USER: drupal
          MYSQL_PASSWORD: drupal
          MYSQL_DATABASE: drupal
          MYSQL_ROOT_PASSWORD: drupal
        ports:
          - 3306:3306
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 1

      - name: Set variables
        run: |
          echo "$HOME/.config/composer/vendor/bin" >> $GITHUB_PATH

      - name: Setup Drupal test runner
        run: |
          composer global require tuutti/drupal-test-runner ~1.0

      - name: Setup Drupal
        run: drupal-tr

      - name: Run tests
        run: TEST_RUNNER=core drupal-tr run-tests
```

### 2. Project

@todo
