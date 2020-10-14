<p align="center">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>

Steel is a microprocessor core that implements the RV32I and Zicsr instruction sets of the RISC-V specifications, designed to be simple and easy to use. It is targeted for embedded systems projects.

## Key features

* Simple and easy to use
* Implements the RV32I base instruction set + Zicsr extension + M-mode priviledged architecture
* 3 pipeline stages, single-issue
* Hardware described in Verilog
* Full documentation
* Passed all RISC-V Compliance Suite tests for the RV32I and Zicsr instruction sets
* 1.36 CoreMarks/MHz

## Getting started

To start using Steel in your project, import all files inside the **rtl** directory to it. Then instantiate the core using the following template:

```verilog
steel_top #(

    .BOOT_ADDRESS() // You must provide a 32-bit value. If omitted the boot
                    // address is set to 0x00000000
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
