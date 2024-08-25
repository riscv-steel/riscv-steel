# Software Guide

<h2>Starting a new project</h2>

Before you start, make sure you have the RISC-V GNU Toolchain installed. [Click here](softwareguide.md) for the steps on how to install it.

Follow the steps below to start a new software project for RISC-V Steel:

### 1. Copy an example project

The easiest way to start a new project for RISC-V Steel is making a copy of one of the example projects in the `examples/` folder.

!!!info ""

    **Tip:** we strongly recommend starting a new project from one of the examples because by doing so you don't have to worry about boot code, linking scripts, and the complex options you need to set to get GCC cross-compiling for your embedded application.

For example, run the following commands to copy the *Hello World* project:

```bash
# Clone RISC-V Steel repository
git clone https://github.com/riscv-steel/riscv-steel
# Make copy of the Hello World project
cp riscv-steel/examples/hello_world/software/ new_project/
```

The Hello World project uses CMake as its build system and contains:

- a Hello World program, `main.c`
- a linker script for RISC-V Steel
- a Makefile to automate building tasks
- a `CMakeLists.txt` file with build instructions for CMake

### 2. Configure the new project

Edit `new_project/CMakeLists.txt` to configure the new project for you. A quick summary of the variables you can change is shown below.   

| Variable            | Description                                                                                                       |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| ``APP_NAME``        | Define the name of the executable to be generated.                                                               |
| ``SOURCES``         | A list with the source files of your application.                                                                 |
| ``STACK_SIZE``      | Define a region in memory that will be left empty for stack growth.                                              |
| ``HEAP_SIZE``       | Define a region in memory that will be left empty for heap growth.                                               |
| ``MEMORY_SIZE``     | Change this variable to the same value you provided for the `MEMORY_SIZE` parameter of `rvsteel_mcu` (see [Instantiation template](mcu.md#instantiation-template) and [Configuration parameters](mcu.md#configuration-parameters)).</br></br>If the size of your program exceeds `MEMORY_SIZE` you will get error messages and the project won't build. |

### 3. Build your application

After you finish writing your application (e.g. by editing `main.c`), run `make` from the project root folder to build it and generate a memory initialization file.

A successfull build ends with a message like this:

```bash
Memory region         Used Size  Region Size  %age Used
             RAM:        1264 B         8 KB     15.43%
-------------------------------------------------------
Build outputs:
-- ELF executable:    build/hello_world.elf
-- Memory init file:  build/hello_world.hex
-- Disassembly:       build/hello_world.objdump
```

### 5. Run the application

To run the application on your FPGA you need to provide the absolute path to the `.hex` file generated in the previous step in the `MEMORY_INIT_FILE` parameter of `rvsteel_mcu`. Doing so will embed the application into the FPGA's bitstream. 

Check the [Getting Started Guide](gettingstarted.md#4-implement-risc-v-steel-on-your-fpga) to learn how to implement RISC-V Steel on your FPGA.

</br>
</br>