// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_soc.h"

int main(void)
{
  gpio_set_output(GPIO0, 0);

  while (1)
  {
    gpio_toggle(GPIO0, 0);
  }
}
