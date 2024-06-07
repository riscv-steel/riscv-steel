// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

void main(void)
{
  gpio_set_output(RVSTEEL_GPIO, 0);
  gpio_set_output(RVSTEEL_GPIO, 1);
  gpio_set_input(RVSTEEL_GPIO, 2);
  gpio_write(RVSTEEL_GPIO, 0, HIGH);
  while (1)
  {
    uint32_t button_state = gpio_read(RVSTEEL_GPIO, 2);
    gpio_write(RVSTEEL_GPIO, 1, button_state);
  }
}
