<p align="center"><img src="https://user-images.githubusercontent.com/22325319/203945687-53910363-5be9-46f9-96fc-c31c78419ccf.png" width="150"></p>

**Steel** is a RISC-V processor core. It implements the `RV32I` base instruction set, the `Zicsr` extension, and the Machine-level ISA of the [RISC-V ISA specifications](https://riscv.org/technical/specifications/). It passes all tests from [RISC-V Compatibility Test Framework v2.0](https://github.com/riscv-non-isa/riscv-arch-test).

### Overview

- [x] Free and open-source ([MIT License](LICENSE))
- [x] RV32I + Zicsr + Machine-level ISA
- [x] 3-stage pipeline, in-order execution
- [x] Tested and production-ready
- [x] Single source file written in human-readable Verilog

### Uses

Steel is designed to be easily integrated into microcontroller / embedded systems / system-on-chip designs as the main or auxiliary processing unit. It can be used both as a soft-core with FPGAs or as a module in ASIC designs.

### Documentation

**Steel** has gone through significant changes recently, making the old docs obsolete. **New docs will be available soon.**

### License

Steel is distributed under the [MIT License](LICENSE).

### History

Steel was developed for the author's final year project in Computer Engineering. 

### Contact

Rafael Calcada (rafaelcalcada@gmail.com)

### Acknowledgements

My friend [Francisco Knebel](https://github.com/FranciscoKnebel) and my advisor [Ricardo Reis](https://www.linkedin.com/in/ricardo-reis-bab4575/) deserve special thanks for their collaboration in this work.
