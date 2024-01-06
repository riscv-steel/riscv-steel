# Processor Core IP Unit Tests

This directory provides unit tests for all RISC-V instructions implemented in the Processor Core IP. It consists of a testbench for **AMD Xilinx Vivado Simulator** (`rvsteel_core_unit_tests.v`), unit tests programs and reference signatures generated by running the tests.

The unit tests programs and their signatures are imported from [RISC-V Architecture Test](https://github.com/riscv-non-isa/riscv-arch-test/tree/old-framework-2.x) repository.

## How to run the unit tests?

* Open **AMD Xilinx Vivado**
* Click on **Run Tcl script...** in the **Tools** menu
* Select the file `create-test-project.tcl` (located in this folder) and click **Ok**

    A Vivado project to run the unit tests will be created.

* To run the unit tests type `launch_simulation; run -all` in Vivado **Tcl Console** and press Enter.

A successful run ends with the message below:

```
------------------------------------------------------------------------------------------

RISC-V Steel Processor Core IP passed ALL unit tests from RISC-V Architectural Test Suite

------------------------------------------------------------------------------------------
$finish called at time : ******* ns
run: Time (s): cpu = **:**:** ; elapsed = **:**:** . Memory (MB): peak = ****.*** ;
```