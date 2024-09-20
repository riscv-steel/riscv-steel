# RISC-V Steel Processor Core IP

## Introduction

RISC-V Steel Processor Core IP is a 32-bit processor core implementing the RV32I instruction set, the Zicsr extension and the Machine-Mode privileged architecture of RISC-V.

The Processor Core IP is a single-issue, in-order, unpipelined processor core.

The Processor Core IP can run real-time operating systems and bare-metal embedded software. It is designed to work as a processing unit in a wide variety of embedded applications.

## Source files

The Processor Core IP has a single source file, `rvsteel_core.v`, saved in `hardware/core/`.

## I/O signals

| **Global signals**{ class="rvsteel-core-io-table" }  |  |  |  |
| -------------- | --------- | | -------------------- |
| **Signal name** | **Direction** | **Size** | **Description** |
| clock      | Input | 1 bit     | Clock input.         |
| reset      | Input | 1 bit     | Reset signal (active-high). |
| halt       | Input | 1 bit     | Halt signal (active-high). |
| **I/O interface**{ class="rvsteel-core-io-table" } |
| **Signal name** | **Direction** | **Size** | **Description** |
| rw_address | Output | 32 bits     | Address of the read/write operation.  |
| read_data | Input | 32 bits     | Data read.  |
| read_request | Output | 1 bit     | Read request.  |
| read_response | Input | 1 bit | Response to the read request. |
| write_data | Output | 32 bits | Data to be written.  |
| write_strobe | Output | 4 bits | A signal indicating which byte lanes of **write_data** holds the data to be written. |
| write_request | Output | 1 bit | Write request.  |
| write_response | Input | 1 bit | Response to the write request. |
| **Interrupt handling**{ class="rvsteel-core-io-table" } |
| **Signal name** | **Direction** | **Size** | **Description** |
| irq_fast | Input | 16 bit  | 16 fast interrupt request lines for peripheral devices. Priority increases in ascending order (line 0 has the highest priority, line 15 the lowest). |
| irq_fast_response | Output | 16 bit  | 16 response lines for interrupt requests. |
| irq_external | Input | 1 bit  | External interrupt request. |
| irq_external_response | Output | 1 bit  | Response to the external interrupt request. |
| irq_timer | Input | 1 bit  | Timer interrupt request. |
| irq_timer_response | Output | 1 bit  | Response to the timer interrupt request. |
| irq_software | Input | 1 bit  | Software interrupt request. |
| irq_software_response | Output | 1 bit  | Response to the software interrupt request. |
| **Real time clock**{ class="rvsteel-core-io-table" } |
| **Signal name** | **Direction** | **Size** | **Description** |
| real_time_clock | Input | 64 bits | Real time clock, used to update the `mtime` CSR. |

## Configuration

The only configuration parameter is the boot address (`BOOT_ADDRESS`). If you leave this parameter blank the boot address is automatically set to `32'h00000000`.

## Instantiation template

An instantiation template for the Processor Core IP is provided below.

``` systemverilog
rvsteel_core #(

  // Address of the first instruction to be fetched and executed

  .BOOT_ADDRESS           ()  // defaults to 32'h00000000 if left blank

) rvsteel_core_instance (

  // Global signals

  .clock                  (),
  .reset                  (), // reset is active-high
  .halt                   (), // halt is active-high

  // IO interface

  .rw_address             (),
  .read_data              (),
  .read_request           (),
  .read_response          (),
  .write_data             (),
  .write_strobe           (),
  .write_request          (),
  .write_response         (),

  // Interrupt signals

  .irq_fast               (), // hardwire to 16'b0 if unused
  .irq_fast_response      (), // leave blank if unused
  .irq_external           (), // hardwire to 1'b0 if unused
  .irq_external_response  (), // leave blank if unused
  .irq_timer              (), // hardwire to 1'b0 if unused
  .irq_timer_response     (), // leave blank if unused
  .irq_software           (), // hardwire to 1'b0 if unused
  .irq_software_response  (), // leave blank if unused

  // Real Time Clock

  .real_time_clock        ()  // hardwire to 64'b0 if unused

);
```

## I/O operations

The Processor Core IP communicates with external devices (memory and peripherals) through its I/O interface signals. In each clock cycle the processor either requests to read or write data. It never requests both operations in the same clock cycle.

As in all RISC-V systems, the processor address space is shared among all devices, both memory and peripherals. Each device is mapped to a region in the address space. Communication with a device takes place by reading and writing data at addresses assigned exclusively to that device.

The two sections below explain how read and write operations are requested by the processor core and the expected response to these requests.

### Read operation

The processor core drives the I/O interface signals as follows on a read request:

- the address is placed in the **rw_address** bus.

- the **read_request** signal is driven to logic `HIGH`.

- the **rw_address** and **read_request** signals remain stable until **read_response** is driven to logic `HIGH` by the external device.

The response to the read request from the external device must observe these rules:

- The read data must be placed in the **read_data** bus.

- the **read_response** signal must be driven to logic `HIGH` only when **read_data** holds valid data, and it must be held `HIGH` for only one clock cycle.

- The read response must never be given in the same clock cycle that **read_request** was driven `HIGH`.

The timing diagram below contains examples of valid read operations:

<figure markdown>
  ![](../images/read_timing.svg)
  <figcaption><strong>Figure 1</strong> - Read operation timing diagram</figcaption>
