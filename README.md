<p align="center">
  <img width="200" src="https://user-images.githubusercontent.com/22325319/85179004-38513880-b256-11ea-9a1a-4d204183bb13.png">
</p>
<h2 align="left">About Steel Core</h2>

Steel is a RISC-V microprocessor softcore designed to be simple and easy to use. It can be used as processing unit in microcontrollers and embedded systems.

**Key features:**
* RV32IZicsr implementation
* Small and easy to use
* 3 pipeline stages
* Single-issue
* M-mode support
* Targeted for use in FPGAs
* Full documentation

<!-- TABLE OF CONTENTS -->
### Table of Contents

* [Microarchitecture overview](#microarchitecture-overview)
* [License](#dependencies)
* [Contact](#contact)
* [Acknowledgments](#acknowledgments)

### Microarchitecture overview

Steel has 3 pipeline stages, a single execution thread and issues only one instruction per clock cycle. Therefore, all instructions are executed in program order. The figure below shows the tasks performed by each pipeline stage. In the first stage, the core generates the program counter and fetches the instruction from memory. In the second, the instruction is decoded and the control signals for all units are generated. Branches, jumps and stores are executed in advance in this stage, which also generates the immediates and fetches the data from memory for load instructions. The last stage executes all other instructions and writes back the results in the register file. More information about Steel microarchitecture can be found in the documentation.

<p align="left">
  <img width="700" src="https://user-images.githubusercontent.com/22325319/85181650-d5af6b00-b25c-11ea-8f36-e68600e4c248.png" caption="Blablalbal">
</p>



