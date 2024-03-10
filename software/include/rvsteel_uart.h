// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_UART__
#define __RVSTEEL_UART__

#include "rvsteel_globals.h"

// UART Device Memory Map
typedef struct
{
  volatile uint32_t WDATA;
  volatile uint32_t RDATA;
  volatile uint32_t READY;
} UartDevice;

/**
 * @brief Read register READY from the UART device. Return true if the device is ready to send
 * data, false otherwise.
 *
 * @param uart Pointer to the UartDevice
 * @return true
 * @return false
 */
inline bool uart_ready(UartDevice *uart)
{
  return uart->READY == 1;
}

/**
 * @brief Read register RDATA of the UART device. The UART requests an interrupt when it
 * completes receiving new data. The new data can be read by calling this function.
 *
 * @param uart Pointer to the UartDevice
 * @return uint8_t
 */
inline uint8_t uart_read(UartDevice *uart)
{
  return uart->RDATA;
}

/**
 * @brief Write a single byte to register WDATA of the UART device. It awaits the UART to be ready
 * before writing to the register.
 *
 * @param uart Pointer to the UartDevice
 * @param data A byte as uint8_t
 */
inline void uart_write(UartDevice *uart, uint8_t data)
{
  while (!uart_ready(uart))
    ;
  uart->WDATA = data;
}

/**
 * @brief Send a C-string over the UART device.
 *
 * @param uart Pointer to the UartDevice
 * @param str A null-terminated C-string
 */
inline void uart_write_string(UartDevice *uart, const char *str)
{
  while (*(str) != '\0')
  {
    uart_write(uart, *(str));
    str++;
  }
}

#endif // __RVSTEEL_UART__
