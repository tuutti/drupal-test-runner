# Drupal test runner

Provides a list of `make` commands to install and test Drupal.

## Requirements

- make (GNU)
- composer
- php
- composer
- git (\*)

(\*): Only contrib-installer.

## Installation

`$ composer global require tuutti/drupal-test-runner`

This will create a `drupal-tr` command that works as a wrapper for our make commands. You can either call it directly from composer's binary folder or add composer's global bin dir to your `$PATH` variable: `PATH="$PATH:$HOME/.composer/vendor/bin"`.

## Usage

drupal-test-runner provides two different installers:

### 1. Contrib

@todo

### 2. Project

@todo
