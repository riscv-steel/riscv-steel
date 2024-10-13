# GPIO Controller

## Introduction

RISC-V Steel features a default [GPIO Controller](../hardware/gpio.md) that provides up to 32 General Purpose Input/Output (GPIO) pins. 

The number of GPIO pins can be adjusted by modifying the [`GPIO_WIDTH`](../hardware/index.md#configuration) parameter of RISC-V Steel top module, which is set to 1 by default.

The base address of the default GPIO registers is `0x80020000`.

Additional GPIO controllers can be added to RISC-V Steel by following the procedure described in the [Adding Devices](../hardware/index.md#adding-devices) section.

The GPIO-related functions are prefixed with `gpio_` and take a pointer of type `GpioController*` as their first argument. This pointer must contain the base address of the GPIO registers.

For improved code readability, it is recommended to define macros for the GPIO addresses as shown in the example below:

=== "Example"

    ```c
    #include "libsteel.h"

    // The default GPIO of RISC-V Steel
    #define DEFAULT_GPIO (GpioController *)0x80020000

    // Suppose you added an extra GPIO and mapped it to address 0x90020000
    #define ADDITIONAL_GPIO (GpioController *)0x90020000

    void main(void)
    {        
        gpio_set_input(DEFAULT_GPIO, 0);
        uint32_t default_gpio_pin0_value = gpio_read(DEFAULT_GPIO, 0);
        gpio_set_output(ADDITIONAL_GPIO, 1);
        gpio_write(ADDITIONAL_GPIO, 1, default_gpio_pin0_value);
    }
    ```

## LibSteel GPIO API 