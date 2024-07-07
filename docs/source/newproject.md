# Software Guide

<h2>Starting a new project</h2>

Before you start, make sure you have the RISC-V GNU Toolchain installed. [Click here](softwareguide.md) for the steps on how to install it.

Follow the steps below to start a new software project for RISC-V Steel:

### 1. Copy one of the example projects

The easiest way to start a new project for RISC-V Steel is making a copy of one of the example projects in the `examples/` folder.

!!!info ""

    **Tip:** we strongly recommend starting a new project from one of the examples because by doing so you don't have to worry about boot code, linking scripts, and the complex options you need to set to get GCC cross-compiling for your embedded application.

For this demonstration we are going to use the *Hello World* example project:

```bash
# Clone RISC-V Steel repository
git clone https://github.com/riscv-steel/riscv-steel
# Start a new project from the Hello World example project
cp riscv-steel/examples/hello_world/software/ new_project/
```

This Hello World example project uses CMake as its build system and contains:

- an example Hello World program, `main.c`
- a linker script for RISC-V Steel
- a Makefile to automate building tasks
- a `CMakeLists.txt` file with build instructions for CMake
- LibSteel library, which provides an API to control RISC-V Steel

### 2. Configure the new project

Change the `CMakeLists.txt` file to configure the new project. A quick summary of the variables you can change is shown below.   

| Variable            | Description                                                                                                       |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| ``APP_NAME``        | Defines the name of the executable to be generated.                                                               |
| ``SOURCES``         | A list with the source files of your application.                                                                 |
| ``MEMORY_SIZE``     | Change it to the same value you provided for the `MEMORY_SIZE` parameter of `rvsteel_mcu`.</br></br>If the size of your program exceeds `MEMORY_SIZE` you will get error messages and the project won't build. |
| ``STACK_SIZE``      | Defines a region in memory that will be left empty for stack growth.                                              |
| ``HEAP_SIZE``       | Defines a region in memory that will be left empty for heap growth.                                               |

### 3. Write your application

The `main.c` file contains the `main` function, which is called by RISC-V Steel boot code. The body of this function initially contains a Hello World application, but you can of course delete it and write your own code.

You can add more source files to the project by editing the `SOURCES` variable of `CMakeLists.txt`.

Use LibSteel to control the UART, GPIO, SPI and timer modules, handle interrupts and access the processor core control and status registers.

### 4. Build your application

Run `make` from the project root folder to build your application and generate a memory initialization file for the `rvsteel_mcu` module.

A successfull build ends with a message like:

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

Now that you have compiled your application, you can run it by implementing RISC-V Steel on your FPGA. The [Getting Started Guide](gettingstarted.md#4-port-risc-v-steel-to-your-fpga) contains a section with instructions on how to do this.

The memory module of RISC-V Steel is initialized by providing the path to the `.hex` file generated in the previous step in the `MEMORY_INIT_FILE` parameter of `rvsteel_mcu`. By doing this, your application will get embedded in the FPGA bitstream and start running as soon as you turn the FPGA on.

</br>
</br>