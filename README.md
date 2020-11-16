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

## Usage

Available installers:

- [contrib](#contrib-installer)
- [composer-project](#composer-project-installer)

### Setup Drupal
`drupal-tr` to install Drupal with selected installer (`INSTALLER_TYPE`)

### Run tests
`drupal-tr run-tests` to run tests with selected test runner (`TEST_RUNNER`)

### Utility tools
`drupal-tr run-drush-server` to start a drush server listening on `DRUPAL_BASE_URL`.

## Configuration

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `DRUPAL_DB_URL` | | Y | The database url, for example `mysql://drupal:drupal@localhost/drupal` |
| `INSTALLER_TYPE` | `contrib` | N | The test type (contrib or composer-project) |
| `TEST_RUNNER`| `phpunit` | N | The test runner (phpunit or core) |
| `PHP_BINARY` | `$(which php)` | N | Path to PHP binary |
| `DRUSH` | `$(which drush)`, fallbacks to `vendor/bin/drush` | N | Path to drush binary. If Drush is not found it will be installed with composer |
| `DRUPAL_BASE_URL` | Fallbacks to `SIMPLETEST_BASE_URL` if set | N | The base url (required for functional tests) |
| `SIMPLETEST_BASE_URL` | | N | Same as `DRUPAL_BASE_URL` |
| `TEST_RUNNER_ROOT` | Defaults to `DRUPAL_ROOT` | N | |

## Contrib installer

Use `contrib` when testing something that is not packaged with Drupal core, like Drupal modules or themes. Core version is determined by `DRUPAL_CORE_VERSION` variable and will be installed to given `DRUPAL_ROOT` using `DRUPAL_INSTALL_PROFILE` installation profile.

Your `DRUPAL_MODULE_PATH` (git root by default) will be added to composer.json's `repositories` automatically and installed with `composer require drupal/$DRUPAL_MODULE_NAME`. For this to work your package MUST have a composer.json file containing `type` and `name` values starting with `drupal`, for example:

```json
{
  "name": "drupal/your_module",
  "type": "drupal-module"
}
```
See [composer/installers](https://github.com/composer/installers) for available types.

*NOTE*: `DRUPAL_ROOT` cannot be inside the `DRUPAL_MODULE_PATH` folder.

### Contrib installer configuration

| Variable name | Default value | Required | Descriptiion |
|---------------|---|---| -- |
| `DRUPAL_MODULE_NAME` | | Y | The module/theme name |
| `DRUPAL_INSTALL_PROFILE` | minimal | N | The install profile used to install Drupal |
| `DRUPAL_ROOT` | `git root/../drupal` | N | The path where Drupal will be installed |
| `DRUPAL_CORE_VERSION` | 9.0.x | N | The core version |
| `DRUPAL_MODULE_PATH` | `git root` | N | Path to the module |
| `DRUPAL_TEST_GROUPS` | `$DRUPAL_MODULE_NAME ` | | The test groups. A comma separated list of group names (from `@group` annotation) |

#### Contrib installer Github actions example

`.github/workflows/ci.yml`:
```yml
on: [push]
name: CI
env:
  MYSQL_ROOT_PASSWORD: drupal
  SIMPLETEST_DB: "mysql://drupal:drupal@mariadb:3306/drupal"
  SIMPLETEST_BASE_URL: "http://127.0.0.1:8080"
  DRUPAL_MODULE_NAME: "your_module"
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
          composer global require tuutti/drupal-test-runner ^1.0

      - name: Setup Drupal
        run: drupal-tr

      - name: Run tests
        run: TEST_RUNNER=core drupal-tr run-tests
```

### Contrib installer Gitlab ci example

```yml
variables:
  DRUPAL_MODULE_NAME: your_module
  SIMPLETEST_BASE_URL: http://127.0.0.1:8080
  DRUPAL_CORE_VERSION: 8.9.x
  DRUPAL_INSTALL_PROFILE: minimal
  MYSQL_DATABASE: drupal
  MYSQL_ROOT_PASSWORD: drupal
  SIMPLETEST_DB: mysql://root:drupal@mariadb/drupal
  TEST_RUNNER: core

before_script:
- export PATH=$HOME/.composer/vendor/bin:$PATH
- composer global require tuutti/drupal-test-runner ^1.0
- drupal-tr
- drupal-tr run-drush-server &

services:
- mariadb:latest

test:7.3:
  image: registry.gitlab.com/tuutti/drupal-php-docker:7.3
  script:
    - drupal-tr run-tests
```

## Composer-project installer

Use `composer-project` installer to test Drupal sites that can be installed with composer. For example [drupal-composer/drupal-project](https://github.com/drupal-composer/drupal-project).

Installs Drupal using `DRUPAL_INSTALL_PROFILE` or existing config when `EXISTING_CONFIG` is set to `true`.

### Composer-project installer Github actions example

```yml
on: [push]
name: CI
env:
  SIMPLETEST_DB: "mysql://drupal:drupal@db:3306/drupal"
  SIMPLETEST_BASE_URL: "http://127.0.0.1:8888"
  EXISTING_CONFIG: true
  INSTALLER_TYPE: composer-project
jobs:
  tests:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: true
      matrix:
        php-version: ['7.4']
    container:
      image: ghcr.io/tuutti/drupal-php-docker:${{ matrix.php-version }}
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 1

      - name: Set variables
        run: |
          echo "$HOME/.config/composer/vendor/bin" >> $GITHUB_PATH
      - name: Setup drupal
        run: |
          composer global require tuutti/drupal-test-runner
          drupal-tr

      - name: Run PHPUnit tests
        run: |
          drupal-tr run-drush-server &
          drupal-tr run-tests
```

### Configuration

| Variable name | Default value | Required | Descriptiion |
|---------------|---|---| -- |
| `DRUPAL_INSTALL_PROFILE` | minimal | N | The install profile used to install Drupal |
| `EXISTING_CONFIG` | false | N | Installs Drupal using existing configuration |
| `DRUPAL_ROOT` | `git root` | N | The git root |
| `DRUPAL_TEST_GROUPS` | | | The test groups. A comma separated list of group names (from `@group` annotation) |

## Test runners

### phpunit

Uses `vendor/bin/phpunit` to run tests (default). Attempts to read configuration file from `PHPUNIT_CONFIG_FILE`.

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `PHPUNIT_CONFIG_FILE` | `git root/phpunit.xml.dist` | N | Path to phpunit config file |
| `DRUPAL_TESTSUITES` | | N | Limit tests to certain types, like `unit` or `kernel` |
| `DRUPAL_TEST_GROUPS` | | N | The test groups. A comma separated list of group names (from `@group` annotation) |

### core

Uses core's `core/scripts/run-tests.sh` to run tests.

Set `TEST_RUNNER=core` to use this.

| Variable name | Default value | Required | Description |
|---------------|---|---|--|
| `DRUPAL_TESTSUITES` | | N | Limit tests to certain types, like `PHPUnit-Kernel` |
| `DRUPAL_TEST_GROUPS` | | Y | The test groups. A comma separated list of group names (from `@group` annotation) |
