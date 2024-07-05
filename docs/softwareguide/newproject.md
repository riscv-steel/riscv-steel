# Software Guide

<h2>How to start a new project</h2>

### 1. Make a copy of the demo software project

The easiest way to start a new software project for RISC-V Steel is making a copy of the demo project saved in the `software/` folder:

```bash
# Get RISC-V Steel
git clone https://github.com/riscv-steel/riscv-steel

# Start a new project from the demo project
cp riscv-steel/software/ new-project/
```

This software project uses CMake as its build system and contains:

- an example Hello World program, `main.c`
- a linker script for RISC-V Steel
- a Makefile to automate building tasks
- a `CMakeLists.txt` file with build instructions for CMake
- LibSteel library, which provides an API to control RISC-V Steel

### 2. Configure your project

The `CMakeLists.txt` file defines a few variables to configure your project. A quick summary of the variables you can change is shown below.   

| Variable            | Description                                                                                                       |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| ``APP_NAME``        | Defines the name of the ELF executable to be generated. Ex: *myapp*.                                              |
| ``STACK_SIZE``      | Defines a region in memory that will be left empty for stack growth.                                              |
| ``HEAP_SIZE``       | Defines a region in memory that will be left empty for heap growth.                                               |
| ``SOURCES``         | A list with the source files of your application.                                                                 |
| ``MEMORY_SIZE``     | Defines the max size of the memory initialization file. Change it to the same value you provided for the `MEMORY_SIZE` parameter of `rvsteel_mcu`. The project won't build and error messages will be shown if the size of your program exceeds `MEMORY_SIZE`. |

### 3. Write your application

The `main.c` contains the `#!c void main(void)` function, called by RISC-V Steel boot code. The body of this function initially contains a Hello World application, but you can of course delete it and write your own code.

You can add other source files to the project by editing the `SOURCES` variable in `CMakeLists.txt`.

You can use LibSteel (included by `#!c #include "libsteel.h"` in `main.c`) to control the UART, GPIO, SPI and timer modules of RISC-V Steel. See [LibSteel Reference](libsteel.md) for documentation and code examples.

### 4. Build the project and generate a memory initialization file

Run `make` from the project root folder to build it and generate a memory initialization file. A successfull build ends with the following message:

```bash
Build outputs:
-- ELF executable:    build/hello_world.elf
-- Memory init file:  build/hello_world.hex
-- Disassembly:       build/hello_world.objdump
```

### 5. Run the application

Now that you have compiled your application, you need to implement RISC-V Steel on your FPGA to run it. The [Getting Started Guide](gettingstarted.md#4-implement-risc-v-steel-on-your-fpga) contains a section with instructions on how to do this.

You initialize the memory of RISC-V Steel by providing the path to the `.hex` file generated in the previous step in the `MEMORY_INIT_FILE` parameter of RISC-V Steel top module, `rvsteel_mcu`. By doing this, your application will get embedded in the FPGA bitstream and start running when you turn on the FPGA.

</br>
</br>