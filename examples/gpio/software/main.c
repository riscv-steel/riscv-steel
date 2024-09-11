// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define GPIO_CONTROLLER_ADDR (GpioController *)0x80020000

void main(void)
{
  gpio_set_output(GPIO_CONTROLLER_ADDR, 0);
  gpio_set_output(GPIO_CONTROLLER_ADDR, 1);
  gpio_set_input(GPIO_CONTROLLER_ADDR, 2);
  gpio_write(GPIO_CONTROLLER_ADDR, 0, HIGH);
  while (1)
  {
    uint32_t button_state = gpio_read(GPIO_CONTROLLER_ADDR, 2);
    gpio_write(GPIO_CONTROLLER_ADDR, 1, button_state);
  }
}
