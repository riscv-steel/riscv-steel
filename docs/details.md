# Implementation details

This section contains information on implementation details. It is intended for those who want to know more about how Steel works.

## Implemented CSRs

The control and status registers implemented in Steel are shown in table 1, below. Other M-mode registers not shown in the table return the hardwired value defined by the RISC-V specifications when read.

<p align=left>
<strong>Table 1.</strong> Implemented CSRs
</p>

| **CSR**            | **Name**                             | **Address** |
| :----------------- | :----------------------------------- | ----------: |
| cycle              | *Cycle Counter*                      | 0xC00       |
| time               | *System Timer*                       | 0xC01       |
| instret            | *Instructions Retired*               | 0xC02       |
| mstatus            | *Machine Status*                     | 0x300       |
| misa               | *Machine ISA*                        | 0x301       |
| mie                | *Machine Interrupt Enable*           | 0x304       |
| mtvec              | *Machine Trap Vector*                | 0x305       |
| mscratch           | *Machine Scratch*                    | 0x340       |
| mepc               | *Machine Exception Program Counter*  | 0x341       |
| mcause             | *Machine Cause*                      | 0x342       |
| mtval              | *Machine Trap Value*                 | 0x343       |
| mip                | *Machine Interrupt Pending*          | 0x344       |
| mcycle             | *Machine Cycle Counter*              | 0xB00       |
| minstret           | *Machine Instructions Retired*       | 0xB01       |
| mcountinhibit      | *Machine Counter Inhibit*            | 0x320       |

## Modules

### Decoder

The Decoder (**decoder.v**) decodes the instruction and generates the signals that control the memory, the Load Unit, the Store Unit, the ALU, the two register files (Integer and CSR), the Immediate Generator and the Writeback Multiplexer. The description of its input and output signals are shown in table 2, below.

<p align=left>
<strong>Table 2.</strong> Decoder input/output signals
</p>

| **Signal name**                       | **Width**  | **Direction**  | **Description**                                                                                                       |
| :------------------------------------ | :--------- | :------------- | :-------------------------------------------------------------------------------------------------------------------- |
| **OPCODE\_6\_TO\_2**                     | 5 bits     | Input          | Connected to the instruction *opcode* field.                                                                          |
| **FUNCT7\_5**                          | 1 bit      | Input          | Connected to the instruction *funct7* field.                                                                          |
| **FUNCT3**                            | 3 bits     | Input          | Connected to the instruction *funct3* field.                                                                          |
| **IADDER\_OUT\_1\_TO\_0**                 | 2 bits     | Input          | Used to verify the alignment of loads and stores.                                                                     |
| **TRAP\_TAKEN**                        | 1 bit      | Input          | When set high indicates that a trap will be taken in the next clock cycle. Connected to the Machine Control module.       |
| **ALU\_OPCODE**                        | 4 bits     | Output         | Selects the operation to be performed by the ALU.                                     |
| **MEM\_WR\_REQ**                        | 1 bit      | Output         | When set high indicates a request to write to memory.                                                                     |
| **LOAD\_SIZE**                         | 2 bits     | Output         | Indicates the word size of load instruction. |
| **LOAD\_UNSIGNED**                     | 1 bit      | Output         | Indicates the type of load instruction (signed or unsigned).  |
| **ALU\_SRC**                           | 1 bit      | Output         | Selects the ALU 2nd operand.                                                                                          |
| **IADDER\_SRC**                        | 1 bit      | Output         | Selects the Immediate Adder 2nd operand.                                                                              |
| **CSR\_WR\_EN**                         | 1 bit      | Output         | Controls the WR\_EN input of CSR Register File.                                                                        |
| **RF\_WR\_EN**                          | 1          | Output         | Controls the WR\_EN input of Integer Register File.  |
| **WB\_MUX\_SEL**                        | 3          | Output         | Selects the data to be written in the Integer Register File.                                                          |
| **IMM\_TYPE**                          | 3          | Output         | Selects the immediate based on the type of the instruction.                                                           |
| **CSR\_OP**                            | 3          | Output         | Selects the operation to be performed by the CSR Register File (read/write, set or clear).                            |
| **ILLEGAL\_INSTR**                     | 1 bit      | Output         | When set high indicates that an invalid or not implemented instruction was fetched from memory.                           |
| **MISALIGNED\_LOAD**                   | 1 bit      | Output         | When set high indicates an attempt to read data in disagreement with the memory alignment rules.  |
| **MISALIGNED\_STORE**                  | 1 bit      | Output         | When set high indicates an attempt to write data to memory in disagreement with the memory alignment rules.  |

