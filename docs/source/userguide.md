---
hide: navigation
---

## Introduction

The process of developing a new application with RISC-V Steel can be divided into two steps:

1. Building the application

    The first step is to write the source code for the new application and build it using the RISC-V GNU Toolchain. The build process will generate a file that will later be used to initialize the memory of RISC-V Steel.

2. Running on FPGA

    Once you have built your application, you can run it on RISC-V Steel. To do this, you need to implement an instance of RISC-V Steel on FPGA. The instance will be configured for the target FPGA and initialized with the application you wrote.

## Prerequisites

To build software for RISC-V Steel you need the [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain), a suite of compilers and development tools for the RISC-V architecture. 

Run the commands below to install and configure the toolchain for RISC-V Steel:

!!! quote ""

    __Important!__ The `--prefix` option defines the installation folder. You need to set it to a folder where you have `rwx` permissions. The commands below assume you have `rwx` permissions on `/opt`.

=== "Ubuntu"

    ```
    # Clone the RISC-V GNU Toolchain repo
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain

    # Install dependencies
    sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev

    # Configure the toolchain for RISC-V Steel
    cd riscv-gnu-toolchain && ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv

    # Compile and install
    make -j $(nproc)
    ```

=== "Fedora/CentOS/RHEL/Rocky"

    ```
    # Clone the RISC-V GNU Toolchain repo
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain

    # Install dependencies
    sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel

    # Configure the toolchain for RISC-V Steel
    cd riscv-gnu-toolchain && ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv

    # Compile and install
    make -j $(nproc)
    ```

=== "Arch Linux"

    ```
    # Clone the RISC-V GNU Toolchain repo
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain

    # Install dependencies
    sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat libslirp

    # Configure the toolchain for RISC-V Steel
    cd riscv-gnu-toolchain && ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv

    # Compile and install
    make -j $(nproc)
    ```

=== "OS X"

    ```
    # Clone the RISC-V GNU Toolchain repo
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain

    # Install dependencies
    brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp

    # Configure the toolchain for RISC-V Steel
    cd riscv-gnu-toolchain && ./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv

    # Compile and install
    make -j $(nproc)
    ```

## Building the application

To facilitate the development of new applications, RISC-V Steel provides two template projects that can be used as a starting point: a template for **bare-metal** embedded software and a more sophisticated one based on **FreeRTOS**.

Both projects provide a `main.c` template file where the application source code must be added. The projects use CMake to configure the RISC-V GNU Toolchain to compile and link software for RISC-V Steel, so you can start writing your application right away, without having to worry about configuration.

Choose a template and run the commands to copy it:

=== "Bare-metal"

    ```
    # Clone RISC-V Steel repository (if not cloned yet)
    git clone https://github.com/riscv-steel/riscv-steel
    
    # Make a copy of the Bare-metal template project
    cp riscv-steel/templates/baremetal new_project/
    ```

=== "FreeRTOS"

    ```
    # Clone RISC-V Steel repository (if not cloned yet)
    git clone https://github.com/riscv-steel/riscv-steel
    
    # Make a copy of the FreeRTOS template project
    cp riscv-steel/templates/freertos new_project/
    ```

Next, add the source code of the new application in the `main.c` file. To build the application you wrote, run:

=== "Bare-metal"

    ```bash
    # -- PREFIX: Absolute path to the RISC-V GNU Toolchain installation folder
    cd new_project/
    make PREFIX=/opt/riscv
    ```

=== "FreeRTOS"

    ```bash
    # -- PREFIX: Absolute path to the RISC-V GNU Toolchain installation folder
    # -- CLOCK_FREQUENCY: Frequency of the `clock` input of `rvsteel_mcu`
    cd new_project/
    make PREFIX=/opt/riscv CLOCK_FREQUENCY=<freq_in_hertz>
    ```

A successfull build ends with a message like this:

