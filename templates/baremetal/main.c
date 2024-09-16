// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define UART_CONTROLLER_ADDR (UartController *)0x80000000

void main(void)
{
  uart_write_string(UART_CONTROLLER_ADDR, "Hello World from RISC-V Steel!");
}