// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_api.h"

// A minimal Hello World program
int main()
{
  uart_send_string(UART0, "Hello World!");
  while (1)
    ;
}
