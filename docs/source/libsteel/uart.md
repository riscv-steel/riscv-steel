# UART Controller

## Introduction

RISC-V Steel [Microcontroller IP](../hardware/mcu.md) comes with a default UART controller that can be used to send and receive data via [UART protocol](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter). This default UART is configured to send 1 start bit, 8 data bits, no parity bit and no stop bit. The base address of the default controller registers is `0x80000000`.

The default baud rate is 9600 bps. The baud rate can be increased or decreased by changing the [`UART_BAUD_RATE`](../hardware/mcu.md#configuration-parameters) parameter of the Microcontroller IP.

The default UART is connected to [Fast Interrupt #0](../hardware/core.md#fast-interrupts). An interrupt is requested whenever a new byte of data is received.

Additional UART controllers can be added to the Microcontroller IP by following the procedure described in [Adding new devices](../hardware/mcu.md#adding-new-devices).

## General information

The `libsteel.h` header provides functions for sending and receiving data via UART protocol. All UART-related functions have names starting with `uart_*` and take as their first argument a pointer to the base address of the UART controller registers.

For example:

```c
#include "libsteel.h"

void main(void)
{
    // 0x80000000 is the base address of the
    // default UART controller registers
    uart_write_string((UartController *)0x80000000, "Hello World!");
}
```

Macros can be defined to avoid having to type the controller addresses every time, an also to make it easier to distinguish between multiple UARTs:

```c
#include "libsteel.h"

#define DEFAULT_UART (UartController *)0x80000000

// Suppose you added an extra UART mapped to address 0x90000000
#define MY_EXTRA_UART (UartController *)0x90000000

void main(void)
{
    uart_write_string(DEFAULT_UART, "Something.");
    uart_write_string(MY_EXTRA_UART, "Something else.");
}
```

To check if new data has been received, polling or interrupts can be used (see the examples in the description of [`uart_read`](#uart_read)).

## UART API Reference 

### uart_data_received { .hide-api-call }

__Function `uart_data_received`{ .api-call-title }__

```c
bool uart_data_received(UartController *uart);
```

Checks whether the UART controller pointed by `uart` has received new data. Return `true` if new data has been received, and `false` otherwise.

Use [`uart_read`](#uart_read) to read the new data.

_Parameters:_

`uart` - The base address of the UART controller registers.

=== "Example"

    ```c hl_lines="7"
    #include "libsteel.h"

    #define DEFAULT_UART (UartController *)0x80000000

    // A silly application that echoes back everything it receives
    void main(void)
    {
      while (1)
      {
        if (uart_data_received(DEFAULT_UART))
        {
          char rx = uart_read(DEFAULT_UART);
          uart_write(DEFAULT_UART, rx);
        }
      }
    }
    ```

### uart_read { .hide-api-call }

__Function `uart_read`{ .api-call-title }__

```c
uint8_t uart_read(UartController *uart);
```

Read the data byte received via the UART controller pointed by `uart`. To check whether new data has been received, use [`uart_data_received`](#uart_data_received).

The call to `uart_read` turns off pending interrupt requests made by the UART.

_Parameters:_

`uart` - The base address of the UART controller registers.

=== "Example (Polling)"

    ```c hl_lines="14"
    #include "libsteel.h"

    #define DEFAULT_UART (UartController *)0x80000000

    // Polls the UART controller whether new data was received
    void main(void)
    {
      uart_write_string(DEFAULT_UART, "RISC-V Steel - UART example"
                                      "\n\nType something and press Enter:\n");
      while (1)
      {
        if (uart_data_received(DEFAULT_UART))
        {
          char rx = uart_read(DEFAULT_UART);
          if (rx == '\r') // Enter key
            uart_write_string(DEFAULT_UART, "\n\nType something else"
                                            " and press Enter again: ");
          else if (rx < 127) // Echo back printable characters
            uart_write(DEFAULT_UART, rx);
        }
      }
    }
    ```

=== "Example (Interrupts)"

    ```c hl_lines="9"
    #include "libsteel.h"

    #define DEFAULT_UART (UartController *)0x80000000

    // UART interrupt signal is connected to Fast IRQ #0
    // This overrides the Fast IRQ #0 Handler
    __NAKED void fast0_irq_handler(void)
    {
      char rx = uart_read(DEFAULT_UART);
      if (rx == '\r') // Enter key
        uart_write_string(DEFAULT_UART, "\n\nType something else "
                                        "and press enter: ");
      else if (rx < 127) // Echo back printable characters
        uart_write(DEFAULT_UART, rx);
      __ASM_VOLATILE("mret");
    }

    // In this example, vectored interrupts are enabled. The Fast IRQ #0 line,
    // used by the default UART, is also enabled.
    // The main function enters into an infinite loop waiting for UART interrupts
    void main(void)
    {
      uart_write_string(DEFAULT_UART, "RISC-V Steel - UART demo");
      uart_write_string(DEFAULT_UART, "\n\nType something and press Enter:\n");
      csr_enable_vectored_mode_irq();
      CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
      csr_global_enable_irq();
      while (1)
        ;
    }
    ```

### uart_ready_to_send { .hide-api-call }

__Function `uart_ready_to_send`{ .api-call-title }__

```c
bool uart_ready_to_send(UartController *uart);
```

Checks whether the UART controller pointed by `uart` is ready to send data. Return `true` if it is ready, and `false` otherwise.

_Parameters:_

`uart` - The base address of the UART controller registers.

=== "Example"

    ```c hl_lines="7"
    #include "libsteel.h"

    #define DEFAULT_UART (UartController *)0x80000000

    void main(void)
    {
      if (uart_ready_to_send(DEFAULT_UART))
      {
        uart_write_string(DEFAULT_UART, "Hi.");
      }
    }
    ```

### uart_write { .hide-api-call }

__Function `uart_write`{ .api-call-title }__

```c
void uart_write(UartController *uart, uint8_t data);
```

Send a single byte of data via the UART controller pointed by `uart`. If the UART is busy, it awaits for the current transfer to complete before sending the data.

_Parameters:_

`uart` - The base address of the UART controller registers.

`data` - The byte of data to be sent.

=== "Example"

    ```c hl_lines="6"
    #include "libsteel.h"

    void main(void)
    {
      // Send the new-line character
      uart_write((UartController *)0x80000000, '\n');
    }
    ```


### uart_write_string { .hide-api-call }

__Function `uart_write_string`{ .api-call-title }__

```c
void uart_write_string(UartController *uart, const char *str);
```

Send a C-string via the UART controller pointed by `uart`. If the UART is busy, it awaits for the current transfer to complete before sending the data.

_Parameters:_

`uart` - The base address of the UART controller registers.

`str` - The C-string to be sent. The string must be null-terminated, however, the null character at the end is not sent.

=== "Example"

    ```c hl_lines="5"
    #include "libsteel.h"

    void main(void)
    {
      uart_write_string((UartController *)0x80000000, "Hello World!");
    }
    ```

</br>
</br>