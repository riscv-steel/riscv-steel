// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define UART_CONTROLLER_ADDR (UartController *)0x80000000
#define MTIMER_CONTROLLER_ADDR (MTimerController *)0x80010000

// Overrides the standard interrupt handler for Machine Timer interrupts
__NAKED void mti_irq_handler()
{
  mtimer_clear_counter(MTIMER_CONTROLLER_ADDR);
  uart_write_string(UART_CONTROLLER_ADDR, "Time elapsed: 1 sec\n");
  __ASM_VOLATILE("mret");
}

int main(void)
{
  uart_write_string(UART_CONTROLLER_ADDR, "MTimer demo started running...\n");
  mtimer_set_compare(MTIMER_CONTROLLER_ADDR, CPU_FREQUENCY);
  mtimer_clear_counter(MTIMER_CONTROLLER_ADDR);
  mtimer_enable(MTIMER_CONTROLLER_ADDR);
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_MTI);
  csr_global_enable_irq();
  while (1)
    ;
}
