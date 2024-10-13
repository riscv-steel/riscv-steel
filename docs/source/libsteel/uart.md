# UART Controller

## Introduction

RISC-V Steel features a default [UART Controller](../hardware/uart.md) designed for sending and receiving data via the [UART Protocol](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter). The configuration parameters for this default UART are as follows:

- **Start Bits**: 1
- **Data Bits**: 8
- **Parity Bit**: None
- **Stop Bits**: None
- **Baud Rate**: 9600 bps

The baud rate can be increased or decreased by changing the [`UART_BAUD_RATE`](../hardware/index.md#configuration) parameter of RISC-V Steel top module.

The base address of the default UART registers is `0x80000000`. 

Additional UARTs can be added to RISC-V Steel by following the procedure described in the [Adding Devices](../hardware/index.md#adding-devices) section.

The UART-related functions are prefixed with `uart_` and take a pointer of type `UartController*` as their first argument. This pointer must contain the base address of the UART registers.

For improved code readability, it is recommended to define macros for the UART addresses as shown in the example below:

=== "Example"

    ```c
    #include "libsteel.h"

    // The default UART of RISC-V Steel
    #define DEFAULT_UART (UartController *)0x80000000

    // Suppose you added an extra UART and mapped it to address 0x90000000
    #define ADDITIONAL_UART (UartController *)0x90000000

    void main(void)
    {        
        uart_write_string(DEFAULT_UART, "Hello World!");
        uart_write_string(ADDITIONAL_UART, "Ola mundo!");
    }
    ```

<div id="api-reference" markdown>

## LibSteel UART API

### uart_data_received { .hide-api-call }

```c title="Function uart_data_received"
bool uart_data_received(UartController *uart)
```

<div class="api-doc-text" markdown>

Checks whether the UART has received new data. Return `true` if new data has been received, and `false` otherwise.

_Parameters:_

`uart` - The base address of the UART registers.

</div>

=== "Example"

    ```c
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

---

### uart_read { .hide-api-call }

```c title="Function uart_read"
uint8_t uart_read(UartController *uart)
```

<div class="api-doc-text" markdown>

Read the data byte received by the UART, turning off pending interrupt requests.

_Parameters:_

`uart` - The base address of the UART registers.

</div>

=== "Example (Polling)"

    ```c
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

    ```c
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

---

### uart_ready_to_send { .hide-api-call }

```c title="Function uart_ready_to_send"
bool uart_ready_to_send(UartController *uart)
```

<div class="api-doc-text" markdown>

Checks whether the UART is ready to send data. Return `true` if it is ready, and `false` otherwise.

_Parameters:_

`uart` - The base address of the UART registers.

</div>

=== "Example"

    ```c
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

---

### uart_write { .hide-api-call }

```c title="Function uart_write"
void uart_write(UartController *uart, uint8_t data)
```

<div class="api-doc-text" markdown>

Send a single byte of data. If the UART is busy, it awaits for the current transfer to complete before sending the data.

_Parameters:_

`uart` - The base address of the UART registers.

`data` - The byte of data to be sent.

</div>

=== "Example"

    ```c
    #include "libsteel.h"

    void main(void)
    {
      // Send the new-line character
      uart_write((UartController *)0x80000000, '\n');
    }
    ```

---

### uart_write_string { .hide-api-call }

```c title="Function uart_write_string"
void uart_write_string(UartController *uart, const char *str)
```

<div class="api-doc-text" markdown>

Send a null-terminated C-string. If the UART is busy, it awaits for the current transfer to complete before sending the data.

The string must be null-terminated, however, the null character at the end is not sent.

_Parameters:_

`uart` - The base address of the UART registers.

`str` - The C-string to be sent.

</div>

=== "Example"

    ```c
    #include "libsteel.h"

    void main(void)
    {
      uart_write_string((UartController *)0x80000000, "Hello World!");
    }
    ```

</div>

</br>
</br>