<p align="center"><img src="docs/source/images/rvsteel_logo.drawio.svg" width="70"/></p>

RISC-V Steel is an open source RISC-V microcontroller unit IP for FPGAs written in Verilog. 

**Key features**

- RISC-V processor core (RV32I + Zicsr + Machine mode)
- UART, GPIO and SPI modules for communicating with external devices
- Timer and memory modules
- Runs real-time operating systems like FreeRTOS.
- Software library that makes it simple to use the UART, GPIO, SPI and timer modules

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

*Get the RISC-V GNU Toolchain*

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
```

*Install dependencies (choose according to your OS)*

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

*Configure it for RISC-V Steel and install it*

```
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
make
```
**Tip**: Change the `--prefix` argument to install the toolchain in a different folder.

### 2. Compile the Hello World program

RISC-V Steel provides a demo software project in the `software/` folder of its repository. This software project uses CMake as its build system and contains:

- a Hello World program, `main.c`
- `libsteel.h`, a software library to control RISC-V Steel modules
- a linker script used to compile software for RISC-V Steel
- a Makefile to automate building tasks

The Hello World program is the simplest application you can build with RISC-V Steel. It calls `uart_write_string` from `libsteel.h` to send a *"Hello World!"* message to the UART controller. Its source code is reproduced below:

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

## License

RISC-V Steel is distributed under the [MIT License](LICENSE).

## Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).
