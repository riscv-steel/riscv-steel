/**************************************************************************************************

MIT License

Copyright (c) 2020-present Rafael Calcada

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**************************************************************************************************/

#include "rvsteel.h"

#ifndef MEMORY_SIZE
#define __R5_MEM_SIZE "8192"
#else
#define __R5_MEM_SIZE MEMORY_SIZE
#endif

// Boot code. Set the memory size, the return address, the stack pointer and
// the interrupt handler
asm(".section .boot, \"ax\";              \
    .global _start;                       \
    _start:                               \
      la ra, _start;                      \
      la sp, " __R5_MEM_SIZE ";           \
      la t0, __r5_irq_handler;            \
      csrw mtvec, t0;                     \
      j main;                             \
    __r5_irq_handler:                     \
      la t0, __R5_IRQ_HANDLER;            \
      lw t1, 0(t0);                       \
      jalr ra, t1, 0;                     \
      mret;                               ");

// Address for sending data to UART
volatile char *__R5_UART_TX = (volatile char *)0x80000000;

// Address for receiving data from UART
volatile char *__R5_UART_RX = (volatile char *)0x80000004;

// Address of the interrupt handler
volatile void *__R5_IRQ_HANDLER = (volatile void *)0x00000000;

void r5_uart_send_char(const char c)
{
  while ((*__R5_UART_TX) != 1);
  *(__R5_UART_TX) = c;
}

void r5_uart_send_string(const char *str)
{
  while (*(str) != '\0')
  {
    r5_uart_send_char(*(str));
    str++;
  }
}

volatile char r5_uart_receive_char()
{
  return (*__R5_UART_RX);
}

void r5_irq_enable_all()
{
  asm("sw t0, -4(sp); li t0, 0xffffffff; csrw mstatus, t0; csrw mie, t0; lw t0, -4(sp);");
}

void r5_irq_disable_all()
{
  asm("sw t0, -4(sp); li t0, 0x00000000; csrw mstatus, t0; csrw mie, t0; lw t0, -4(sp);");
}

void r5_irq_set_interrupt_handler(void (*interrupt_handler)())
{
  __R5_IRQ_HANDLER = (volatile void *)interrupt_handler;
}

void r5_busy_wait()
{
  while (1);
}