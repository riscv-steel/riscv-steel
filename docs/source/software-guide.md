# RISC-V Steel System-on-Chip IP </br><small>Software Guide</small>

## Introduction

In this guide you find instruction on how to write, compile and run software applications for RISC-V Steel SoC IP.

## Prerequisites

To compile, assemble and link programs for the RISC-V architecture you need the [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain). Follow the steps below to install and configure it for use with RISC-V Steel:

<h4>1. Get the source files</h4>

```
git clone https://github.com/riscv/riscv-gnu-toolchain
```

<h4>2. Install dependencies</h4>

=== "Ubuntu"

    ```
    sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
    ```

=== "Fedora/CentOS/RHEL OS"

    ```
    sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
    ```

=== "Arch Linux"

    ```
    sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat
    ```

=== "OS X"

    ```
    brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock
    ```

<h4>3. Configure it for RISC-V Steel</h4>

```
./configure --with-arch=rv32i --with-abi=ilp32 --prefix=/opt/riscv
```

<h4>4. Compile and install</h4>

```
make -j $(nproc)
```

## Building a new application

<h4>1. Make a copy of the software development template project.</h4>

The template project is all you need to start and is located at `riscv-steel/software-dev/template-project/`.

<h4>2. Edit the Makefile.</h4>

The template project comes with a Makefile to help you automate the tasks of compiling the software and generating a memory initialization file.

The beginning of the Makefile (reproduced below) contain the four variables you need to set to configure the project:

```
# Configure your project by setting the variables below
# -------------------------------------------------------------------------------------------------

# Name of the program to be created
PROGRAM_NAME      ?= main
# Memory size (must be set to the same value of the MEMORY_SIZE parameter of rvsteel_soc module)
MEMORY_SIZE       ?= 8192
# Path to RISC-V Steel API
RVSTEEL_API_DIR   ?= ../rvsteel-api
# The full path to RISC-V GNU Toolchain binaries in this machine + RISC-V binaries prefix
RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-

```

<h4>3. Write your application.</h4>

The template project comes with a `main.c` file containing a Hello World example. You can edit this file, rename it or delete it.

You can add as many source files to the project as you want. The Makefile was written so that all `*.c` source files you add to the project get automatically compiled when you run `make`.

To make it easier to develop your application, RISC-V Steel API provides function calls to configure and control the SoC IP. [Check it out](#rvsteel-api-reference) for more information.

<h4>4. Build your application.</h4>

Run `make` from the project root folder to build your application and generate a memory initialization file. A successfull build output is similar to this:

```
Building RISC-V Steel API: ok.
Making my_app.o: ok.
Making srcfile1.o: ok.
Making srcfile2.o: ok.
Linking my_app.elf: ok.

Generated files:
-- ELF executable   : build/my_app.elf
-- Disassembly      : build/my_app.objdump
-- Memory init file : build/my_app.hex

The memory size is set to 8192 bytes.
```

The generated `.hex` file can now be used to initialize RISC-V Steel SoC IP memory and run the application.

## Running the application

<h4>1. Specify the path to the memory initialization file</h4>

The SoC IP has a parameter called `MEMORY_INIT_FILE` that can be set when instantiating its top module. If you specify this parameter the RAM memory will be initialized with the contents of the memory file that you provided. 

In the example below (that you can find at `hello-world/arty-a7/hello-world-arty-a7.v`) an instance of the SoC IP for the [Digilent Arty-A7 FPGA board](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual) is configured to load a Hello World program:

```verilog
rvsteel_soc                  #(
    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (8192               ),
    .MEMORY_INIT_FILE         ("hello-world.hex"  ),
    .BOOT_ADDRESS             (32'h00000000       ))
rvsteel_soc_instance          ( 
    .clock                    (clock_50mhz        ),
    .reset                    (reset              ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            ));
```

<h4>2. Set the boot address (if needed)</h4>

If you did not use the template project for making your application then you'll need to set the `BOOT_ADDRESS` parameter to point to the entry symbol of your application.

The `BOOT_ADDRESS` parameter does not need to be set if you generated the memory init file with the template project Makefile. In this case, a small boot code is automatically added to your application and the linker script in the template project places this boot code at `0x00000000` (which is the default boot address).

<h4>3. Update the bitstream of your FPGA</h4>

After configuring the parameters of your instance of the SoC IP, generate a new bitstream and upload it to your FPGA. The application will start running automatically when you power up the board.

## RISC-V Steel API Reference

### Introduction

RISC-V Steel API is a set of function calls to configure and control RISC-V Steel SoC IP, making it easier to develop applications for it.

To use the API in your application you need to include  `rvsteel-api.h` in your source code:

```c
#include "rvsteel-api.h"

// ... your code ...
```

This header file is saved in the `software-dev/rvsteel-api/` folder along with its source code, `rvsteel-api.c`. The API is compiled and linked to your project by default if you use the template project.

The following sections contain detailed information about the available API calls.

### UART communication

#### uart_send_char { class="hide-h4"}

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

#### uart_send_string { class="hide-h4"}

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

#### uart_read_last_char { class="hide-h4"}

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

### Interrupt handling

#### irq_enable_all { class="hide-h4" }

`#!c void irq_enable_all();`
{ class="api-call" }

<div class="api-doc" markdown>
Enable external, timer and software interrupts by setting the global interrupt-enable bit in the <strong>mstatus</strong> CSR and the corresponding interrupt-enable bits in the <strong>mie</strong> CSR.

```c
// Example

irq_enable_all();
```
</div>

#### irq_disable_all { class="hide-h4" }

`#!c void irq_disable_all();`
{ class="api-call" }

<div class="api-doc" markdown>
Disable external, timer and software interrupts by clearing the global interrupt-enable bit in the <strong>mstatus</strong> CSR and the corresponding interrupt-enable bits in the <strong>mie</strong> CSR.

```c
// Example

irq_disable_all();
```
</div>

#### irq_set_interrupt_handler { class="hide-h4" }

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

### Miscellaneous

#### busy_wait { class="hide-h4" }

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