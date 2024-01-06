# Processor Core IP Tests

This directory contains tests to verify that instructions implemented by the Processor Core IP are compliant with the RISC-V specifications.

The tests consist of Verilog simulations that run unit test programs from the [RISC-V Architecture Test](https://github.com/riscv-non-isa/riscv-arch-test/) repository. Each unit test program tests an instruction and generates a signature after its execution, which is compared to a golden reference. The signature only matches the golden reference if the instruction implements its function correctly.

The tests can be run with **Verilator** or **AMD Xilinx Vivado**. A different Verilog simulation file is provided for each tool. All unit tests are run in sequence by the simulation. At the end of a successful run the following message is printed:

```
------------------------------------------------------------------------------------------
RISC-V Steel Processor Core IP passed ALL unit tests from RISC-V Architectural Test
------------------------------------------------------------------------------------------
```

## How do I run the tests?

### Using Verilator

We provide a shell script to verilate and run the tests. Verilator version 5.0 or higher is required.

```bash
chmod +x run_verilator.sh # give permissions to run this script
./run_verilator.sh
```

### Using AMD Xilinx Vivado

* Open **AMD Xilinx Vivado**
* Click on **Run Tcl script...** in the **Tools** menu
* Select the file `create-test-project.tcl` and click **Ok**

    A Vivado project to run the unit tests will be created.

* To run the unit tests type `launch_simulation; run -all` in Vivado **Tcl Console** and press Enter.

