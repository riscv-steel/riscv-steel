// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 12000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

// Pointer to GPIO0 controller register block.
RvxGpio *const gpio0 = RVX_GPIO0_BASE;

// Pointer to UART0 controller register block.
RvxUart *const uart0 = RVX_UART0_BASE;

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud (12000000 / 9600 = 1250)
  rvx_uart_set_clock_divider(uart0, 1250U);

  // Print welcome message
  rvx_uart_print(uart0, "RVX GPIO Example Project\n\n");
  rvx_uart_print(uart0, "Press push-button 1 to toggle LED 0 on/off.\n");

  // Configure pin 0 (LED 1) as output, pin 1 (push-button 1) as input
  rvx_gpio_pin_direction(gpio0, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_direction(gpio0, 1, RVX_GPIO_INPUT);

  // Turn LED 0 ON initially
  RvxGpioPinLevel led_level = RVX_GPIO_HIGH;
  rvx_gpio_pin_write(gpio0, 0, led_level);

  while (true)
  {
    // Wait the push-button to be pressed
    while (rvx_gpio_pin_read(gpio0, 1) == RVX_GPIO_LOW)
      ;

    // Toggle LED state
    led_level = (led_level == RVX_GPIO_HIGH) ? RVX_GPIO_LOW : RVX_GPIO_HIGH;
    rvx_gpio_pin_write(gpio0, 0, led_level);

    // Wait the push-button to be released
    while (rvx_gpio_pin_read(gpio0, 1) == RVX_GPIO_HIGH)
      ;
  }
}