### ALU

The ALU (**alu.v**) applies ten distinct logical and arithmetic operations in parallel to two 32-bit operands, outputting the result selected by **OPCODE**. The ALU input/output signals and the opcodes are shown in tables 3 and 4, below.

The opcode values were assigned to facilitate instruction decoding. The most significant bit of **OPCODE** matches with the second most significant bit in the instruction **funct7** field. The remaining three bits match with the instruction **funct3** field.

<p align=left>
<strong>Table 3.</strong> ALU input/output signals
</p>

| **Signal name**            | **Width**  | **Direction**  | **Description**                                                                                                    |
| :------------------------- | :--------- | :------------- | :----------------------------------------------------------------------------------------------------------------- |
| **OP\_1**                   | 32 bits    | Input          | Operation first operand.                                                                                           |
| **OP\_2**                   | 32 bits    | Input          | Operation second operand.                                                                                          |
| **OPCODE**                 | 4 bits     | Input          | Operation code. This signal is driven by *funct7* and *funct3* instruction fields.                                 |
| **RESULT**                 | 32 bits    | Output         | Result of the requested operation.                                                                                 |

<p align=left>
<strong>Table 4.</strong> ALU opcodes
</p>

| **Opcode**          | **Operation**             |  **Binary value** |
| :------------------ | :------------------------ | :---------------- |
| **ALU\_ADD**         | Addition                  | 4'b0000           |
| **ALU\_SUB**         | Subtraction               | 4'b1000           |
| **ALU\_SLT**         | Set on less than          | 4'b0010           |
| **ALU\_SLTU**        | Set on less than unsigned | 4'b0011           |
| **ALU\_AND**         | Bitwise logical AND       | 4'b0111           |
| **ALU\_OR**          | Bitwise logical OR        | 4'b0110           |
| **ALU\_XOR**         | Bitwise logical XOR       | 4'b0100           |
| **ALU\_SLL**         | Logical left shift        | 4'b0001           |
| **ALU\_SRL**         | Logical right shift       | 4'b0101           |
| **ALU\_SRA**         | Arithmetic right shift    | 4'b1101           |

### Integer Register File

The Integer Register File (**integer\_file.v**) has 32 general-purpose registers and supports read and write operations. Reads are requested by pipeline stage 2 and provide data from one or two registers. Writes are requested by stage 3 and put the data coming from the Writeback Multiplexer into the selected register. If stage 3 requests to write to a register being read by stage 2, the data to be written is immediately forwarded to stage 2. Each operation is driven by a distinct set of signals, shown in the tables 5 and 6, below.

<p align=left>
<strong>Table 5.</strong> Integer Register File signals for read
</p>

| **Signal name**        | **Width**  | **Direction**  | **Description**                                                                                                                                                         |
| :--------------------- | :--------- | :------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RS\_1\_ADDR**          | 5 bits     | Input          | *Register source 1 address*. The data is placed at **RS_1** immediately after an address change.                                                                            |
| **RS\_2\_ADDR**          | 5 bits     | Input          | *Register source 2 address*. The data is placed at **RS_2** immediately after an address change.                                                                            |
| **RS\_1**               | 32 bits    | Output         | Data read (source 1).                                                                                                                                                   |
| **RS\_2**               | 32 bits    | Output         | Data read (source 2).                                                                                                                                                   |

<p align=left>
<strong>Table 6.</strong> Integer Register File signals for write
</p>

| **Signal name**        | **Width**  | **Direction**  | **Description**                                                                                                                                                          |
| :--------------------- | :--------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RD\_ADDR**            | 5 bits     | Input          | *Destination register address*.                                                                                                                                          |
| **RD**                 | 32 bits    | Input          | Data to be written in the destination register.                                                                                                                          |
| **WR\_EN**              | 1 bit      | Input          | *Write enable*. When set high, the data placed on RD is written in the destination register at the next clock rising edge.                                                   |

### Branch Unit

The Branch Unit (**branch\_unit.v**) decides if a branch instruction must be taken or not. It receives two operands from the Integer Register File and, based on the value of *opcode* and *funct3* instruction fields, decides the branch. Jump instructions are interpreted as branches that must always be taken. Internally, the unit realizes just two comparisions, deriving other four from them. Table 7 (below) shows the module input and output signals.

<p align=left>
<strong>Table 7.</strong> Branch Unit input/output signals
</p>

