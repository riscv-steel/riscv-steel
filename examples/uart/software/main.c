// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000

void main(void)
{
  uart_write_string(DEFAULT_UART, "RISC-V Steel - UART example"
                                  "\n\nType something and press Enter:\n");
  while (1)
  {
    if (uart_data_received(DEFAULT_UART))
    {
      char rx = uart_read(DEFAULT_UART);
      if (rx == '\r') // Enter key
        uart_write_string(DEFAULT_UART, "\n\nType something else and press Enter again: ");
      else if (rx < 127) // Echo back printable characters
        uart_write(DEFAULT_UART, rx);
    }
  }
}
