# UART Controller

## Introduction

RISC-V Steel [Microcontroller IP](../hardware/mcu.md) comes with a default UART controller that can be used to send and receive data via [UART protocol](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter). This default UART is configured to send 1 start bit, 8 data bits, no parity bit and no stop bit. The base address of this controller registers is `0x80000000`.

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
    // 0x80000000 is the base address of the UART controller registers
    uart_write_string((UartController *)0x80000000, "Hello World!");
}
```

A macro can be defined to avoid having to type the controller address every time, an also to make it easier to distinguish between multiple UARTs:

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

## UART API Reference 

### uart_write { .hide-api-call }

__Function `uart_write`{ .api-call-title }__

```c
void uart_write(UartController *uart, uint8_t data);
```

Send a single byte of `data` via the UART controller pointed by `uart`.

If the UART is busy, it awaits for the current transfer to complete before sending the data.

=== "Example"

    ```c
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

Send a C-string via the UART controller pointed by `uart`. The string must be null-terminated.

If the UART is busy, it awaits for the current transfer to complete before sending the data.

=== "Example"

    ```c
    #include "libsteel.h"

    void main(void)
    {
        uart_write_write((UartController *)0x80000000, "Hello World!");
    }
    ```

</br>
</br>