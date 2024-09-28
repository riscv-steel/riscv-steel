# GPIO Controller

## Introduction

RISC-V Steel [Microcontroller IP](../hardware/mcu.md) comes with a default [GPIO controller](https://en.wikipedia.org/wiki/General-purpose_input/output) providing up to 32 General Purpose Input/Output pins. 

The number of GPIO pins provided by the default GPIO controller can be adjusted by changing the [`GPIO_WIDTH`](../hardware/mcu.md#configuration-parameters) parameter of the Microcontroller IP. By default, the value of `GPIO_WIDTH` is 1. The base address of the default GPIO controller registers is `0x80020000`.

Additional GPIO controllers can be added to the Microcontroller IP by following the procedure described in [Adding new devices](../hardware/mcu.md#adding-new-devices).

## General information

The GPIO-related functions have names starting with `gpio_*` and take as their first argument a pointer to the base address of the GPIO controller registers.

For example:

```c
#include "libsteel.h"

void main(void)
{
    // 0x80020000 is the base address of the
    // default GPIO controller registers
    gpio_set_output((GpioController *)0x80020000, 0);
    gpio_write((GpioController *)0x80020000, 0, HIGH);
}
```

Macros can be defined to avoid having to type the controller addresses every time, an also to make it easier to distinguish between multiple GPIO controllers:

```c
#include "libsteel.h"

#define DEFAULT_GPIO (GpioController *)0x80000000

// Suppose you added an extra GPIO mapped to address 0x90020000
#define MY_EXTRA_GPIO (GpioController *)0x90000000

void main(void)
{
    gpio_set_output(DEFAULT_GPIO, 0);    
    gpio_write(DEFAULT_GPIO, 0, HIGH);
    gpio_set_input(MY_EXTRA_GPIO, 0);
    uint32_t button_state = gpio_read(MY_EXTRA_GPIO, 0);
}
```

## GPIO API Reference 