// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "rvsteel-soc.h"

#ifndef MEMORY_SIZE
#define __RVSTEEL_MEM_SIZE "8192"
#else
#define __RVSTEEL_MEM_SIZE MEMORY_SIZE
#endif

// Boot code. Set the memory size, the return address, the stack pointer and
// the interrupt handler
asm(".section .boot, \"ax\";              \
    .global _start;                       \
    _start:                               \
      la ra, _start;                      \
      la sp, " __RVSTEEL_MEM_SIZE ";      \
      la t0, __rvsteel_irq_handler__;     \
      csrw mtvec, t0;                     \
      j main;                             \
    __rvsteel_irq_handler__:              \
      la t0, __RVSTEEL_IRQ_HANDLER;       \
      lw t1, 0(t0);                       \
      jalr ra, t1, 0;                     \
      mret;                               ");

// Address of the interrupt handler
volatile void *__RVSTEEL_IRQ_HANDLER = (volatile void *)0x00000000;

void irq_set_interrupt_handler(void (*interrupt_handler)())
{
  __RVSTEEL_IRQ_HANDLER = (volatile void *)interrupt_handler;
}

