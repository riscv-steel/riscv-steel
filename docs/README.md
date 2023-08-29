## RISC-V Steel Core

RISC-V Steel is a free and open 32-bit processor core that implements the RV32I instruction set of the RISC-V architecture. It is designed to be easily reused in new RISC-V based hardware designs, from small embedded projects to complex systems on a chip.

[Check out the Quick Start Guide!]([https://riscv-steel.github.io/riscv-steel-core/getting-started/](https://riscv-steel.github.io/riscv-steel-core/quick-start-guide/))

### Features

- Implemented RISC-V ISA modules: **RV32I**, **Zicsr**, **Machine-Mode** privileged architecture
- Native AXI4 Lite Master Interface
- Verified with [RISC-V Architectural Test Suite](https://github.com/riscv-non-isa/riscv-arch-test) - passes all tests
- Single [source file](../riscv-steel-core.v) (Verilog)
- Free and open-source ([MIT License](../LICENSE))
- [Quick start project demo](https://riscv-steel.github.io/riscv-steel-core/getting-started/)

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
