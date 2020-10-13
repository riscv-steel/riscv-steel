<p align="center">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>

## Table of Contents

* [About Steel](#about-steel)
* [Getting Started](#getting-started)
* [Documentation](#documentation)
* [License](#license)
* [About the Author](#about-the-author)
* [Acknowledgements](#acknowledegments)

## About Steel

Steel is a RISC-V core that implements the instruction sets RV32I and Zicsr from RISC-V specifications. It was designed to be simple and easy to use.

**Key features:**

* Simple and easy to use
* Implements the RV32I base instruction set + Zicsr extension
* M-mode privilege level support
* Hardware described in Verilog
* 3 pipeline stages
* Full documentation
* Passed all RV32I and Zicsr tests from RISC-V Test and Compliance suites
* 1.36 CoreMarks/MHz

## Getting Started

### What you need to know first

You must connect Steel to a memory that meets the following requirements:
* One clock cycle read/write latency, which means that the memory should take one clock cycle to complete both read and write operations;
* The data bus width must be 32 bits long;

There are three signals to request for external, timer or software interrupts, respectively. They can be connected to a single device or to an interrupt controller managing interrupt requests from several devices. If your system does not need interrupts you should hardwire these signals to zero.

There is a 64-bit bus to read the value from a real-time counter. If your system does not need hardware timers, you should hardwire this signal to zero.

### Instantiating Steel

Before instantiating you must import all files from the **rtl** directory to your project. Then you can instantiate Steel using the following template:

```verilog
steel_top #(

    .BOOT_ADDRESS()     // You must provide a 32-bit value. If omitted the boot address is set to 0x00000000
    
    ) core (
    
    // -----------------------------------------------------------------------------------------------------------
    // REMEMBER: optional inputs, if unused, must be hardwired to zero
    // -----------------------------------------------------------------------------------------------------------
    
    .CLK(),             // System clock                         (required, input, 1-bit)
    .RESET(),           // System reset                         (required, input, 1-bit, synchronous, active high)

    // INPUTS ----------------------------------------------------------------------------------------------------

    .INSTR(),           // Instruction data                     (required, input, 32-bit)    
    .DATA_IN(),         // Data read from memory                (required, input, 32-bit)
    .REAL_TIME(),       // Value read from a real-time counter  (optional, input, 64-bit)
    .E_IRQ(),           // External interrupt request           (optional, active high, input, 1-bit)
    .T_IRQ(),           // Timer interrupt request              (optional, active high, input, 1-bit)
    .S_IRQ()            // Software interrupt request           (optional, active high, input, 1-bit)

    // OUTPUTS ---------------------------------------------------------------------------------------------------

    .I_ADDR(),          // Instruction address                  (output, 32-bit)
    .D_ADDR(),          // Data address                         (output, 32-bit)
    .DATA_OUT(),        // Data to be written                   (output, 32-bit)
    .WR_REQ(),          // Write enable                         (output, 1-bit)
    .WR_MASK(),         // Write mask                           (output, 4-bit)
    
);
```
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

## Licence

Steel is distributed under the MIT License. Read the `LICENCE.md` file carefully before using Steel.

## About the author

The author is a computer engineering student at UFRGS (graduates at the end of 2020).

Contact: rafaelcalcada@gmail.com / rafaelcalcada@hotmail.com

## Acknowledgements

My colleague [Francisco Knebel](https://github.com/FranciscoKnebel) deserves special thanks for his collaboration with this work.
