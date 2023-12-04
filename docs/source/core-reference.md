# RISC-V Steel Core </br><small>Reference Guide</small>

## Introduction

RISC-V Steel Core is a 32-bit processor design that implements the RV32I instruction set, the Zicsr extension and the Machine-mode privileged architecture of RISC-V.

RISC-V Steel Core is a single-issue, in-order, unpipelined processor core.

RISC-V Steel Core can run real-time operating systems and bare-metal embedded software. It is designed to work as a processing unit in a wide variety of embedded applications.

## General information

This section provides information about the source files, the input/output signals and the configuration parameters of RISC-V Steel Core.

### Source files

RISC-V Steel Core has a single source file, **`rvsteel-core.v`**, saved in the `riscv-steel/ip/` folder.

### Input/output signals

**Table 2** - RISC-V Steel Core input and output signals

| **Global signals**{ class="rvsteel-core-io-table" }  |  |  |  |
| -------------- | --------- | | -------------------- |
| **Signal name** | **Direction** | **Size** | **Description** |
| clock      | Input | 1 bit     | Clock input.         |
| reset      | Input | 1bit     | Reset (active-high). |
| **Memory interface**{ class="rvsteel-core-io-table" } | 
| **Signal name** | **Direction** | **Size** | **Description** |
| mem_address | Output | 32 bits     | The address for the read/write operation.  |
| mem_read_data | Input | 32 bits     | The data read from memory.  |
| mem_read_request | Output | 1 bit     | This signal is set to logic `HIGH` when the processor requests to read from memory.  |
| mem_read_request_ack | Input | 1 bit | The response to the read request from the previous clock cycle.</br></br>Must be asserted to logic `HIGH` if and only if **mem_read_data** holds valid data. |
| mem_write_data | Output | 32 bits | The data to write in memory.  |
| mem_write_strobe | Output | 4 bits | A signal indicating which byte lanes of **mem_write_data** must be written.</br></br>For example, if this signal holds `4'b0001`, then only the least significant byte of **mem_write_data** must be written. |
| mem_write_request | Output | 1 bit | This signal is set to logic `HIGH` when the processor requests to write to memory.  |
| mem_write_request_ack | Input | 1 bit | The response to the write request from the previous clock cycle.</br></br>Must be asserted to logic `HIGH` if and only if writing **mem_write_data** to **mem_address** was successful. |
| **Interrupt handling**{ class="rvsteel-core-io-table" } | 
| **Signal name** | **Direction** | **Size** | **Description** |
| irq_external | Input | 1 bit  | Assert this signal to logic `HIGH` to request the processor an external interrupt request. |
| irq_external_ack | Output | 1 bit  | The response to the external interrupt request. This signal is driven to logic `HIGH` if and only if the external interrupt request is accepted. |
| irq_timer | Input | 1 bit  | Assert this signal to logic `HIGH` to request the processor a timer interrupt request. |
| irq_timer_ack | Output | 1 bit  | The response to the timer interrupt request. This signal is driven to logic `HIGH` if and only if the timer interrupt request is accepted. |
| irq_software | Input | 1 bit  | Assert this signal to logic `HIGH` to request the processor a software interrupt request. |
| irq_software_ack | Output | 1 bit  | The response to the software interrupt request. This signal is driven to logic `HIGH` if and only if the software interrupt request is accepted. |
| **Real time clock**{ class="rvsteel-core-io-table" } | 
| **Signal name** | **Direction** | **Size** | **Description** |
| real_time_clock | Input | 64 bits | The measured time from a real time clock. This value is copied to the `mtime` and `utime` CSR registers at every rising edge of the **clock** signal. |

### Configuration

The only configuration parameter of RISC-V Steel Core is the boot address (`BOOT_ADDRESS`). In case you leave this parameter blank the boot address is automatically set to `32'h00000000`.

## Instantiation template

An instantiation template for the top module of RISC-V Steel Core is provided below.

