**RISC-V Steel** is a free collection of RISC-V IP cores. It features a 32-bit RISC-V processor and a configurable system-on-chip design plus a suite of software and hardware tools aimed to speed up building new RISC-V systems from scratch.

RISC-V Steel IP cores are written in Verilog and can be either synthesized on FPGAs or manufactured as custom integrated circuits.

## Available IP cores

#### [RISC-V 32-bit Processor](hardware/rvsteel-core.v)
Area-optimized 32-bit processor. Implements the RV32I instruction set of RISC-V, the Zicsr extension and the Machine-mode privileged architecture.

#### [RISC-V Steel SoC](hardware/rvsteel-soc.v)
All configurable system-on-chip design featuring RISC-V Steel 32-bit Processor + Tightly Coupled Memory + UART.

## Getting Started

[Check out the Getting Started Guide!](https://riscv-steel.github.io/riscv-steel/getting-started/)

To quickly get you started with RISC-V Steel we provide a [guide](https://riscv-steel.github.io/riscv-steel/getting-started/) demonstrating how to synthesize our [Hello World](https://github.com/riscv-steel/riscv-steel/tree/main/hello-world) demo for popular FPGA boards. The demo is an instance of RISC-V Steel SoC that runs a program that sends a Hello World message to a host computer via UART protocol. The goal of the demo is to introduce you to our SoC design so that you can expand it and run your own software in it.

## License

RISC-V Steel is distributed under the [MIT License](LICENSE.md).

## Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).
