## Welcome to RISC-V Steel

RISC-V Steel is a free and open platform for embedded systems development based on the RISC-V instruction set architecture. It is intended for use as a soft-core on FPGA boards and kits and features a 32-bit RISC-V processor core, programmable memory, UART transceiver and an API for software development.

### How to get started

The easiest way to start with RISC-V Steel is to modify the [Hello World](https://github.com/riscv-steel/riscv-steel/tree/main/hello-world) project. Steps for running this project on an **Arty A7-35T** FPGA board can be found in the [Quick Start Guide](https://riscv-steel.github.io/riscv-steel/quick-start-guide/).

[**Check out the Quick Start Guide!**](https://riscv-steel.github.io/riscv-steel/quick-start-guide/)

Would you like a version of it for other FPGA boards and kits? Please let us know by opening a [new discussion](https://github.com/riscv-steel/riscv-steel/discussions).

### Features

- RISC-V processor core
  
  - RV32I + Zicsr extension + Machine-mode
  - AXI4-Lite interface
  - Verified with [RISC-V Architectural Test Suite](https://github.com/riscv-non-isa/riscv-arch-test)
    
- Programmable RAM memory  
- UART  
- Software toolchain

### License

RISC-V Steel is distributed under the [MIT License](../LICENSE).

### Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).

### Roadmap and project status

- RV32I base instruction set ✔️
- Zicsr extension ✔️
- Support to M-mode ✔️
- AXI4-Lite Master Interface ✔️
- Documentation - in progress
- Software toolchain - in progress
- SPI interface
- I2C interface
- GPIO interface
- Support to U-mode
- C extension
- M extension
