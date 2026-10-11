// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 50000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

// Pointer to UART0 controller register block.
RvxUart *const uart0 = RVX_UART0_BASE;

void main()
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud (rvx_setup.clock_frequency / 5208 ~= 9600)
  rvx_uart_set_clock_divider(uart0, 5208);

  // Send "Hello World, RVX!" message
  rvx_uart_print(uart0, "Hello World, RVX!\n");
}