```
Memory region         Used Size  Region Size  %age Used
             RAM:        1264 B         8 KB     15.43%
-------------------------------------------------------
Build outputs:
-- ELF executable:    build/myapp.elf
-- Memory init file:  build/myapp.hex
-- Disassembly:       build/myapp.objdump
```

The `.hex` file generated by the build process will be used in the next step to initialize the memory of RISC-V Steel.

## Running on FPGA

Once you have generated the `.hex` file you can implement RISC-V Steel on FPGA and run the application. Implementing RISC-V Steel on FPGA consists of two steps:

- First, you create a wrapper module with an instance of RISC-V Steel. This instance is then configured for the target FPGA and initialized with the application it will run.

- Next, using the software provided by the FPGA vendor, you synthesize the wrapper module and program the FPGA with it.

Using your preferred text editor, create a Verilog file named `rvsteel_wrapper.v` and add the code below. 

!!! quote ""

    __Important:__ Don't forget to change the file as instructed in the comments!

```verilog

module rvsteel_wrapper (
  
  input   wire          clock       ,
  input   wire          reset       ,
  input   wire          halt        ,

  // UART pins
  // You can remove them if your application does not use the UART controller
  input   wire          uart_rx     ,
  output  wire          uart_tx     ,

  // General Purpose I/O pins
  // You can remove them if your application does not use the GPIO controller
  input   wire  [3:0]   gpio_input  ,
  output  wire  [3:0]   gpio_oe     ,
  output  wire  [3:0]   gpio_output ,

  // Serial Peripheral Interface (SPI) pins
  // You can remove them if your application does not use the SPI controller
  output  wire          sclk        ,
  output  wire          pico        ,
  input   wire          poci        ,
  output  wire  [0:0]   cs
  
  );

  reg reset_debounced;
  always @(posedge clock) reset_debounced <= reset;

  reg halt_debounced;
  always @(posedge clock) halt_debounced <= halt;

  rvsteel_mcu #(

    // Frequency (in Hertz) of the `clock` pin
    .CLOCK_FREQUENCY          (50000000                   ),
    // Absolute path to the .hex init file generated in the previous step
    .MEMORY_INIT_FILE         ("/path/to/myapp.hex"       ),    
    // The size you want for the memory (in bytes)
    .MEMORY_SIZE              (8192                       ),
    // The UART baud rate (in bauds per second)
    .UART_BAUD_RATE           (9600                       ),
    // Don't change it unless you explicitly modified the boot address
    .BOOT_ADDRESS             (32'h00000000               ),
    // Width of the gpio_* ports
    .GPIO_WIDTH               (4                          ),
    // Width of the cs port
    .SPI_NUM_CHIP_SELECT      (1                          ))
    
    rvsteel_mcu_instance      (
    
    .clock                    (clock                      ),
    .reset                    (reset_debounced            ),
    .halt                     (halt_debounced             ),
    .uart_rx                  (uart_rx                    ),
    .uart_tx                  (uart_tx                    ),
    .gpio_input               (gpio_input                 ),
    .gpio_oe                  (gpio_oe                    ),
    .gpio_output              (gpio_output                ),
    .sclk                     (sclk                       ),
    .pico                     (pico                       ),
    .poci                     (poci                       ),
    .cs                       (cs                         ));

endmodule
```

Now you need to synthesize this module to finally run the application. The steps to synthesize it vary depending on the FPGA model and vendor, but generally follow this sequence:

- Start a new project on the EDA tool provided by your FPGA vendor (e.g. AMD Vivado, Intel Quartus, Lattice iCEcube)
- Add the following files to the project:
    - The Verilog file created above, `rvsteel_wrapper.v`.
    - All [source files](hardware/mcu.md#source-files) of RISC-V Steel.
- Create a design constraints file and map the ports of `rvsteel_wrapper.v` to the respective devices on the FPGA board.
- Run synthesis, place and route, and any other intermediate step needed to generate a bitstream for the FPGA.
- Generate the bitstream and program the FPGA with it.

After programming the FPGA, the application starts running immediately!

</br>
</br>