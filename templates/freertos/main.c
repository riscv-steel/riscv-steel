// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"
#include <FreeRTOS.h>
#include <task.h>

#define MTIMER_CONTROLLER_ADDR (MTimerController *)0x80010000
#define GPIO_CONTROLLER_ADDR (GpioController *)0x80020000

extern void freertos_risc_v_mtimer_interrupt_handler();
extern void freertos_risc_v_exception_handler();

// FreeRTOS heap
uint8_t ucHeap[configTOTAL_HEAP_SIZE];

// Override the trap handler for Machine Timer Interrupts: make it call FreeRTOS MTimer interrupt
// handler.
__NAKED void mti_irq_handler()
{
  freertos_risc_v_mtimer_interrupt_handler();
}

// Override the default trap handler (for non-vectored mode): make it call FreeRTOS exception
// handler.
__NAKED void default_trap_handler()
{
  freertos_risc_v_exception_handler();
}

// Task 1: toggle LED #0 each 500ms
void task1(void *pvParameters)
{
  configASSERT((uint32_t)pvParameters == 1UL);
  for (;;)
  {
    vTaskDelay(250);
    gpio_set(GPIO_CONTROLLER_ADDR, 0);
    vTaskDelay(250);
    gpio_clear(GPIO_CONTROLLER_ADDR, 0);
  }
}

// Task 2: toggle LED #1 each 1000ms
void task2(void *pvParameters)
{
  configASSERT((uint32_t)pvParameters == 1UL);
  for (;;)
  {
    vTaskDelay(1000);
    gpio_set(GPIO_CONTROLLER_ADDR, 1);
    vTaskDelay(1000);
    gpio_clear(GPIO_CONTROLLER_ADDR, 1);
  }
}

int main(void)
{
  csr_enable_vectored_mode_irq();
  mtimer_enable(MTIMER_CONTROLLER_ADDR);

  gpio_set_output(GPIO_CONTROLLER_ADDR, 0);
  gpio_set_output(GPIO_CONTROLLER_ADDR, 1);

  xTaskCreate(task1, "task1", configMINIMAL_STACK_SIZE, (void *)1, 1, NULL);
  xTaskCreate(task2, "task2", configMINIMAL_STACK_SIZE, (void *)1, 1, NULL);

  vTaskStartScheduler();

  while (1)
    ;
}