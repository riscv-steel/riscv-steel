<p align="center"><img src="docs/source/images/rvsteel_logo_circle.svg" width="70"/></br><strong>RISC-V Steel</strong></p>

RISC-V Steel is an open source RISC-V microcontroller unit for FPGAs written in Verilog.

**Top features**

- 32-bit RISC-V processor core (RV32I + Zicsr + Machine mode)
- UART, GPIO and SPI modules for communication with external devices
- Timer and memory modules
- Support for real-time operating systems like FreeRTOS
- `libsteel` library, which makes it simple to use the UART, GPIO, SPI and timer modules

RISC-V Steel is designed to make it easier to develop embedded applications on FPGA boards and can be easily ported to any FPGA.

## Getting Started

To demonstrate how to get RISC-V Steel working on your FPGA, this guide will show you how to:

- start a new software project for RISC-V Steel and compile a Hello World program
- implement RISC-V Steel on your FPGA board and run the program you compiled on it

The Hello World program is a simple application that sends a *"Hello World!"* message over the UART device of your FPGA board.

After you finish this guide you will have a basic working environment that you can use to create larger projects.

### 1. Download RISC-V Steel

```
git clone https://github.com/riscv-steel/riscv-steel
```

### 2. Download and install the RISC-V GNU Toolchain

The [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) is a set of compilers and software development tools for the RISC-V architecture. You need it to compile the Hello World program, as well as any other software for RISC-V machines.

*2.1. Get the RISC-V GNU Toolchain*

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
```

*2.2. Install dependencies (choose according to your OS)*

```bash
# Ubuntu
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev

# Fedora/CentOS/RHEL OS
sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel

# Arch Linux
sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat libslirp

# OS X
brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp
```

*2.3. Configure it for RISC-V Steel and install it*

```bash
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32izicsr --with-abi=ilp32
make
```
**Tip**: Change the `--prefix` argument to install the toolchain in a different folder.

### 2. Compile the Hello World program

RISC-V Steel provides a demo software project in the `software/` folder of its repository. This software project uses CMake as its build system and contains:

- a Hello World program, `main.c`
- `libsteel.h`, a software library to control RISC-V Steel modules
- a linker script used to compile software for RISC-V Steel
- a Makefile to automate building tasks

The Hello World program in the demo software project is the simplest application you can build with RISC-V Steel. Its source code is reproduced below. It calls `uart_write_string` from `libsteel.h` to send a *"Hello World!"* message to the UART controller. :

```c
#include "libsteel.h"

void main(void) {
  uart_write_string(RVSTEEL_UART, "Hello World from RISC-V Steel!");
}
```

To build the Hello World program, run:

```bash
cp -r /path/to/riscv-steel/software/ hello_world/
cd hello_world/
# assuming you have configured the RISC-V GNU Toolchain with --prefix=/opt/riscv
make release TOOLCHAIN_PREFIX=/opt/riscv/bin/riscv32-unknown-elf-
```

The build output will be saved to `hello_world/build/` and a file named `hello_world.hex` will be generated. You will use this file next to initialize the memory module of Steel MCU.

### 3. Implement RISC-V Steel on your FPGA

*3.1. Create a new design `hello_world` with an instance of RISC-V Steel*

Using your preferred text editor, create a new Verilog file named `hello_world.v` and add a module declaration with the same name of the file. This module will serve as a wrapper for an instance of RISC-V Steel.

The Hello World program uses only the UART module. Thus, only one extra pin is needed in addition to the `clock` and `reset` pins.

```verilog
module hello_world (
  input wire clock,
  input wire reset,
  output wire uart_tx
  );
```

Later you will connect the `reset` pin to a push-button or switch in your board. To remove glitches coming from this signal, add a simple debouncing logic to it:

```verilog
  reg reset_debounced;
  always @(posedge clock) reset_debounced <= reset;
```

Next, instantiate RISC-V Steel using the template provided below. You need to adjust the `CLOCK_FREQUENCY` parameter to the frequency (in Hertz) of your FPGA board clock. You must also provide the full path to the memory initialization file generated in the previous step in the `MEMORY_INIT_FILE` parameter.

Note that the unused inputs of RISC-V Steel are hardwired to zero, while unused outputs are simply left open.

```verilog
  rvsteel_mcu #(
    .CLOCK_FREQUENCY          (50000000                   ),
    .UART_BAUD_RATE           (9600                       ),
    .MEMORY_INIT_FILE         ("/path/to/hello_world.hex" )
  ) rvsteel_mcu_instance (
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
    .cs                       (/* unused */               ),
  );
```

Finally, end the module declaration with `endmodule`:

```verilog
endmodule
```

[Click here](demos/hello_world/hello_world.v) for a full example of the `hello_world.v` file.

*3.2. Implement the new `hello_world` design on your FPGA*

The specific steps to implement the `hello_world` design on your FPGA board vary depending on the vendor and model of your FPGA board. However, they can be broken down into the following general steps:

- Open the EDA software for your FPGA board (e.g. AMD Vivado, Intel Quartus, Lattice iCEcube)
- Create a new project named `hello_world`. Add the following files to the project:
    - The Verilog file you just wrote, `hello_world.v`
    - All Verilog files saved in `riscv-steel/hardware/mcu/`. You don't need to add the `tests` folder.
- Create a design constraints file
    - Assign the `clock` pin of `hello_world.v` to the clock of your board
    - Assign the `reset` pin of `hello_world.v` to a push-button or switch
    - Assign the `uart_tx` pin to the **receiver** pin (rx) of your board's UART
- Run synthesis, place and route, and any other intermediate step needed to generate a bitstream to program the FPGA
- Upload the bitstream to your FPGA 

### 4. Run the application

The Hello World program starts running as soon as you finish uploading the bitstream to your FPGA. To visualize the *"Hello World!"* message, proceed as follows:

- Connect the FPGA board to your computer (if not already connected)
- Open a serial terminal emulator like PySerial to connect to your board's UART
  - To install PySerial, run `python3 -m pip install pyserial`
  - To open a PySerial terminal, run `python3 -m serial.tools.miniterm`
  - PySerial will show the available UART serial ports, one of which is your board's UART. Choose it to connect.
- Press the reset button. You should see the Hello World message!

## License

RISC-V Steel is distributed under the [MIT License](LICENSE).

## Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).
