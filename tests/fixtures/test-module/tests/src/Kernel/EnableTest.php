<?php

declare(strict_types = 1);

namespace Drupal\Tests\test_module\Kernel;

use Drupal\KernelTests\KernelTestBase;

/**
 * Tests test_module.
 *
 * @group test_module
 */
class EnableTest extends KernelTestBase {

  /**
   * {@inheritdoc}
   */
  protected static $modules = [
    'test_module',
  ];

  /**
   * {@inheritdoc}
   */
  public function setUp() : void {
    parent::setUp();

    $this->installConfig(['test_module']);
  }

  /**
   * Test that we've enabled our module.
   */
  public function testModule() : void {
    $this->assertNotNull($this->config('system.site')->get('name'));
  }

}