| **Signal name**       | **Width**  | **Direction**  | **Description**                                          |
| :-------------------- | :--------- | :------------- | :------------------------------------------------------- |
| **OPCODE\_6\_TO\_2**     | 5 bits     | Input          | Connected to the *opcode* instruction field.             |
| **FUNCT3**            | 3 bits     | Input          | Connected to the *funct3* instruction field.             |
| **RS1**               | 32 bits    | Input          | Connected to the Integer Register File 1st operand source.       |
| **RS2**               | 32 bits    | Input          | Connected to the Integer Register File 2nd operand source.       |
| **BRANCH\_TAKEN**      | 1 bit      | Output         | High if the branch must be taken, low otherwise.         |

### Load Unit

The Load Unit (**load\_unit.v**) reads the **DATA_IN** input signal and forms a 32-bit value based on the load instruction type (encoded in the *funct3* field). The formed value (placed on **OUTPUT**) can then be written in the Integer Register File. The module input and output signals are shown in table 8. The value of **OUTPUT** is formed as shown in table 9.

<p align=left>
<strong>Table 8.</strong> Load Unit input/output signals
</p>

| **Signal name**              | **Width**  | **Direction**  | **Description**                                                                                                                                            |
| :--------------------------- | :--------- | :------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **LOAD\_SIZE**                | 2 bits     | Input          | Connected to the two least significant bits of the *funct3* instruction field.                                                                             |
| **LOAD\_UNSIGNED**            | 1 bit      | Input          | Connected to the most significant bit of the *funct3* instruction field.                                                                                   |
| **DATA\_IN**                  | 32 bits    | Input          | 32-bit word read from memory.                                                                                                                              |
| **IADDER\_OUT\_1\_TO\_0**        | 2 bits     | Input          | Indicates the byte/halfword position in **DATA_IN**. Used only with load byte/halfword instructions.                                                           |
| **OUTPUT**                   | 32 bits    | Output         | 32-bit value to be written in the Integer Register File.                                                                                                   |

<p align=left>
<strong>Table 9.</strong> Load Unit output generation
</p>

| **LOAD\_SIZE**               | **Effect on OUTPUT**                                                                                                                                                                   |
| :-------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **2'b00**                   | The byte in the position indicated by **IADDER_OUT_1_TO_0** is placed on the least significant byte of **OUTPUT**. The upper 24 bits are filled according to the **LOAD_UNSIGNED** signal.         |
| **2'b01**                   | The halfword in the position indicated by **IADDER_OUT_1_TO_0** is placed on the least significant halfword of **OUTPUT**. The upper 16 bits are filled according to the **LOAD_UNSIGNED** signal. |
| **2'b10**                   | All bits of **DATA_IN** are placed on OUTPUT.                                                                                                                                              |
| **2'b11**                   | All bits of **DATA_IN** are placed on OUTPUT.                                                                                                                                              |
| **LOAD\_UNSIGNED**           | **Effect on OUTPUT**                                                                                                                                                                   |
| **1'b0**                    | The remaining bits of **OUTPUT** are filled with the sign bit.                                                                                                                             |
| **1'b1**                    | The remaining bits of **OUTPUT** are filled with zeros.                                                                                                                                    |

### Store Unit

The Store Unit (**store\_unit.v**) drives the signals that interface with memory. It places the data to be written (which can be a byte, halfword or word) in the right position in **DATA_OUT** and sets the value of **WR_MASK** in an appropriate way. Table 10 (below) shows the unit input and output signals.

<p align=left>
<strong>Table 10.</strong> Store Unit input/output signals
</p>

| **Signal name**       | **Width**  | **Direction**  | **Description**                                                                                                                                                           |
| :-------------------- | :--------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **FUNCT3**            | 3 bits     | Input          | Connected to the *funct3* instruction field. Indicates the data size (byte, halfword or word).                                                                            |
| **IADDER\_OUT**        | 32 bits    | Input          | Contains the address (possibly unaligned) where the data must be written.                                                                                                 |
| **RS2**               | 32 bits    | Input          | Connected to Integer Register File source 2. Contains the data to be written (possibly in the wrong position).                                                           |
| **MEM\_WR\_REQ**        | 1 bit      | Input          | Control signal generated by the Control Unit. When set high indicates a request to write to memory.                                                                           |
| **DATA\_OUT**          | 32 bits    | Output         | Contains the data to be written in the right position.                                                                                                                    |
| **D\_ADDR**            | 32 bits    | Output         | Contains the address (aligned) where the data must be written.                                                                                                            |
| **WR\_MASK**           | 4 bits     | Output         | A bitmask that indicates which bytes of **DATA_OUT** must be written.   |
| **WR\_REQ**            | 1 bit      | Output         | When set high indicates a request to write to memory. |

