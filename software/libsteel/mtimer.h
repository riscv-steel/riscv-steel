// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __LIBSTEEL_MTIMER__
#define __LIBSTEEL_MTIMER__

#include "libsteel/globals.h"

// Struct providing access to RISC-V Steel MTimer Device registers
typedef struct
{
  // Control Register (CR). Address offset: 0x00
  volatile uint32_t CR;
  // Machine Time (MTIME) Register lowest 32 bits. Address offset: 0x04
  volatile uint32_t MTIMEL;
  // Machine Time (MTIME) Register highest 32 bits. Address offset: 0x08
  volatile uint32_t MTIMEH;
  // Machine Time Compare (MTIMECMP) Register lowest 32 bits. Address offset: 0x0c
  volatile uint32_t MTIMECMPL;
  // Machine Time Compare (MTIMECMP) Register highest 32 bits. Address offset: 0x10
  volatile uint32_t MTIMECMPH;
} MTimerDevice;

// Offset of the Counter Enable (EN) bit of the MTIME register
#define MTIMER_CR_EN_OFFSET 0U

// Mask used to read/set/clear the Counter Enable (EN) bit of the MTIME register
#define MTIMER_CR_EN_MASK (0x1U << MTIMER_CR_EN_OFFSET)

/**
 * @brief Enable MTIMER register counting. When counting is enabled, the value of MTIMER is
 * incremented by 1 at every rising edge of the `clock` signal.
 *
 * @param mtimer Pointer to the MTimerDevice
 */
inline void mtimer_enable(MTimerDevice *mtimer)
{
  SET_FLAG(mtimer->CR, MTIMER_CR_EN_MASK);
}

/**
 * @brief Disable MTIMER register counting. When counting is disabled, the value of MTIMER is held
 * constant.
 *
 * @param mtimer Pointer to the MTimerDevice
 */
inline void mtimer_disable(MTimerDevice *mtimer)
{
  CLR_FLAG(mtimer->CR, MTIMER_CR_EN_MASK);
}

/**
 * @brief Assign a new value for MTIMER register. The value can be assigned whether counting is
 * enabled or not.
 *
 * @param mtimer Pointer to the MTimerDevice
 * @param new_value The new 64-bit value for the MTIMER register
 */
inline void mtimer_set_counter(MTimerDevice *mtimer, uint64_t new_value)
{
  mtimer->MTIMEL = new_value & 0xFFFFFFFF;
  mtimer->MTIMEH = new_value >> 32;
}

/**
 * @brief Read the value of the MTIMER register.
 *
 * @param mtimer Pointer to the MTimerDevice
 * @return uint64_t
 */
inline uint64_t mtimer_get_counter(MTimerDevice *mtimer)
{
  uint32_t cnt_l = mtimer->MTIMEL;
  uint64_t cnt_h = mtimer->MTIMEH;
  return (cnt_h << 31) | cnt_l;
}

/**
 * @brief Set the value of the MTIMER register to 0 (zero).
 *
 * @param mtimer Pointer to the MTimerDevice
 */
inline void mtimer_clear_counter(MTimerDevice *mtimer)
{
  mtimer->MTIMEL = 0;
  mtimer->MTIMEH = 0;
}

/**
 * @brief Assign a new value for MTIMERCMP register.
 *
 * @param mtimer Pointer to the MTimerDevice
 * @param new_value The new 64-bit value for the MTIMERCMP register
 */
inline void mtimer_set_compare(MTimerDevice *mtimer, uint64_t new_value)
{
  /* Writing -1 to MTIMECMPL, writing the MSB word first and finally writing the LSB word prevents
   * spurious interrupts to be triggered due to the intermediate value held by the register during
   * the update.
   *
   * See RISC-V Specifications, v.2 (privileged architecture) pp. 45-46 */
  mtimer->MTIMECMPL = -1;
  mtimer->MTIMECMPH = new_value >> 32;
  mtimer->MTIMECMPL = new_value & 0xFFFFFFFF;
}

#endif // __LIBSTEEL_MTIMER__
