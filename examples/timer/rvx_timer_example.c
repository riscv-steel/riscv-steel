// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 12000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

// PointerS to peripheral register blocks.
RvxUart *const uart0 = RVX_UART0_BASE;
RvxGpio *const gpio0 = RVX_GPIO0_BASE;
RvxTimer *const timer0 = RVX_TIMER0_BASE;
RvxPlic *const plic0 = RVX_PLIC0_BASE;

// Custom interrupt handler for the TIMER0 interrupt
void rvx_interrupt_handler(const uint32_t interrupt_cause)
{
  if (interrupt_cause == RVX_CAUSE_EXTERNAL_IRQ_M)
  {
    uint32_t source_id = rvx_plic_claim_source(plic0);
    if (source_id == RVX_PLIC0_SOURCE_TIMER0)
    {
      // Toggle LED 1 state (connected to GPIO pin 0)
      RvxGpioPinLevel led_level = rvx_gpio_pin_read(gpio0, 0);
      rvx_gpio_pin_write(gpio0, 0, !led_level);

      // Reset the counter
      rvx_timer_reset_counter(timer0);
    }
  }
}

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud (rvx_setup.clock_frequency / 1250 = 9600)
  rvx_uart_set_clock_divider(uart0, 1250U);

  // Print welcome message
  rvx_uart_print(uart0, "RVX Timer Example Project\n\n");
  rvx_uart_print(uart0, "LED 0 state will be toggled by the timer every second.\n");

  // Configure pin 0 (LED 1) as output and turn it on initially
  rvx_gpio_pin_direction(gpio0, 0, RVX_GPIO_OUTPUT);
  rvx_gpio_pin_write(gpio0, 0, RVX_GPIO_HIGH);

  // Configure the machine timer to generate an interrupt every 1 second
  rvx_timer_stop_counter(timer0);
  rvx_timer_set_compare(timer0, rvx_setup.clock_frequency);

  // Enable the TIMER0 interrupt in the PLIC and set it to maximum priority
  rvx_plic_enable_source(plic0, RVX_PLIC0_SOURCE_TIMER0);
  rvx_plic_set_priority(plic0, RVX_PLIC0_SOURCE_TIMER0, RVX_PLIC_MAX_PRIORITY);

  // Enable interrupts in M-mode
  rvx_interrupt_enable_m();

  // Reset and start the timer counter
  rvx_timer_reset_counter(timer0);
  rvx_timer_start_counter(timer0);

  while (1) // Wait for a timer interrupt
    ;
}