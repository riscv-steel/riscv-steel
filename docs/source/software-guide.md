# RISC-V Steel System-on-Chip IP </br><small>Software Guide</small>

## Introduction

This guide shows how to write, compile and run software applications for RISC-V Steel SoC IP.


## Installing the RISC-V GNU Toolchain

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

This last step might take some time to complete.

## Building a new application

<h4>1. Make a copy of the software development template project.</h4>

The template project is all you need to start and is located at `riscv-steel/dev-template/`.

<h4>2. Edit the Makefile.</h4>

The template project comes with a Makefile to help you automatize the tasks of compiling the software and generating a memory initialization file.

The beginning of the Makefile (reproduced below) contain the four variables you need to set to configure the project:

```
# Configure your project by setting the variables below
# -------------------------------------------------------------------------------------------------

# Name of the program to be created
PROGRAM_NAME      ?= main
# Memory size (must be set to the same value of the MEMORY_SIZE parameter of rvsteel_soc module)
MEMORY_SIZE       ?= 8192
# Path to RISC-V Steel API
RVSTEEL_API_DIR   ?= ../api
# The full path to RISC-V GNU Toolchain in this machine + RISC-V binaries prefix
RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-

```

<h4>3. Write your application.</h4>

The template project comes with a `main.c` file containing a Hello World example. You can edit this file and rename it. You can also add as many source files to the project as you want.

The Makefile was written so that all `*.c` source files added to the project get automatically compiled when you run `make`.

To simplify writing your application, [RISC-V Steel SoC API](#) provides a set of function calls to set up and control RISC-V Steel SoC IP devices. Check it out for more information.

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

</br>
</br>