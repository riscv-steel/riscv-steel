// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

// Overrides the standard interrupt handler for Machine Timer interrupts
__NAKED void mti_irq_handler()
{
  mtimer_clear_counter(RVSTEEL_MTIMER);
  uart_write_string(RVSTEEL_UART, "Time elapsed: 1 sec\n");
  __ASM_VOLATILE("mret");
}

int main(void)
{
  uart_write_string(RVSTEEL_UART, "MTimer demo started running...\n");
  mtimer_set_compare(RVSTEEL_MTIMER, CPU_FREQUENCY);
  mtimer_clear_counter(RVSTEEL_MTIMER);
  mtimer_enable(RVSTEEL_MTIMER);
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_MTI);
  csr_global_enable_irq();
  while (1)
    ;
}
