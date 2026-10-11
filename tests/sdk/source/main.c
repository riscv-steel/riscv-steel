// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

extern const RvxTestSuiteDescriptor rvx_sdk_uart_test_suite;
extern const RvxTestSuiteDescriptor rvx_sdk_gpio_test_suite;
extern const RvxTestSuiteDescriptor rvx_sdk_spi_test_suite;
extern const RvxTestSuiteDescriptor rvx_sdk_timer_test_suite;

static const RvxTestSuiteDescriptor *const rvx_sdk_test_suites[] = {
    &rvx_sdk_uart_test_suite,
    &rvx_sdk_gpio_test_suite,
    &rvx_sdk_spi_test_suite,
    &rvx_sdk_timer_test_suite,
};

static const size_t rvx_sdk_test_suite_count = RVX_ARRAY_SIZE(rvx_sdk_test_suites);

const RvxSetup rvx_setup = {.clock_frequency = 50000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

extern void rvx_timer_interrupt_handler(void);
extern void rvx_uart0_interrupt_handler(void);

// Interrupt handler for the SDK tests.
// Dispatches to the appropriate peripheral-specific handler based on the cause code.
void rvx_interrupt_handler(const uint32_t cause)
{
  if (cause == RVX_TRAP_CAUSE_TIMER_IRQ_M)
    rvx_timer_interrupt_handler();
  else if (cause == RVX_TRAP_CAUSE_EXTERNAL_IRQ_M)
  {
    const uint8_t source_id = rvx_plic_claim_source(RVX_PLIC0_BASE);
    if (source_id == RVX_PLIC0_SOURCE_UART0)
      rvx_uart0_interrupt_handler();
  }
}

int main(void)
{
  rvx_init(&rvx_setup);
  const bool all_tests_passed = rvx_test_run_suites(rvx_sdk_test_suites, rvx_sdk_test_suite_count);

  if (all_tests_passed)
    rvx_uart_print(RVX_UART0_BASE, "\nPassed all RVX SDK tests.\n\n");
  else
    rvx_uart_print(RVX_UART0_BASE, "\nERROR: Some RVX SDK tests failed. Check the test output for details.\n\n");

  volatile uint32_t *const simulator_status = (volatile uint32_t *)0x00000000;
  *simulator_status = all_tests_passed ? 0U : 1U;

  return all_tests_passed ? 0 : 1;
}