``` systemverilog
rvsteel_core #(

  // Address of the first instruction to be fetched and executed

  .BOOT_ADDRESS                   ()  // if left blank the boot address
                                      // is set to 32'h00000000
) rvsteel_core_instance (

  // Global clock and active-high reset

  .clock                          (),
  .reset                          (), // reset is active-high

  // Memory Interface

  .mem_address                    (),
  .mem_read_data                  (),
  .mem_read_request               (),
  .mem_read_request_ack           (),
  .mem_write_data                 (),
  .mem_write_strobe               (),
  .mem_write_request              (),
  .mem_write_request_ack          (),

  // Interrupt signals

  .irq_external                   (), // hardwire to 1'b0 if unused
  .irq_external_ack               (), // leave blank if unused
  .irq_timer                      (), // hardwire to 1'b0 if unused
  .irq_timer_ack                  (), // leave blank if unused
  .irq_software                   (), // hardwire to 1'b0 if unused
  .irq_software_ack               (), // leave blank if unused

  // Real Time Clock

  .real_time_clock                ()  // hardwire to 64'b0 if unused

);
```

## Memory operations

This section explains the handshaking process of memory read and write operations requested by RISC-V Steel Core.

???+ info

    The core never requests to read and write in the same clock cycle. The core is either reading from memory or writing to it.

### Read operation

The memory interface signals are driven as follows during a read operation:

- the address is placed in the **mem_address** bus.

- the **mem_read_request** signal is driven to logic `HIGH`.

- **mem_address** and **mem_read_request** hold their values until **mem_read_request_ack** is driven to `HIGH`.

The processor core expects to receive the response in the following clock cycles. A response must never be given in the same clock cycle that **mem_read_request** was driven `HIGH`.

The figure below shows a timing diagram exemplifying the read operation handshaking:

<figure markdown>
  ![](images/read-timing.svg)
  <figcaption><strong>Figure 1</strong> - Read operation timing diagram</figcaption>
</figure>

### Write operation

The memory interface signals are driven as follows during a write operation:

- the address is placed in the **mem_address** bus.

- the **mem_write_request** signal is driven to logic `HIGH`.

- the data to be written is placed in the **mem_write_data** bus.

- the **mem_write_strobe** signal will indicate which byte lanes of **mem_write_data** must be written.

    For example, if this signal holds `4'b0001`, then only the least significant byte must be written. The upper 24 bits of **mem_write_data** must be ignored.

- all signals above hold their values until **mem_write_request_ack** is driven to `HIGH`.

The processor core expects to receive the response in the following clock cycles. A response must never be given in the same clock cycle that **mem_write_request** was driven `HIGH`.

The figure below shows a timing diagram exemplifying the write operation handshaking:

<figure markdown>
  ![](images/write-timing.svg)
  <figcaption><strong>Figure 1</strong> - Write operation timing diagram</figcaption>
</figure>

## Interrupt requests

There are three interrupt types in the RISC-V architecture: external, timer and software. RISC-V Steel Core provides a dedicated signal to request each of these interrupt types. An interrupt request is only accepted (causes a trap to be taken) if:

- the global interrupt enable bit is set (field `mie` in the `mstatus` CSR), and

- the corresponding interrupt type is enabled (fields `meie`, `mtie` and `msie` in the `mie` CSR).

The core proceeds as follows when an interrupt request is accepted:

- the execution of the current instruction is aborted.

- the memory address of the aborted instruction is saved in the `mepc` CSR.

- the program counter is set to the value of the `mtvec` CSR.

- the `mcause` CSR is set to a value encoding the type of the interrupt.

- the global interrupt enable bit `mstatus.mie` is set to logic `LOW`, disabling new interrupts.

- the prior interrupt enable bit `mstatus.mpie` is set to logic `HIGH`.

- the corresponding ack signal (**`irq_*_ack`**) is set to logic `HIGH` for one clock cycle.

The `mtvec` CSR is usually set to the address of an interrupt handler routine, so the core branches from normal execution and starts the execution of the interrupt handler.

To `mret` instruction is usually used to return from the interrupt handler. When this instruction is executed the core proceeds as follows:

- the program counter is set to the value of the `mepc` CSR.

- the global interrupt enable bit `mstatus.mie` receives the value saved in the `mstatus.mpie` bit.

- the prior interrupt enable bit `mstatus.mpie` is set to logic `LOW`. 

The value in the `mepc` register is the address of the instruction aborted by the interrupt, so normal execution is resumed.

## Real time clock

RISC-V Steel Core provides a 64-bit bus to update the `mtime` CSR with the value measured from a real time clock. The value of `mtime` is update on every rising edge of the **clock** signal and can be read with the `csrr` instruction.

???+ info

    Although the cycle counter register `mcycle` can be used to measure time lapses, it cannot provide wall clock time. And it can only realiably measure time lapses if the **clock** signal is connected to a stable oscillating signal, which is not always the case.

</br>
</br>
</br>
</br>
</br>