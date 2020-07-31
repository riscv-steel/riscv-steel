<p align="left">
  <img width="100" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>
<h2 align="left">About Steel Core</h2>
Steel is a RISC-V microprocessor softcore designed to be simple and easy to use. It is intended for use in FPGAs as a processing unit in embedded systems projects.
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
steel_top core(

    .CLK(  ),
    .RESET(  ),        
    .REAL_TIME(  ),        
    .I_ADDR(  ),
    .INSTR(  ),        
    .D_ADDR(  ),
    .DATA_OUT(  ),
    .WR_REQ(  ),
    .WR_MASK(  ),
    .DATA_IN(  ),        
    .E_IRQ(  ),
    .T_IRQ(  ),
    .S_IRQ(  )

);
```
Steel must be connected to a word-addressed memory with read/write latency of 1 clock cycle. It can be optionally connected to an interrupt controller and a real-time counter. Read the documentation to learn how integrate the core to these devices.

## Running the project in Vivado

The `vivado` directory has a project created in Vivado for an Artix-7 FPGA. To run it, simply open it in Vivado. To run it on another device, change the project settings.

## About the author

The author is a computer engineering student at UFRGS (graduates at the end of 2020) and developed Steel Core for his undergraduate thesis.

Contact: rafaelcalcada@gmail.com / rafaelcalcada@hotmail.com

## Acknowledgements

My colleague [Francisco Knebel](https://github.com/FranciscoKnebel) deserves special thanks for his collaboration with this work.
