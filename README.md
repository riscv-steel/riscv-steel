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

## Licence

Steel is distributed under the MIT License.

## Microarchitecture

Steel has 3 pipeline stages, a single execution thread and issues only one instruction per clock cycle. Therefore, all instructions are executed in program order. The figure below shows the tasks performed by each pipeline stage. Detailed information about Steel microarchitecture can be found in the documentation.

<p align="left">
  <img width="700" src="https://user-images.githubusercontent.com/22325319/85181650-d5af6b00-b25c-11ea-8f36-e68600e4c248.png" caption="Blablalbal">
</p>