</figure>

### Write operation

The processor core drives the I/O interface signals as follows on a write request:

- the address is placed in the **rw_address** bus.

- the **write_request** signal is driven to logic `HIGH`.

- the data to be written is placed in the **write_data** bus.

- the **write_strobe** signal will indicate which byte lanes of **write_data** must be written.

    For example, if this signal holds `4'b0001`, only the least significant byte must be written. The upper 24 bits of **write_data** must be ignored.

- all signals above remain stable until **write_response** is driven to logic `HIGH` by the external device.

The response to the write request from the external device must observe these rules:

- the **write_response** signal must be driven to logic `HIGH` only if the write operation succeeded, and it must be held `HIGH` for only one clock cycle.

- The write response must never be given in the same clock cycle that **write_request** was driven `HIGH`.

The timing diagram below contains examples of valid write operations:

<figure markdown>
  ![](../images/write_timing.svg)
  <figcaption><strong>Figure 2</strong> - Write operation timing diagram</figcaption>
</figure>

## Exceptions, interrupts and traps

### Overview

In the RISC-V architeture, a trap refers to the transfer of control caused by either an exception or interrupt. A trap is said to be _taken_ when an exception or interrupt change the program normal execution order by writing to the program counter the start address of a trap handler software routine, as configured in the **mtvec** CSR.

An exception always causes a trap to be taken. An interrupt causes a trap to be taken only if:

- the global interrupt enable bit is set (field **mie** in the **mstatus** CSR), and

- the corresponding interrupt type is enabled (fields **meie**, **mtie** and **msie** in the **mie** CSR).

The implemented exceptions and interrupts are listed in the table below. They are listed in descending priority order, that is, the topmost has the highest priority.

| Priority       | Type      | `mstatus[31]` | `mstatus[30:0]` | Description |
| -------------- | --------- | ------------------- | ---------------------| ----------- |
| highest        | Exception | 0 | 2 | Illegal instruction |
|                | Exception | 0 | 0 | Misaligned instruction address |
|                | Exception | 0 | 11 | Environment call from M-mode |
|                | Exception | 0 | 3 | Breakpoint call from M-mode |
|                | Exception | 0 | 6 | Misaligned store address |
|                | Exception | 0 | 4 | Misaligned load address |
|                | Interrupt | 1 | 16 | Fast interrupt #0 |
|                | Interrupt | 1 | 17 | Fast interrupt #1 |
|                | Interrupt | ... | ... | ... |
|                | Interrupt | 1 | 32 | Fast interrupt #15 |
|                | Interrupt | 1 | 11 | External interrupt |
|                | Interrupt | 1 | 3 | Software interrupt |
| lowest         | Interrupt | 1 | 7 | Timer interrupt |

### Fast Interrupts

The Processor Core IP provides 16 fast interrupt request lines in addition to the standard RISC-V interrupts. These interrupt requests have higher priority over the standard interrupts, as shown in the table above.

### Interrupt request handshake

A device can request an interrupt by driving the corresponding **irq_\*** signal to logic `HIGH` and holding it `HIGH` until the request is accepted. The processor accepts the request by driving the **irq_\*_response** signal to logic `HIGH` for one clock cycle. The requesting device can drive the **irq_\*** signal to logic `LOW` in the clock cycle that follows the response, or keep it `HIGH` to make a new request.

The timing diagram below is an example of a valid interrupt request:

<figure markdown>
  ![](../images/irq.svg)
  <figcaption><strong>Figure 3</strong> - Interrupt request timing diagram</figcaption>
</figure>

### Trap handling

The Processor Core IP proceeds as follows when a trap is taken:

- the execution of the current instruction is aborted.

- the memory address of the aborted instruction is saved in the **mepc** CSR.

- the program counter is set to the value of the **mtvec** CSR.

- the **mcause** CSR is set to a value encoding the type of the interrupt.

- the current value of the global interrupt enable bit **mstatus.mie** is saved in **mstatus.mpie** (prior interrupt enable bit).

- **mstatus.mie** is set to logic `LOW`, disabling new interrupts in case they were enabled.

- if the trap was caused by an interrupt, the corresponding response signal (**irq_\*_response**) is set to logic `HIGH` for one clock cycle.

The **mtvec** CSR is set by software to the address of a trap handler routine, so the core branches from normal execution and starts the execution of the trap handler.

The **mret** instruction is used by software to return from the trap handler. When this instruction is executed the core proceeds as follows:

- the program counter is set to the value of the **mepc** CSR.

- the global interrupt enable bit **mstatus.mie** receives the value saved in the **mstatus.mpie** bit.

- the prior interrupt enable bit **mstatus.mpie** is set to logic `LOW`.

The value in the **mepc** register holds the address of the instruction aborted when the trap was taken, so normal execution is resumed.

## Real time clock

Systems that require a real time clock can connect the **time** CSR to an external clock device through the **real_time_clock** bus. By doing so, wall clock time can be obtained by reading the **time** CSR with the **csrrw** instruction.

Systems that do not need a real time clock can hardwire this signal to `64'b0`, which causes reading the **time** CSR to return zero. In this case time lapses can still be measured by reading the cycle counter **mcycle**, as long as the **clock** signal is connected to a stable oscillating signal.

</br>
</br>
</br>
</br>
</br>