## Welcome to RISC-V Steel

RISC-V Steel is a free and open platform for embedded systems development based on the RISC-V instruction set architecture. It is intended for use as a soft-core on FPGA boards and kits and features a 32-bit RISC-V processor core, programmable memory, UART transceiver and an API for software development.

### How to get started

The easiest way to get started with RISC-V Steel is to modify its [Hello World Project](https://github.com/riscv-steel/riscv-steel/tree/main/hello-world). In the [Quick Start Guide](https://riscv-steel.github.io/riscv-steel/quick-start-guide/) you find the steps to get this project running on an **Arty A7-35T** development board.

[**Check out the Quick Start Guide!**](https://riscv-steel.github.io/riscv-steel/quick-start-guide/)

Would you like a version of the Quick Start Guide for other FPGA boards and kits? Please let us know by opening a [new discussion](https://github.com/riscv-steel/riscv-steel/discussions).

### Features 

- RISC-V processor core
  
  - RV32I + Zicsr extension + Machine-mode
  - AXI4-Lite interface
  - Verified with [RISC-V Architectural Test Suite](https://github.com/riscv-non-isa/riscv-arch-test)
    
- Programmable RAM memory  
- UART  
- Software toolchain

### License

RISC-V Steel is distributed under the [MIT License](LICENSE.md).

### Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel/issues).

### Roadmap and project status

The following features are planned to be developed soon. You can help us contributing!

:white_check_mark: RV32I base instruction set

:white_check_mark: Zicsr extension

:white_check_mark: Support to M-mode

:white_check_mark: AXI4-Lite Master Interface

:black_square_button: Documentation *(in progress)*

:black_square_button: Software toolchain *(in progress)*

:black_square_button: SPI interface

:black_square_button: I2C interface

:black_square_button: GPIO interface

:black_square_button: Support to U-mode

:black_square_button: C extension

:black_square_button: M extension
