<p align="center"><img src="docs/source/images/rvsteel_logo.drawio.svg" width="70"/></br><strong>RISC-V Steel</strong></p>

RISC-V Steel is an open collection of RISC-V based Intellectual Property (IP) for FPGAs written in Verilog. It features two main IPs:

- **Steel Core**, a 32-bit RISC-V processor (RV32I + Zicsr + M-mode)
- **Steel MCU**, a microcontroller unit integrating Steel Core + UART, GPIO, SPI, timer and memory modules.

RISC-V Steel is designed to make it easier to develop embedded applications with FPGA boards. Steel MCU can be easily ported to any FPGA and consumes few resources.

## Getting Started

In the next steps we will show you how to get Steel MCU working on your FPGA and run a Hello World program on it.

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

### Compile the demo Hello World program

RISC-V Steel provides a demo software project for Steel MCU in the `software/` folder of the repository. This software project uses CMake as its build system and contains:

- a Hello World program, `main.c`
- **LibSteel**, which provides API calls to control Steel MCU
- a linker script
- a Makefile to automate building tasks

The Hello World program uses the UART module of Steel MCU to send a "Hello World!" message. Its source code is reproduced below:

```c
#include "libsteel/mcu.h"

void main(void) {
  uart_write_string(RVSTEEL_UART, "Hello World from RISC-V Steel!");
}
```

You can start a new software project for Steel MCU making a copy of this folder as follows:

```bash
cp -r /path/to/riscv-steel/software/ hello_world/
```

Assuming you have configured the RISC-V GNU Toolchain with `--prefix=/opt/riscv`, run the command below to build the Hello World program:

```bash
cd hello_world/
make release TOOLCHAIN_PREFIX=/opt/riscv/bin/riscv32-unknown-elf-
```

The build output will be saved to `hello_world/build/` and a file named `hello_world.hex` will be generated. You will use it next to initialize the memory module of Steel MCU.

## License

RISC-V Steel is distributed under the [MIT License](LICENSE).

## Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).
