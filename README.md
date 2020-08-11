<p align="center">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>
Steel is a RISC-V microprocessor softcore designed to be simple and easy to use. It is intended for use as a processing unit in embedded systems projects.
<p align="center"></p>

**Key features:**
* RV32IZicsr implementation
* Small and easy to use
* 3 pipeline stages
* Single-issue
* M-mode support
* Targeted for use in FPGAs
* Full documentation
* Passed all RV32IZicsr tests from RISC-V test and compliance suites
* 0.46 CoreMarks / MHz

## Licence

Steel is distributed under the MIT License. See the `LICENCE.md` file.

## Documentation

Steel documentation ([https://rafaelcalcada.github.io/steel-core/](https://rafaelcalcada.github.io/steel-core/)) provides information on:
* Steel configuration
* Integration with other devices
* Implemented extensions and CSRs
* Supported exceptions and interrupts
* Trap handling
* Implementation details
* Timing diagrams for instruction fetch, data fetch, data writing and interrupt request processes
* Input and output signals

## Using Steel in your project

To use Steel in your project you must import all files from `rtl` directory to it. Then instantiate Steel using the following template:
```
steel_top #(

    .BOOT_ADDRESS()     // You must provide a 32-bit value. If omitted the core will use
                        // its default value, 32'h00000000.
    ) core (
    
    // Optional inputs must be hardwired to zero if not used.
    
    .CLK(),             // Clock source (required, input, 1-bit)
    .RESET(),           // Reset (required, input, synchronous, active high, 1-bit)
    .REAL_TIME(),       // Value read from a real time counter (optional, input, 64-bit)
    .I_ADDR(),          // Instruction address (output, 32-bit)
    .INSTR(),           // Instruction data (required, input, 32-bit)
    .D_ADDR(),          // Data address (output, 32-bit)
    .DATA_OUT(),        // Data to be written (output, 32-bit)
    .WR_REQ(),          // Write enable (output, 1-bit)
    .WR_MASK(),         // Write mask (output, 4-bit). Also known as "write strobe"
    .DATA_IN(),         // Data read from memory (required, input, 32-bit)
    .E_IRQ(),           // External interrupt request (optional, active-high, input, 1-bit)
    .T_IRQ(),           // Timer interrupt request (optional, active-high, input, 1-bit)
    .S_IRQ()            // Software interrupt request (optional, active-high, input, 1-bit)
    
);
```
Steel must be connected to a word-addressed memory with 1 clock cycle read/write latency, which means that the memory should take 1 clock cycle to complete both read and write operations. The signals used to fetch instructions and to read/write data were designed to facilitate the integration with FPGA Block RAMs and memory arrays. Read the documentation to learn how integrate the core to these devices.

## Running the project in Vivado

The `vivado` directory has a project created in Vivado for an Artix-7 FPGA. To run it, simply open it in Vivado. To run it on another device, change the project settings.

## About the author

The author is a computer engineering student at UFRGS (graduates at the end of 2020) and developed Steel Core for his undergraduate thesis.

Contact: rafaelcalcada@gmail.com / rafaelcalcada@hotmail.com

## Acknowledgements

My colleague [Francisco Knebel](https://github.com/FranciscoKnebel) deserves special thanks for his collaboration with this work.
