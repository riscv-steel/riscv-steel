// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __MTIMER__
#define __MTIMER__

#include <stdint.h>
#include "rvsteel_api.h"

typedef struct
{
  __IO uint32_t CR;
  __IO uint32_t MTIMEL;
  __IO uint32_t MTIMEH;
  __IO uint32_t MTIMECMPL;
  __IO uint32_t MTIMECMPH;
} MTimerDevice;

// CR
// MTIMER Enable
#define MTIMER_CR_EN_OFFSET 0U
#define MTIMER_CR_EN_MASK (0x1U << MTIMER_CR_EN_OFFSET)
#define MTIMER_CR_EN (MTIMER_CR_EN_MASK)

__STATIC_INLINE void mtimer_enable(MTimerDevice *MTIMERx)
{
  SET_FLAG(MTIMERx->CR, MTIMER_CR_EN);
}

__STATIC_INLINE void mtimer_disable(MTimerDevice *MTIMERx)
{
  CLEAR_FLAG(MTIMERx->CR, MTIMER_CR_EN);
}

__STATIC_INLINE void mtimer_set_counter(MTimerDevice *MTIMERx, uint64_t val)
{
  MTIMERx->MTIMEL = val & 0xFFFFFFFF;
  MTIMERx->MTIMEH = val >> 32;
}

__STATIC_INLINE uint64_t mtimer_get_counter(MTimerDevice *MTIMERx)
{
  uint32_t cnt_l = MTIMERx->MTIMEL;
  uint64_t cnt_h = MTIMERx->MTIMEH;
  return (cnt_h << 31) | cnt_l;
}

__STATIC_INLINE void mtimer_clear_counter(MTimerDevice *MTIMERx)
{
  MTIMERx->MTIMEL = 0;
  MTIMERx->MTIMEH = 0;
}

__STATIC_INLINE void mtimer_set_compare(MTimerDevice *MTIMERx, uint64_t val)
{
  MTIMERx->MTIMECMPL = val & 0xFFFFFFFF;
  MTIMERx->MTIMECMPH = val >> 32;
}

#endif // __MTIMER__
