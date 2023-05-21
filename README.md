### About the project

RISC-V Steel Core is a free and open 32-bit processor core that implements the RV32I instruction set of the RISC-V architecture. It is designed so you can easily reuse it in new RISC-V based hardware designs, from small embedded projects to complex systems on a chip.

[Check out how to get the **Hello World project** running on an FPGA!](https://riscv-steel.github.io/riscv-steel-core/getting-started/)

### Core features

- **RV32I** base integer instruction set
- **Zicsr** Control and Status Register extension
- **Machine-level** privileged architecture
- 3-stage pipeline, in-order execution
- Passes all [RISC-V Compatibility Test Framework v2.0](https://github.com/riscv-non-isa/riscv-arch-test) tests
- Single [source file](riscv_steel_core.v) (Verilog)
- Free and open-source ([MIT License](LICENSE.md))

### License

RISC-V Steel Core is distributed under [MIT License](LICENSE.md).

### Project goal

The project goal is to help expand the adoption of the RISC-V architecture by creating free and open RISC-V hardware that is easy to reuse.

### Need help?

Please open a [new issue](https://github.com/riscv-steel/riscv-steel-core/issues).

### Project roadmap

- RV32I base instruction set ✔️
- Zicsr extension ✔️
- Support to M-mode ✔️
- Documentation
- Support to U-mode
- C extension
- M extension
