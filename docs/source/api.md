# RISC-V Steel API

RISC-V Steel API is a set of function calls to configure and control RISC-V Steel SoC IP, making it easier to develop applications for it.

To start using the API in your application you must include the `rvsteel-api.h` header in your source code:

```c
#include "rvsteel-api.h"

// ... your code ...
```

This header file is saved in the `software-dev/rvsteel-api/` folder along with its source code, `rvsteel-api.c`. The API is compiled and linked to your project by default if you use the template project (located in `software-dev/template-project/`).

The following sections contain detailed information about the available API calls.

## UART communication

`#!c void uart_send_char(const char c);`
{ class="api-call" }

<div class="api-doc" markdown>
Send character <strong>c</strong> over the UART.

This is a blocking call, that is, the execution of the program is halted until the UART finishes sending the data.

```c
// Example

uart_send_char('\n');
```
</div>

`#!c void uart_send_string(const char *str);`
{ class="api-call" }

<div class="api-doc" markdown>
Send the null-terminated C-string <strong>str</strong> over the UART.

This is a blocking call, that is, the execution of the program is halted until the UART finishes sending the data.

```c
// Example

uart_send_string("Hello World!");
```
</div>

`#!c volatile char uart_read_last_char();`
{ class="api-call" }

<div class="api-doc" markdown>
Return the last character received by the UART. The null character `'\0'` is returned if no character was received since power up.

This is a non-blocking call.

```c
// Example

if (uart_read_last_char() == '\n')
{
  uart_send_string("Last received character is new line.");
}
```
</div>

## Interrupt handling

`#!c void irq_enable_all();`
{ class="api-call" }

<div class="api-doc" markdown>
Enable external, timer and software interrupts by setting the global interrupt-enable bit in the <strong>mstatus</strong> CSR and the corresponding interrupt-enable bits in the <strong>mie</strong> CSR.

```c
// Example

irq_enable_all();
```
</div>

`#!c void irq_disable_all();`
{ class="api-call" }

<div class="api-doc" markdown>
Disable external, timer and software interrupts by clearing the global interrupt-enable bit in the <strong>mstatus</strong> CSR and the corresponding interrupt-enable bits in the <strong>mie</strong> CSR.

```c
// Example

irq_disable_all();
```
</div>

`#!c void irq_set_interrupt_handler(void (*interrupt_handler)());`
{ class="api-call" }

<div class="api-doc" markdown>
Set the interrupt handler, a routine called everytime an interrupt is accepted.

The interrupt handler routine must be a `void` function with no arguments.

```c hl_lines="13"
// Example

void my_custom_interrupt_handler()
{
  // simply echoes back the received character
  char c = uart_read_last_char();
  uart_send_char(c);
}

int main()
{
  uart_send_string("Hello! Type something (it will be echoed back): ");
  irq_set_interrupt_handler(my_custom_interrupt_handler)
  irq_enable_all();
  busy_wait();
}
```
</div>

## Miscellaneous

`#!c void busy_wait();`
{ class="api-call" }

<div class="api-doc" markdown>

Enter into an infinite loop that can only be stopped by an interrupt request.

Make sure interrupts are enabled before calling this method (see [**`irq_enable_all`**](#irq_enable_all)).

```c hl_lines="15"
// Example

void my_custom_interrupt_handler()
{
  // simply echoes back the received character
  char c = uart_read_last_char();
  uart_send_char(c);
}

int main()
{
  uart_send_string("Hello! Type something (it will be echoed back): ");
  irq_set_interrupt_handler(my_custom_interrupt_handler)
  irq_enable_all();
  busy_wait();
}
```
</div>

</br>
</br>