<p align="center">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>

Steel is a RISC-V processor core that implements the RV32I and Zicsr instruction sets of the RISC-V specifications. It is designed to be simple and easy to use.

## Key features

* Simple, easy to use
* Free, open-source
* RV32I base instruction set + Zicsr extension + M-mode privileged architecture
* 3 pipeline stages, single-issue
* Hardware described in Verilog
* Full documentation
* RISC-V compliant
* 1.36 CoreMarks/MHz

## Getting started

A microprocessor by itself does not form a computer system, so you need to connect Steel to memory and peripherals to build a system that can do work for you. The **soc** folder has the project of a small example system that uses Steel, formed by Steel + RAM + UART interface. This project was built for an Artix-7 FPGA (Digilent Arty-A7 35T board, [link](https://store.digilentinc.com/arty-a7-artix-7-fpga-development-board/)) using the free version of Vivado ([link](https://www.xilinx.com/products/design-tools/vivado.html)), and it sends a "Hello World!" message through the UART interface. The Arty-A7 board has a USB-UART bridge that enables you to connect the system to your computer using a USB cable, and then see this "Hello World!" message on the screen. Instructions to build and run this project can be found in the section *Example system* from [Steel Docs](https://rafaelcalcada.github.io/steel-core/).

To use Steel as the microprocessor unit of your project, follow the steps below:

1. Import the file **steel_core.v** to your project - this is the only file you need
2. Instantiate the core into a Verilog module (the instantiation template is provided below)
3. Connect Steel to a clock source, a reset signal and memory. There is an interface to fetch instructions and another to read/write data, so it is recommended a dual-port RAM memory

There are also interfaces to request for interrupts and to update the internal time register. The signals of these interfaces must be hardwired to zero if unused. [Read the docs](https://rafaelcalcada.github.io/steel-core/) for more information about this signals.

You can write and compile programs for Steel using [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain). More information can be found in the [documentation](https://rafaelcalcada.github.io/steel-core/).

```verilog
steel_core_top #(

    // The address of the first instruction the core will fetch
    // ---------------------------------------------------------------------------------

    .BOOT_ADDRESS(32'h00000000) 
                  
    ) core (    
    
    // Clock and reset inputs
    // ---------------------------------------------------------------------------------
    
    .CLK(),         // System clock (input, required, 1-bit)
    .RESET(),       // System reset (input, required, 1-bit, synchronous, active high)

    // Instruction fetch interface
    // ---------------------------------------------------------------------------------
    .I_ADDR(),      // Instruction address (output, 32-bit)
    .INSTR(),       // Instruction itself (input, required, 32-bit)
    
    // Data read/write interface
    // ---------------------------------------------------------------------------------

    .D_ADDR(),      // Data address (output, 32-bit)    
    .DATA_IN(),     // Data read from memory (input, required, 32-bit)
    .DATA_OUT(),    // Data to write into memory (output, 32-bit)
    .WR_REQ(),      // Write enable/request (output, 1-bit)
    .WR_MASK(),     // Byte-write enable mask (output, 4-bit)
    
    // Interrupt request interface (hardwire to zero if unused)
    // ---------------------------------------------------------------------------------
    
    .E_IRQ(),       // External interrupt request (optional, active high, 1-bit)
    .T_IRQ(),       // Timer interrupt request (optional, active high, 1-bit)
    .S_IRQ(),       // Software interrupt request (optional, active high, 1-bit)

    // Time register update interface (hardwire to zero if unused)
    // ---------------------------------------------------------------------------------

    .REAL_TIME()   // Value read from a real-time counter (optional, 64-bit)
    
);
```

## Documentation

Steel documentation is available at [https://rafaelcalcada.github.io/steel-core/](https://rafaelcalcada.github.io/steel-core/) and provides information on:
* How to compile software for Steel
* I/O signals and communication with other devices
* Configuration
* Exceptions, interrupts and trap handling
* Implementation details
* Timing diagrams

## License

Steel is distributed under the MIT License. Read the `LICENSE.md` file before using Steel.

## About

Steel was developed for the author's Bachelor's thesis in Computer Engineering. 

Contact: rafaelcalcada@gmail.com

## Acknowledgements

My colleague [Francisco Knebel](https://github.com/FranciscoKnebel) deserves special thanks for his collaboration with this work.
