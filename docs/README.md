## RISC-V Steel Core

RISC-V Steel is a free and open 32-bit processor core that implements the RV32I instruction set of the RISC-V architecture. It is designed to be easily reused in new RISC-V based hardware designs, from small embedded projects to complex systems on a chip.

### How to get started

The easiest way to start a new project with RISC-V Steel is to modify the [Hello World](https://github.com/riscv-steel/riscv-steel-core/tree/main/hello-world-project) project. It contains some basic devices in addition to the core so that it can be easily expanded into a larger system. The steps to run this project on an **Arty A7-35T** development board can be found in the Quick Start Guide.

[**Check out the Quick Start Guide!**](https://riscv-steel.github.io/riscv-steel-core/quick-start-guide/)

Would you like a version of the Quick Start Guide for other FPGAs and development boards? Please let us know by opening a [new discussion](https://github.com/riscv-steel/riscv-steel-core/discussions).

### Features

- **RV32I** base integer instruction set
- **Zicsr** extension
- **Machine-Level** privileged ISA
- Native **AXI4 Lite** Master Interface
- Verified with [RISC-V Architectural Test Suite](https://github.com/riscv-non-isa/riscv-arch-test)
- Single [source file](../riscv-steel-core.v) (Verilog)
- Free and open-source ([MIT License](../LICENSE))

### License

RISC-V Steel Core is distributed under the [MIT License](../LICENSE).

### Project goal

The project goal is to help expand the adoption of the RISC-V architecture by creating free and open RISC-V hardware that is easy to reuse.

### Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel-core/issues).

### Project roadmap

- RV32I base instruction set ✔️
- Zicsr extension ✔️
- Support to M-mode ✔️
- AXI4-Lite Master Interface ✔️
- Documentation
- Support to U-mode
- C extension
- M extension
