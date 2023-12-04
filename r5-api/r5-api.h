/**************************************************************************************************

MIT License

Copyright (c) 2020 - present Rafael Calcada

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

#ifndef __R5_API__
#define __R5_API__

/// Send a single character over the UART
void r5_uart_send_char(const char c);

/// Send a C-string over the UART
void r5_uart_send_string(const char *str);

/// Return the last character received over the UART
volatile char r5_uart_receive_char();

/// Enable external, timer and software interrupts
void r5_irq_enable_all();

/// Disable external, timer and software interrupts
void r5_irq_disable_all();

/// Sets the function to be called on interrupts
void r5_irq_set_interrupt_handler(void (*interrupt_handler)());

/// Enter into an infinite loop that can only be stopped by an interrupt
/// request. Make sure interrupts are enabled before calling this method.
/// You can enable all types of interrupt by calling r5_irq_enable_all().
void r5_busy_wait();

#endif