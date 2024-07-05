# RISC-V Steel Software Guide { class="main-section-title" }
<h2 class="main-section-subtitle">LibSteel Reference - UART communication</h2>

The function calls to send and receive data over the UART controller of RISC-V Steel MCU are described in this page.  

All function calls take as their first argument a pointer to a struct providing access to the UART controller registers. A pointer to the UART present by default in RISC-V Steel MCU is declared in the `libsteel.h` header file as follows:

```
#define RVSTEEL_UART ((UartDevice *)0x80000000)
```

If you add extra UARTs to RISC-V Steel MCU you need to declare them in your code:

```
#define MY_EXTRA_UART ((UartDevice*)0x12345678)
```

The macro can then be passed as argument to the API calls. For example:

```
uart_write_string(MY_EXTRA_UART, "Hello my extra UART");
```

#### uart_send_char { class="api-hidden" }

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

#### uart_send_string { class="api-hidden" }

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

#### uart_read_last_char { class="api-hidden" }

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

</br>
</br>