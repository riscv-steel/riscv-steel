// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel_soc.h"

extern "C" __IRQ_M(IRQ_MTIMER0_VECTOR)
{
  mtimer_clear_counter(MTIMER0);
  uart_send_string(UART0, "5ms\n");
}

int main(void)
{
  mtimer_set_compare(MTIMER0, 250000);
  mtimer_clear_counter(MTIMER0);
  mtimer_enable(MTIMER0);
  enable_vector_mod_irq();
  enable_irq(IRQ_MTIMER0_MASK);
  global_enable_irq();

  while (1)
    ;
}