### Immediate Generator

The Immediate Generator (**imm\_generator.v**) rearranges the immediate bits contained in the instruction and, if necessary, sign-extends it to form a 32-bit value. The unit is controlled by the **IMM_TYPE** signal, generated by the Control Unit. Table 11 shows the unit input and output signals.

<p align=left>
<strong>Table 11.</strong> Immediate Generator input/output signals
</p>

| **Signal name**     | **Width**  | **Direction**  | **Description**                                                                                                                                    |
| :------------------ | :--------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| **INSTR**           | 25 bits    | Input          | Connected to the instruction bits (32 to 7).                                                                                                       |
| **IMM\_TYPE**        | 2 bits     | Input          | Control signal generated by the Control Unit that indicates the type of immediate that must be generated.                                          |
| **IMM**             | 32 bits    | Output         | 32-bit generated immediate.                                                                                                                        |

### CSR Register File

The CSR Register File (**csr_file.v**) has the control and status registers required for the implementation of M-mode. Read/write, set and clear operations can be applied to the registers. Table 12 shows the unit input and output signals, except those used for communication with the Machine Control module, which are shown in table 13.

<p align=left>
<strong>Table 12.</strong> CSR Register File input/output signals
</p>

| **Signal name**                | **Width**  | **Direction**  | **Description**                                                                                                                                |
| :----------------------------- | :--------- | :------------- | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| **WR\_EN**                      | 1 bit      | Input          | *Write enable*. When set high, updates the CSR addressed by **CSR_ADDR** at the next clock rising edge according to the operation selected by **CSR_OP**.  |
| **CSR\_ADDR**                   | 12 bits    | Input          | Address of the CSR to read/write/modify.                                                                                                       |
| **CSR\_OP**                     | 3 bits     | Input          | Control signal generated by the Control Unit. Selects the operation to be performed (read/write, set, clear or no operation).                  |
| **CSR\_UIMM**                   | 5 bits     | Input          | *Unsigned immediate*. Connected to the five least significant bits from the Immediate Generator output.                                        |
| **CSR\_DATA\_IN**                | 32 bits    | Input          | In write operations, contains the data to be written. In set or clear operations, contains a bit mask.                                         |
| **PC**                         | 32 bits    | Input          | *Program counter* value. Used to update the **mepc** CSR.                                                                                          |
| **E\_IRQ**                      | 1 bit      | Input          | *External interrupt request*. Used to update the MEIP bit of **mip** CSR.                                                                          |
| **T\_IRQ**                      | 1 bit      | Input          | *Timer interrupt request*. Used to update the MTIP bit of **mip** CSR.                                                                             |
| **S\_IRQ**                      | 1 bit      | Input          | *Software interrupt request*. Used to update the MSIP bit of **mip** CSR.                                                                          |
| **REAL\_TIME**                  | 64 bits    | Input          | Current value of the real time counter. Used to update the **time** and **timeh** CSRs.                                                                |
| **CSR\_DATA\_OUT**               | 32 bits    | Output         | Contains the data read from the CSR addressed by **CSR_ADDR**.                                                                                     |
| **EPC\_OUT**                    | 32 bits    | Output         | Current value of the **mepc** CSR.                                                                                                                 |
| **TRAP\_ADDRESS**               | 32 bits    | Output         | Address of the trap handler first instruction.                                                                                                 |

<p align=left>
<strong>Table 13.</strong> CSR Register File and Machine Control module interface signals
</p>

