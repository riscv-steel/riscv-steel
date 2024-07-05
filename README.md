<p align="center"><img src="docs/source/images/rvsteel_logo_circle.svg" width="70"/></br><strong>RISC-V Steel</strong></p>

RISC-V Steel is a free collection of hardware modules written in Verilog intended for use in FPGAs and embedded systems. It features a 32-bit RISC-V processor core, UART, GPIO and SPI interfaces, and timer and memory modules. All modules are integrated into a tunable microcontroller design that can be easily ported to any FPGA in just a few steps.

- [Documentation Page](https://riscv-steel.github.io/riscv-steel)

## Features

- 32-bit RISC-V processor core (RV32I + Zicsr + Machine mode)
- UART, GPIO and SPI interfaces
- Timer and memory modules
- Support for real-time operating systems like FreeRTOS
- LibSteel library, which provides an API to control RISC-V Steel

## Getting Started

This getting started guide will show you how to use RISC-V Steel to create a Hello World system for your FPGA. This example system is a simple embedded application that sends a *Hello World!* message through the UART interface of RISC-V Steel. You will be able to see this message on your computer with the help of a serial terminal emulator (PySerial) after programming the FPGA.

After you finish this guide you will have a basic environment that you can use to create larger projects.

### 1. Download RISC-V Steel

First of all, download RISC-V Steel by running:

```
git clone https://github.com/riscv-steel/riscv-steel
```

### 2. Download and install the RISC-V GNU Toolchain

The [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) is a set of compilers and software development tools for the RISC-V architecture. You need it to compile the C program written for the Hello World system.

*2.1. Get the RISC-V GNU Toolchain*

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
```

*2.2. Install dependencies on your operating system*

```bash
# Ubuntu
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev

# Fedora/CentOS/Rocky/RHEL
sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel

# Arch Linux
sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat libslirp

# OS X
brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp
```

*2.3. Configure the toolchain for RISC-V Steel and install it*

```bash
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32izicsr --with-abi=ilp32
make
```
**Tip**: Change the `--prefix` argument to install the toolchain in a different folder.

### 3. Build the Hello World example

The software project for the Hello World system is saved in `examples/hello_world/software/`. This folder contains:

- a Hello World example program, `main.c`
- a linker script for RISC-V Steel
- a Makefile to automate building tasks
- a `CMakeLists.txt` file with build instructions for CMake
- LibSteel library, which provides an API to control RISC-V Steel

The Hello World program in `main.c` is perhaps the simplest application you can build with RISC-V Steel. Its source code is reproduced below.

```c
#include "libsteel.h"

void main(void) {
  uart_write_string(RVSTEEL_UART, "Hello World from RISC-V Steel!");
}
```

As you can see, this program calls `uart_write_string` from `libsteel.h` to send a *Hello World!* message to the UART controller.

To build the project, run:

```bash
cd riscv-steel/examples/hello_world/software/
make release PREFIX=/opt/riscv
```

The build output will be saved to `build/` and contain a file named `hello_world.hex`. You will use this file in the next step to initialize the memory of RISC-V Steel.

### 4. Port RISC-V Steel to your FPGA

*4.1. Create a new hardware module `hello_world` with an instance of RISC-V Steel*

Using your preferred text editor, create a new Verilog file named `hello_world.v` and add the code below.

**Don't forget** to change the instance parameters as instructed in the comments!

```verilog

module hello_world (
  
  input wire clock,
  input wire reset,
  output wire uart_tx
  
  );

  reg reset_debounced;
  always @(posedge clock) reset_debounced <= reset;

  rvsteel_mcu #(

    // Change to the frequency (in Hertz) of your FPGA board clock source
    .CLOCK_FREQUENCY          (50000000                   ),
    // Change to the absolute path to the .hex file generated in the previous step
    .MEMORY_INIT_FILE         ("/path/to/hello_world.hex" ),
    
    // The parameters below don't need to be changed for this example
    .MEMORY_SIZE              (8192                       ),
    .UART_BAUD_RATE           (9600                       ),
    .BOOT_ADDRESS             (32'h00000000               ),
    .GPIO_WIDTH               (1                          ),
    .SPI_NUM_CHIP_SELECT      (1                          ))
    
    rvsteel_mcu_instance      (
    
    .clock                    (clock                      ),
    .reset                    (reset_debounced            ),
    .halt                     (1'b0                       ),
    .uart_rx                  (/* unused */               ),
    .uart_tx                  (uart_tx                    ),
    .gpio_input               (1'b0                       ),
    .gpio_oe                  (/* unused */               ),
    .gpio_output              (/* unused */               ),
    .sclk                     (/* unused */               ),
    .pico                     (/* unused */               ),
    .poci                     (1'b0                       ),
    .cs                       (/* unused */               ));

endmodule
```

*4.2. Implement the new `hello_world` design on your FPGA*

The specific steps to implement the `hello_world` design you created above vary depending on the vendor and model of your FPGA. However, they can be broken down into the following general steps:

- Open the EDA software for your FPGA (e.g. AMD Vivado, Intel Quartus, Lattice iCEcube)
- Create a new project named `hello_world`. Add the following files to the project:
    - The Verilog file you just created, `hello_world.v`
    - All Verilog files saved in `riscv-steel/hardware/mcu/`. You don't need to add the `tests` folder and its contents.
- Create a design constraints file
    - Assign the `clock` pin of `hello_world.v` to a clock source
    - Assign the `reset` pin of `hello_world.v` to a push-button or switch
    - Assign the `uart_tx` pin to the **receiver** pin (rx) of the UART of your FPGA board
- Run synthesis, place and route, and any other intermediate step needed to generate a bitstream for the FPGA
- Upload the bitstream to your FPGA 

### 5. Run the application

The Hello World program starts running as soon as you finish uploading the bitstream.

To receive the *Hello World!* message on your computer you need a serial terminal emulator like [PySerial](https://pythonhosted.org/pyserial/), which we show how to install below:

- Connect the UART of your FPGA board to your computer (if not already connected)
- Open a serial terminal emulator:
    - To install PySerial, run `python3 -m pip install pyserial`
    - To open a PySerial terminal, run `python3 -m serial.tools.miniterm`
    - PySerial will show the available serial ports, one of which is the UART of your FPGA board. Choose it to connect.
    - If you are not using PySerial, adjust the UART configuration to 9600 bauds/s, 8 data bits, no parity, no control and no stop bit
- Press the reset button
- You should now see the Hello World message!

## License

RISC-V Steel is distributed under the [MIT License](LICENSE).

## Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).
