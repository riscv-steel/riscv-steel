// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

.globl __rvsteel_boot
.section ".init"
.option norvc;
__rvsteel_boot:
  .option push
  .option norelax
  la    gp, __global_pointer$
  .option pop
  la sp, __freertos_irq_stack_top
  la t0, trap_vector
  csrw mtvec, t0
  j _start
  ecall

.weak rvsteel_default_irq_handler
rvsteel_default_irq_handler:
  .option norvc;
  mret

.weakref irq_m_software,  rvsteel_default_irq_handler
.weakref irq_m_external,  rvsteel_default_irq_handler
.weakref irq_fast_0,      rvsteel_default_irq_handler
.weakref irq_fast_1,      rvsteel_default_irq_handler
.weakref irq_fast_2,      rvsteel_default_irq_handler
.weakref irq_fast_3,      rvsteel_default_irq_handler
.weakref irq_fast_4,      rvsteel_default_irq_handler
.weakref irq_fast_5,      rvsteel_default_irq_handler
.weakref irq_fast_6,      rvsteel_default_irq_handler
.weakref irq_fast_7,      rvsteel_default_irq_handler
.weakref irq_fast_8,      rvsteel_default_irq_handler
.weakref irq_fast_9,      rvsteel_default_irq_handler
.weakref irq_fast_10,     rvsteel_default_irq_handler
.weakref irq_fast_11,     rvsteel_default_irq_handler
.weakref irq_fast_12,     rvsteel_default_irq_handler
.weakref irq_fast_13,     rvsteel_default_irq_handler
.weakref irq_fast_14,     rvsteel_default_irq_handler
.weakref irq_fast_15,     rvsteel_default_irq_handler


.section ".init"
trap_vector:
  .option norvc
  j freertos_risc_v_exception_handler         // 0  - Trap
  j .                                         // 1  - Reserved / Supervisor software interrupt
  j .                                         // 2  - Reserved
  j irq_m_software                            // 3  - Machine software interrupt
  j .                                         // 4  - Reserved
  j .                                         // 5  - Reserved / Supervisor timer interrupt
  j .                                         // 6  - Reserved
  j freertos_risc_v_mtimer_interrupt_handler  // 7  - Machine timer interrupt
  j .                                         // 8  - Reserved
  j .                                         // 9  - Reserved / Supervisor external interrupt
  j .                                         // 10 - Reserved
  j irq_m_external                            // 11 - Machine external interrupt
  j .                                         // 12 - Reserved
  j .                                         // 13 - Reserved
  j .                                         // 14 - Reserved
  j .                                         // 15 - Reserved
  j irq_fast_0                                // 16 - Fast irq #0
  j irq_fast_1                                // 17 - Fast irq #1
  j irq_fast_2                                // 18 - Fast irq #2
  j irq_fast_3                                // 19 - Fast irq #3
  j irq_fast_4                                // 20 - Fast irq #4
  j irq_fast_5                                // 21 - Fast irq #5
  j irq_fast_6                                // 22 - Fast irq #6
  j irq_fast_7                                // 23 - Fast irq #7
  j irq_fast_8                                // 24 - Fast irq #8
  j irq_fast_9                                // 25 - Fast irq #9
  j irq_fast_10                               // 26 - Fast irq #10
  j irq_fast_11                               // 27 - Fast irq #11
  j irq_fast_12                               // 28 - Fast irq #12
  j irq_fast_13                               // 29 - Fast irq #13
  j irq_fast_14                               // 30 - Fast irq #14
  j irq_fast_15                               // 31 - Fast irq #15
