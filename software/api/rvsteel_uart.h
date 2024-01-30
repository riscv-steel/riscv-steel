// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __UART__
#define __UART__

#include <stdint.h>
#include "rvsteel_api.h"

// Machine Timer Registers
typedef struct
{
  __IO uint32_t TX;
  __IO uint32_t RX;
} UART_TypeDef;

__STATIC_INLINE uint8_t uart_read(UART_TypeDef *UARTx)
{
  return UARTx->RX;
}

__STATIC_INLINE void uart_write(UART_TypeDef *UARTx, uint8_t data)
{
  UARTx->TX = data;
}

__STATIC_INLINE int uart_write_busy(UART_TypeDef *UARTx)
{
  return UARTx->TX != 1;
}

__STATIC_INLINE void uart_send_char(UART_TypeDef *UARTx, const char c)
{
  while ((UARTx->TX != 1))
  {
    __NOP();
  }

  UARTx->TX = c;
}

__STATIC_INLINE void uart_send_string(UART_TypeDef *UARTx, const char *str)
{
  while (*(str) != '\0')
  {
    uart_send_char(UARTx, *(str));
    str++;
  }
}

#endif // __UART__
