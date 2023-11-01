## RISC-V Steel

**RISC-V Steel** is a free collection of RISC-V based IP cores. It features a 32-bit RISC-V processor and a suite of software and hardware tools aimed to speed up building new RISC-V systems from scratch.

RISC-V Steel IP cores are written in Verilog and can be either synthesized on FPGAs or reused in system-on-a-chip designs.

### How to get started

The easiest way to get started with RISC-V Steel is to synthesize its [Hello World](https://github.com/riscv-steel/riscv-steel/tree/main/hello-world) demo on an FPGA and then modify it to meet your project requirements. We provide a guide with the steps to synthesize it on three different Digilent FPGA boards: Arty A7-35T, Arty A7-100T, and Cmod-A7.

[Get Started with RISC-V Steel!](https://riscv-steel.github.io/riscv-steel/getting-started/)

### Available IP cores

#### [RISC-V Processor Core](hardware/rvsteel_core.v)
Unpipelined RV32I processor + Zicsr extension + Machine-mode + AXI4-Lite interface

#### [RISC-V Steel SoC](hardware/rvsteel_soc.v)
All configurable system-on-chip with RISC-V processor + memory + UART

### License

RISC-V Steel is distributed under the [MIT License](LICENSE.md).

### Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).

### Roadmap and project status

The following features are planned to be developed soon. You can help us contributing!

:white_check_mark: RV32I base instruction set  
:white_check_mark: Zicsr extension  
:white_check_mark: Support to M-mode  
:white_check_mark: AXI4-Lite Manager Interface  
:arrow_forward: Documentation *(in progress)*  
:arrow_forward: Software toolchain *(in progress)*  
:arrow_forward: SPI interface  
:arrow_forward: I2C interface  
:arrow_forward: GPIO interface  
:arrow_forward: Support to U-mode  
:arrow_forward: C extension  
:arrow_forward: M extension  
