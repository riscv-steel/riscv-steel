<p><img src="https://user-images.githubusercontent.com/22325319/203945687-53910363-5be9-46f9-96fc-c31c78419ccf.png" width="150"></p>

**Steel** is a RISC-V processor core. It implements the `RV32I` base instruction set, the `Zicsr` extension, and the `M-mode` privileged architecture of the [RISC-V ISA specifications](https://riscv.org/technical/specifications/).

It passes all tests from [RISC-V Test Suite](https://github.com/riscv-software-src/riscv-tests) and [RISC-V Compatibility Test Framework v2.0](https://github.com/riscv-non-isa/riscv-arch-test).

### Overview

- [x] Free and open-source ([MIT License](LICENSE))
- [x] RV32I + Zicsr + M-mode
- [x] Tested and production-ready
- [x] Single-issue, in-order, 3-stage pipeline (fetch / decode / execute)
- [x] Single source file written in human-readable Verilog
- [x] [Documentation](https://rafaelcalcada.github.io/steel-core/) and examples available
- [x] [CoreMark](https://github.com/eembc/coremark) score: 1.36 CoreMarks/MHz

### Uses

Steel is designed to be easily integrated into microcontroller / embedded systems / system-on-chip designs as the main or auxiliary processing unit. It can be used both as a soft-core with FPGAs or as a module in ASIC designs.

### Documentation

Documentation is available at [https://rafaelcalcada.github.io/steel-core/](https://rafaelcalcada.github.io/steel-core/). There you can find:
- [x] [Getting Started](https://rafaelcalcada.github.io/steel-core/getting/) guide showing how to integrate **Steel** into a project
- [x] How you can build software to run on **Steel**
- [x] Timing diagrams showing how **Steel** communicates with memory and peripherals
- [x] How **Steel** handle exceptions, interrupts and traps
- [x] Implementation details with RTL diagrams

### License

Steel is distributed under the [MIT License](LICENSE).

### History

Steel was developed for the author's final year project in Computer Engineering. 

### Contact

Rafael Calcada (rafaelcalcada@gmail.com)

### Acknowledgements

My friend [Francisco Knebel](https://github.com/FranciscoKnebel) and my advisor [Ricardo Reis](https://www.linkedin.com/in/ricardo-reis-bab4575/) deserve special thanks for their collaboration in this work.
