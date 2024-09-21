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
  uart_write_string(UART_CONTROLLER_ADDR, "RISC-V Steel - UART example"
                                          "\n\nType something and press Enter:\n");
  while (1)
  {
    if (uart_data_received(UART_CONTROLLER_ADDR))
    {
      char rx = uart_read(UART_CONTROLLER_ADDR);
      if (rx == '\r') // Enter key
        uart_write_string(UART_CONTROLLER_ADDR, "\n\nType something else and press Enter again: ");
      else if (rx < 127) // Echo back printable characters
        uart_write(UART_CONTROLLER_ADDR, rx);
    }
  }
}
