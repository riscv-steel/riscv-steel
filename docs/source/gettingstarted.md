---
hide:
  - navigation
---

# Getting Started Guide

In this guide we will show you how create a Hello World example system for FPGA implementation with RISC-V Steel.

This example is a simple embedded application that makes your FPGA board send a Hello World message to your computer through its UART interface. With the help of a serial terminal emulator (PySerial), you will be able to see this message on your computer screen after programming the FPGA.

Once you have completed this guide you will have a basic environment that you can use to create larger applications.

### 1. Download RISC-V Steel

First, download RISC-V Steel by running:

```
git clone https://github.com/riscv-steel/riscv-steel
```

### 2. Download and install the RISC-V GNU Toolchain

The [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) is a set of compilers and software development tools for the RISC-V architecture. You need it to compile the C program written for the Hello World system. Follow the steps below:

*2.1. Get the RISC-V GNU Toolchain*

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
```

*2.2. Install dependencies*

=== "Ubuntu"

    ```
    sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev
    ```

=== "Fedora/CentOS/RHEL OS"

    ```
    sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel
    ```

=== "Arch Linux"

    ```
    sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat libslirp
    ```

=== "OS X"

    ```
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

The software project for this Hello World example is saved in `examples/hello_world/software/`. This folder contains:

- the Hello World program, `main.c`
- a linker script for RISC-V Steel
- a Makefile to automate building tasks
- a `CMakeLists.txt` file with build instructions for CMake

The program in `main.c` is very simple. It calls `uart_write_string` from `libsteel.h` to send a message to the UART controller. Its source code is reproduced below:

```c
#include "libsteel.h"

void main(void) {
  uart_write_string(RVSTEEL_UART, "Hello World from RISC-V Steel!");
}
```

To build the program above, run:

```bash
cd riscv-steel/examples/hello_world/software/
make release PREFIX=/opt/riscv
```

The build process will generate, among others, a file named `hello_world.hex` (saved to `build/`). This file will be used in the next step to initialize the memory of RISC-V Steel.

### 4. Implement RISC-V Steel on your FPGA

*4.1. Create a hardware module named `hello_world` with an instance of RISC-V Steel top module*

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

    // Change to the frequency (in Hertz) of your FPGA board's clock
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

*4.2. Implement the design created above on your FPGA*

The specific steps to implement the `hello_world` design you created above vary depending on the vendor and model of your FPGA. However, they can be broken down into the following general steps:

- Open the EDA software for your FPGA (e.g. AMD Vivado, Intel Quartus, Lattice iCEcube)
- Create a new project named `hello_world`. Add the following files to the project:
    - The Verilog file you just created, `hello_world.v`
    - All Verilog files saved in `riscv-steel/hardware/mcu/`. You don't need to add the `tests` folder and its contents.
- Create a design constraints file
    - Assign the `clock` pin to a clock source
    - Assign the `reset` pin to a push-button or switch
    - Assign the `uart_tx` pin to the **receiver** pin (rx) of your FPGA board's UART
- Run synthesis, place and route, and any other intermediate step needed to generate a bitstream for the FPGA
- Upload the bitstream to your FPGA 

### 5. Run the application

The program you built in step 3 will start running as soon as the EDA tool finishes uploading the bitstream to the FPGA.

To see the Hello World message on your computer screen you need a serial terminal emulator like [PySerial](https://pythonhosted.org/pyserial/), which we show how to install below:

- Connect the UART of the FPGA board to your computer (if not already connected)
- Install PySerial by running `python3 -m pip install pyserial`
- Open a PySerial terminal by running `python3 -m serial.tools.miniterm`
- PySerial will show the available serial ports, one of which is the UART of your FPGA. Choose it to connect.
- Press the reset button
- You should now see a Hello World message!

</br>
</br>