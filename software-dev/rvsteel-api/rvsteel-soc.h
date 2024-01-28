// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_SOC_
#define __RVSTEEL_SOC_

#include "mtimer.h"
#include "uart.h"

// Bus adder base
#define MAIN_BASE_ADDR      0x00000000U

// Peripheral map in main bus
#define MTIMER0_BASE        (MAIN_BASE_ADDR +   0x10000000U)
#define UART0_BASE          (MAIN_BASE_ADDR +   0x80000000U)

// Peripheral declaration
#define MTIMER0             ((MTIMER_TypeDef*)  MTIMER0_BASE)
#define UART0               ((UART_TypeDef*)    UART0_BASE)

/// Sets the function to be called on interrupts
void irq_set_interrupt_handler(void (*interrupt_handler)());

#endif // __RVSTEEL_SOC_
