// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define UART_CONTROLLER_ADDR (UartController *)0x80000000

// UART interrupt signal is connected to Fast IRQ #0
__NAKED void fast0_irq_handler(void)
{
  char rx = uart_read(UART_CONTROLLER_ADDR);
  if (rx == '\r') // Enter key
    uart_write_string(UART_CONTROLLER_ADDR, "\n\nType something else and press enter: ");
  else if (rx < 127)
    uart_write(UART_CONTROLLER_ADDR, rx);
  __ASM_VOLATILE("mret");
}

void main(void)
{
  uart_write_string(UART_CONTROLLER_ADDR, "RISC-V Steel - UART demo");
  uart_write_string(UART_CONTROLLER_ADDR, "\n\nType something and press Enter:\n");
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
  csr_global_enable_irq();
  while (1)
    ;
}
