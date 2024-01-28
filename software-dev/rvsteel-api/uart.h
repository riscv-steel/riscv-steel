// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __UART__
#define __UART__

#include <stdint.h>
#include "rvsteel-api.h"

// Machine Timer Registers
typedef struct
{
  __IO uint32_t TX;
  __IO uint32_t RX;
} UART_TypeDef;


__STATIC_INLINE uint8_t read(UART_TypeDef *UARTx)
{
  return UARTx->RX;
}

__STATIC_INLINE void write(UART_TypeDef *UARTx, uint8_t data)
{
  UARTx->TX = data;
}

#endif // __UART__
