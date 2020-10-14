<p align="center">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>

Steel is a microprocessor core that implements the RV32I and Zicsr instruction sets of the RISC-V specifications. It is designed to be easy to use and targeted for embedded systems projects.

## Key features

* Simple and easy to use
* Implements the RV32I base instruction set + Zicsr extension + M-mode privileged architecture
* 3 pipeline stages, single-issue
* Hardware described in Verilog
* Full documentation
* Passed all RISC-V Compliance Suite tests for the RV32I and Zicsr instruction sets
* 1.36 CoreMarks/MHz

## Getting started


Follow the steps:

1. Import all files inside the **rtl** directory into your project
2. Instantiate the core into a Verilog/SystemVerilog module (an instantiation template is provided below)
3. Connect Steel to a clock source, a reset signal and memory. There is an interface to fetch instructions and another to read/write data, so we recommend a dual-port memory

There are also interfaces to request for interrupts and to update the time register. The signals of these interfaces must be hardwired to zero if unused. [Read the docs](https://rafaelcalcada.github.io/steel-core/) for more information about this signals.

```verilog
steel_top #(

    // You must provide a 32-bit value. If omitted the boot address is set to 0x00000000
    // ---------------------------------------------------------------------------------

    .BOOT_ADDRESS() 
                  
    ) core (    
    
    // Clock source and reset
    // ---------------------------------------------------------------------------------
    
    .CLK(),         // System clock (input, required, 1-bit)
    .RESET(),       // System reset (input, required, 1-bit, synchronous, active high)

    // Instruction fetch interface
    // ---------------------------------------------------------------------------------
    .I_ADDR(),      // Instruction address (output, 32-bit)
    .INSTR(),       // Instruction data (input, required, 32-bit)
    
    // Data read/write interface
    // ---------------------------------------------------------------------------------

    .D_ADDR(),      // Data address (output, 32-bit)    
    .DATA_IN(),     // Data read from memory (input, required, 32-bit)
    .DATA_OUT(),    // Data to write into memory (output, 32-bit)
    .WR_REQ(),      // Write enable (output, 1-bit)
    .WR_MASK(),     // Write byte mask (output, 4-bit)
    
    // Interrupt request interface (hardwire to zero if unused)
    // ---------------------------------------------------------------------------------
    
    .E_IRQ(),       // External interrupt request (optional, active high, 1-bit)
    .T_IRQ(),       // Timer interrupt request (optional, active high, 1-bit)
    .S_IRQ()        // Software interrupt request (optional, active high, 1-bit)

    // Time register update interface (hardwire to zero if unused)
    // ---------------------------------------------------------------------------------

    .REAL_TIME(),   // Value read from a real-time counter (optional, 64-bit)
    
);
```

## Documentation

Steel documentation is available at [https://rafaelcalcada.github.io/steel-core/](https://rafaelcalcada.github.io/steel-core/) and provides information on:
* How to compile software for Steel
* I/O signals and communication to other devices
* Configuration
* Exceptions, interrupts and trap handling
* Implementation details
* Timing diagrams

## License

Steel is distributed under the MIT License. Read the `LICENSE.md` file before using Steel.

## About the author

The author is a computer engineering student at UFRGS (graduates at the end of 2020).

Contact: rafaelcalcada@gmail.com / rafaelcalcada@hotmail.com

## Acknowledgements

My colleague [Francisco Knebel](https://github.com/FranciscoKnebel) deserves special thanks for his collaboration with this work.
