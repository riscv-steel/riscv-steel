// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_soc.h"

// A minimal Hello World Program
int main(void)
{
  uart_write_string(UART0, "Hello World from RISC-V Steel!\n");
  while (1)
    ;
}