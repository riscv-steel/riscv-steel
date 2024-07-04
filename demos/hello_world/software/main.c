// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

void main(void)
{
  uart_write_string(RVSTEEL_UART, "Hello World from RISC-V Steel!");
}