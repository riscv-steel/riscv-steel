# Software Guide

## Introduction

This guide shows how to write, compile and run new software applications for RISC-V Steel SoC.

## Pre-requisites

To be able to cross-compile software for RISC-V systems like RISC-V Steel SoC you need the [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain).

<h3>How to install the RISC-V GNU Toolchain in 4 steps</h3>

<h4>1. Get the source files</h4>

Run the following command to download the RISC-V GNU Toolchain repository from GitHub:

```
git clone https://github.com/riscv/riscv-gnu-toolchain
```

<h4>2. Install dependencies</h4>

Run the following command to install all RISC-V GNU Toolchain dependencies in your computer:

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

<h4>3. Configure for RISC-V Steel</h4>

Run the following command from the toolchain root folder to configure the installation for RISC-V Steel:

```
./configure --with-arch=rv32i --with-abi=ilp32 --prefix=/opt/riscv
```

The `--prefix=` option specifies the installation path. Make sure you choose a path where you have write permissions.

<h4>4. Compile and install</h4>

The following command compiles and installs the toolchain (this last step might take some time to complete):

```
make -j $(nproc)
```

## Building a new application

Follow the steps below to build a new application for RISC-V Steel SoC.

1. **Make a copy of the `dev-template` folder.**

    This template project is all you need to start. It contains 3 files: `main.c`, `Makefile` and `linker-script.ld`.

2. **Edit the Makefile to configure the project.**

    The beginning of the Makefile (reproduced below) contain four variables you need to set to configure the project:

    ```
    # Configure your project by setting the variables below
    # --------------------------------------------------------------------------------------------

    # Name of the program to be created
    PROGRAM_NAME      ?= main
    # Memory size (must be set to the same value of the MEMORY_SIZE parameter of RISC-V Steel SoC)
    MEMORY_SIZE       ?= 8192
    # Path to RISC-V Steel API
    RVSTEEL_API_DIR   ?= ../api
    # The full path to RISC-V GNU Toolchain in this machine + RISC-V binaries prefix
    RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-

    # Other variables (do not edit)
    # --------------------------------------------------------------------------------------------

    ...
    ```

3. **Write your application.**

    The `main.c` file is a Hello World example program. You can edit this file and rename it. You can add new source files to the project as well. They will all be compiled when you run `make`.

    Use [RISC-V Steel API](#) to set up and control RISC-V Steel SoC devices.

4. **Build your application.**

    To build your application, run `make` from the project root folder.
    
    Once you run `make`, all `*.c` sources files will be compiled and linked into an executable called `PROGRAM_NAME.elf`, the name you set for the executable in the Makefile. Running `make` will also:

    - Compile RISC-V Steel API and link it to the executable.
    - Generate a memory initialization file for RISC-V Steel SoC.

    A successfull build will output a message similar to this:

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

    The generated `.hex` file can be used to initialize RISC-V Steel SoC memory and run the application.

</br>
</br>