| **Signal name**                                                                                                    | **Width**  | **Direction**  | **Description**                                                                                                                                            |
| :----------------------------------------------------------------------------------------------------------------- | :--------- | :----------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **I\_OR\_E**                                                                                                         | 1 bit      | Input              | *Interrupt or exception*. When set high indicates an interrupt, otherwise indicates an exception. Used to update the most significant bit of **mcause** register.  |
| **CAUSE\_IN**                                                                                                       | 4 bits     | Input              | Contains the exception code. Used to update the **mcause** register.                                                                               |
| **SET\_CAUSE**                                                                                                      | 1 bit      | Input              | When set high updates the **mcause** register with the values of **I_OR_E** and **CAUSE_IN**.                                                                              |
| **SET\_EPC**                                                                                                        | 1 bit      | Input              | When set high, updates the **mepc** register with the value of PC.                                                                                                 |
| **INSTRET\_INC**                                                                                                    | 1 bit      | Input              | When set high enables the instructions retired counting.                                                                                                       |
| **MIE\_CLEAR**                                                                                                      | 1 bit      | Input              | When set high sets the MIE bit of **mstatus** to zero (which globally disables interrupts). The old value of MIE is saved in the **mstatus** MPIE field.               |
| **MIE\_SET**                                                                                                        | 1 bit      | Input              | When set high sets the MPIE bit of **mstatus** to one. The old value of MPIE is saved in the **mstatus** MIE field.                                                    |
| **MIE**                                                                                                            | 1 bit      | Output             | Current value of MIE bit of **mstatus** CSR.                                                                                                                   |
| **MEIE\_OUT**                                                                                                       | 1 bit      | Output             | Current value of MEIE bit of **mie** CSR.                                                                                                                      |
| **MTIE\_OUT**                                                                                                       | 1 bit      | Output             | Current value of MTIE bit of **mie** CSR.                                                                                                                      |
| **MSIE\_OUT**                                                                                                       | 1 bit      | Output             | Current value of MSIE bit of **mie** CSR.                                                                                                                      |
| **MEIP\_OUT**                                                                                                       | 1 bit      | Output             | Current value of MEIP bit of **mip** CSR.                                                                                                                      |
| **MTIP\_OUT**                                                                                                       | 1 bit      | Output             | Current value of MTIP bit of **mip** CSR.                                                                                                                      |
| **MSIP\_OUT**                                                                                                       | 1 bit      | Output             | Current value of MSIP bit of **mip** CSR.                                                                                                                      |

### Machine Control

The Machine Control module (**machine_control.v**) implements the M-mode, controlling the the program counter generation and updating several CSRs. It has a special communication interface with the CSR Register File, already shown in table 13 (above). Its input and output signals are shown in table 14 (below).

Internally, the module implements the finite state machine shown in figure 1 (below).

<p align=left>
<strong>Table 14.</strong> Machine Control input/output signals
</p>

| **Signal name**                      | **Width**  | **Direction**  | **Description**                                                                                                                                                   |
| :----------------------------------- | :--------- | :------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ILLEGAL\_INSTR**                    | 1 bit      | Input          | *Illegal instruction*. When set high indicates that an invalid or not implemented instruction was fetched from memory.                                                |
| **MISALIGNED\_INSTR**                 | 1 bit      | Input          | *Misaligned instruction*. When set high indicates an attempt to fetch an instruction which address is in disagreement with the memory alignment rules.  |
| **MISALIGNED\_LOAD**                  | 1 bit      | Input          | *Misaligned load*. When set high indicates an attempt to read data in disagreement with the memory alignment rules.                                    |
| **MISALIGNED\_STORE**                 | 1 bit      | Input          | *Misaligned store*. When set high indicates an attempt to write data to memory in disagreement with the memory alignment rules.                        |
| **OPCODE\_6\_TO\_2**                    | 5 bits     | Input          | Value of the *opcode* instruction field.                                                                                                                          |
| **FUNCT3**                           | 3 bits     | Input          | Value of the *funct3* instruction field.                                                                                                                          |
| **FUNCT7**                           | 7 bits     | Input          | Value of the *funct7* instruction field.                                                                                                                          |
| **RS1\_ADDR**                         | 5 bits     | Input          | Value of the *rs1* instruction field.                                                                                                                             |
| **RS2\_ADDR**                         | 5 bits     | Input          | Value of the *rs2* instruction field.                                                                                                                             |
| **RD\_ADDR**                          | 5 bits     | Input          | Value of the *rd* instruction field.                                                                                                                              |
| **E\_IRQ**                            | 1 bit      | Input          | *External interrupt request*.                                                                                                                                     |
| **T\_IRQ**                            | 1 bit      | Input          | *Timer interrupt request*.                                                                                                                                        |
| **S\_IRQ**                            | 1 bit      | Input          | *Software interrupt request*.                                                                                                                                     |
| **PC\_SRC**                           | 2 bit      | Output         | Selects the program counter source.                                                                                                                               |
| **FLUSH**                            | 1 bit      | Output         | Flushes the pipeline when set.                                                                                                                                    |
| **TRAP\_TAKEN**                       | 1 bit      | Output         | When set high indicates that a trap will be taken in the next clock cycle.                                                                                            |

<p align="center">
<img src="../images/steel-fsm.png" width="80%"></img>
</br>
</br>
<strong>Fig. 1:</strong> Machine Control finite state machine
</p>
![Machine Control FSM]()
