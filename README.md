<p align="center">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>

Steel is a RISC-V core that implements the instruction sets RV32I and Zicsr from RISC-V specifications. It was designed to be simple and easy to use. It is targeted for embedded systems projects.

**Key features:**

* Simple and easy to use
* Implements the RV32I base instruction set + Zicsr extension
* M-mode privilege level support
* Hardware described in Verilog
* 3 pipeline stages
* Full documentation
* Passed all RV32I and Zicsr tests from RISC-V Test and Compliance suites
* 1.36 CoreMarks/MHz

## Table of Contents

* [Getting Started](#getting-started)
* [Documentation](#documentation)
* [License](#license)
* [About the Author](#about-the-author)
* [Acknowledgements](#acknowledgements)

## Getting Started

To use Steel in your project, import all files from the **rtl** directory to it and then instantiate Steel using the following template:

```verilog
steel_top #(

    .BOOT_ADDRESS() // You must provide a 32-bit value. If omitted the boot address is set to 0x00000000
    
    ) core (
    
    // ----------------------------------------------------------------------------
    // REMEMBER: optional inputs, if unused, must be hardwired to zero
    // ----------------------------------------------------------------------------
    
    .CLK(),         // System clock (required, 1-bit)
    .RESET(),       // System reset (required, 1-bit, synchronous, active high)

    // INPUTS ---------------------------------------------------------------------

    .INSTR(),       // Instruction data (required, 32-bit)    
    .DATA_IN(),     // Data read from memory (required, 32-bit)
    .REAL_TIME(),   // Value read from a real-time counter (optional, 64-bit)
    .E_IRQ(),       // External interrupt request (optional, active high, 1-bit)
    .T_IRQ(),       // Timer interrupt request (optional, active high, 1-bit)
    .S_IRQ()        // Software interrupt request (optional, active high, 1-bit)

    // OUTPUTS --------------------------------------------------------------------

    .I_ADDR(),      // Instruction address (32-bit)
    .D_ADDR(),      // Data address (32-bit)
    .DATA_OUT(),    // Data to be written (32-bit)
    .WR_REQ(),      // Write enable (1-bit)
    .WR_MASK(),     // Write mask (4-bit)
    
);
```
Steel has 4 communication interfaces, shown in the figure below:

<p align="center">
  <img width="75%" src="https://user-images.githubusercontent.com/22325319/95912803-b1cae480-0d79-11eb-87de-299f408f0d63.png">
</p>

The core was designed to be connected to a dual-port memory with one clock cycle read/write latency, which means that the memory should take one clock cycle to complete both read and write operations. You must connect the instruction fetch and data read/write interfaces to memory.

The interrupt request interface has signals to request for external, timer and software interrupts, respectively. They can be connected to a single device or to an interrupt controller managing interrupt requests from several devices. If your system does not need interrupts you should hardwire these signals to zero.

The real-time counter interface provides a 64-bit bus to read the value from a real-time counter. If your system does not need hardware timers, you should hardwire this signal to zero.

[Read the docs](https://rafaelcalcada.github.io/steel-core/) for instructions on how to compile and run software for Steel.

## Documentation

Steel docs are available at [https://rafaelcalcada.github.io/steel-core/](https://rafaelcalcada.github.io/steel-core/) and provides information on:
* I/O signals
* Integration to other devices
* Configuration
* Exceptions and interrupts
* Trap handling
* Implementation details
* Timing diagrams
* Testing

## License

Steel is distributed under the MIT License. Read the `LICENSE.md` file carefully before using Steel.

## About the author

The author is a computer engineering student at UFRGS (graduates at the end of 2020).

Contact: rafaelcalcada@gmail.com / rafaelcalcada@hotmail.com

## Acknowledgements

My colleague [Francisco Knebel](https://github.com/FranciscoKnebel) deserves special thanks for his collaboration with this work.
