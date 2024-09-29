// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel/globals.h"

__NAKED void rvsteel_return_from_trap()
{
  __ASM_VOLATILE("mret");
}

// Unless explicitly implemented, a trap simply returns.

__WEAK_ALIAS("rvsteel_return_from_trap") void default_trap_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void msi_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void mti_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void mei_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast0_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast1_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast2_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast3_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast4_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast5_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast6_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast7_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast8_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast9_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast10_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast11_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast12_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast13_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast14_irq_handler();
__WEAK_ALIAS("rvsteel_return_from_trap") void fast15_irq_handler();