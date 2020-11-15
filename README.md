# Drupal test runner

[![Tests](https://github.com/tuutti/drupal-test-runner/workflows/CI/badge.svg)](https://github.com/tuutti/drupal-test-runner/actions)

Provides a set of tools to make testing Drupal easier.

## Requirements

- make (GNU)
- composer
- php
- composer

## Installation

`$ composer global require tuutti/drupal-test-runner ^1.0`

This will create `drupal-tr` executable that works as a wrapper for our make commands. You can either call it directly
from composer's binary folder or add composer's global bin dir to your `$PATH` variable: `PATH="$PATH:$HOME/.composer/vendor/bin"`.

## Test runners

### PHPUnit

Uses phpunit to run tests (default).

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `PHPUNIT_CONFIG_FILE` | `git root/phpunit.xml.dist` | N | Path to phpunit config file |
| `DRUPAL_TESTSUITES` | | N | Limit tests to certain types, like `unit` or `kernel` |

### Core (run-tests.sh)

Uses core's `run-tests.sh` to run tests.

Set `TEST_RUNNER=core` to use this.

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `DRUPAL_TESTSUITES` | | N | Limit tests to certain types, like `PHPUnit-Kernel` |

## Configuration

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `DRUPAL_DB_URL` | | Y | The database url, for example `mysql://drupal:drupal@localhost/drupal` |
| `INSTALLER_TYPE` | `contrib` | Y | The test type (contrib or composer-project) |
| `TEST_RUNNER`| `phpunit` | Y | The test runner (phpunit or core) |
| `PHP_BINARY` | `$(which php)` | Y | Path to PHP binary |
| `DRUSH` | `$(which drush)`, fallbacks to `vendor/bin/drush` | Y | Path to drush binary. If Drush is not found it will be installed with composer |
| `DRUPAL_BASE_URL` | Fallbacks to `SIMPLETEST_BASE_URL` if set | N | The base url (required for functional tests) |
| `SIMPLETEST_BASE_URL` | | N | Same as `DRUPAL_BASE_URL` |
| `TEST_RUNNER_ROOT` | Defaults to `DRUPAL_ROOT` | N | |

## Contrib installer

Use `contrib` when testing something that is not packaged with Drupal core, like Drupal modules or themes. Core version is determined by `DRUPAL_CORE_VERSION` variable and will be installed to given `DRUPAL_ROOT`.

Your `DRUPAL_MODULE_PATH` (git root by default) will be added to composer.json `repositories` automatically and installed with `composer require drupal/$DRUPAL_MODULE_NAME`. For this to work your package needs to have a composer.json file containing `type` and `name` values starting with `drupal`, for example:

```json
{
  "name": "drupal/your_module",
  "type": "drupal-module"
}

```
See [composer/installers](https://github.com/composer/installers) for available types.

*NOTE*: `DRUPAL_ROOT` cannot be inside the `DRUPAL_MODULE_PATH` folder. By default it's set to `git root/../drupal`.

### Usage

Running `drupal-tr` will execute `make install` using [make/contrib.mk](make/contrib.mk). This will:

- Install the Drupal to `DRUPAL_ROOT`
- Install Drush with composer if `drush` executable is not found
- Set `DRUPAL_MODULE_PATH` path to composer.json's repositories
- Run composer install
- Install Drupal using `DRUPAL_INSTALL_PROFILE` install profile

#### Configuration

| Variable name | Default value | Required | Descriptiion |
|---------------|---|---| -- |
| `DRUPAL_MODULE_NAME` | | Y | The name of module to test |
| `DRUPAL_INSTALL_PROFILE` | minimal | The install profile to install Drupal with |
| `DRUPAL_ROOT` | `git root/../drupal` | N | The path where Drupal will be installed |
| `DRUPAL_CORE_VERSION` | 9.0.x | Y | The core version |
| `DRUPAL_MODULE_PATH` | `git root` | Y | Path to the module |
| `DRUPAL_TEST_GROUPS` | `$DRUPAL_MODULE_NAME ` | Y | The test groups. Comma separated list of group names (from `@group` annotation) |


#### Github actions example

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

## Composer-project installer

Use `composer-project` when your project is built with composer, like [drupal-composer/drupal-project](https://github.com/drupal-composer/drupal-project).

### Usage

Running `drupal-tr` will execute `make install` using [make/composer-project.mk](make/composer-project.mk). This will:

- Run composer install in git root to build your project
- Install Drush with composer if `drush` executable is not found
- Install Drupal using `DRUPAL_INSTALL_PROFILE` or with existing configuration when `EXISTING_CONFIG` is set to `true`.

#### Configuration

| Variable name | Default value | Required | Descriptiion |
|---------------|---|---| -- |
| `DRUPAL_INSTALL_PROFILE` | minimal | The install profile to install Drupal with |
| `DRUPAL_ROOT` | `git root` | N | The git root |
| `DRUPAL_TEST_GROUPS` | `$DRUPAL_MODULE_NAME ` | Y | The test groups. Comma separated list of group names (from `@group` annotation) |


## Running tests

`drupal-tr run-tests`
