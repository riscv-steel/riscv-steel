# RISC-V Steel System-on-Chip IP </br><small>Reference Guide</small>

## Introduction

RISC-V Steel SoC IP is a system-on-chip design with RISC-V Steel Processor Core, RAM memory and UART module. It comes with an [API for software development](software-guide.md#soc-ip-api-reference) that makes it easier for hardware engineers to develop and deploy RISC-V embedded applications.

In this Reference Guide you find information on the SoC IP hardware design. See the [Software Guide](software-guide.md) for instructions on how to write, compile and run software for the SoC IP.

## Design overview

**Figure 1**{#figure-1} - RISC-V Steel SoC IP design overview

![Image title](images/rvsteel-soc.svg)

## Source files

**Table 1** - RISC-V Steel SoC IP source files

| Module name      | File                 | Location                |  Description                    |
| ---------------- | -------------------- | ----------------------- |------------------------------ |
| **rvsteel_soc**  | `rvsteel-soc.v`      | `riscv-steel/ip/` | Top module of RISC-V Steel SoC IP |
| **rvsteel_core** | `rvsteel-core.v`     | `riscv-steel/ip/` | RISC-V Steel Processor Core              |
| **ram_memory**   | `ram-memory.v`       | `riscv-steel/ip/` | RAM memory                     |
| **uart**         | `uart.v`             | `riscv-steel/ip/` | UART                           |
| **system_bus**   | `system-bus.v`       | `riscv-steel/ip/` | System Bus                     |

## I/O signals

**Table 2** - RISC-V Steel SoC IP top module input and output signals

| Pin name       | Direction | Size  | Description          |
| -------------- | --------- | ----- | -------------------- |
| **clock**      | Input     | 1 bit | Clock input.         |
| **reset**      | Input     | 1 bit | Reset (active-high). |
| **uart_rx**    | Input     | 1 bit | UART receiver pin. Must be connected to the transmitter (`TX`) pin of another UART device. |
| **uart_tx**    | Output    | 1 bit | UART transmitter pin. Must be connected to the receiver (`RX`) pin of another UART device. |

## Memory Map

In RISC-V systems, all devices share the processor address space and are mapped to an exclusive region in it (*Memory Mapped I/O*). 

The memory region assigned to each device of RISC-V Steel SoC IP is listed in the table below.

**Table 4**{#table-4} - Memory Map of RISC-V Steel SoC IP

| Start address     | Final address       | Mapped device              |
| ----------------- | ------------------- | -------------------------- |
| `0x00000000`      | `0x(MEMORY_SIZE-1)` | RAM memory                 |
| `0x(MEMORY_SIZE)` | `0x7fffffff`        | -                          |
| `0x80000000`      | `0x80000004`        | UART                       |
| `0x80000005`      | `0xffffffff`        | -                          |

## Configuration

**Table 3** - Configuration parameters of RISC-V Steel SoC IP

| Parameter name         | Default value    | Value type and description                                                                    |
| ---------------------- | ---------------- | --------------------------------------------------------------------------------------------- |
| **`BOOT_ADDRESS`**     | `32'h00000000`   | 32-bit hexadecimal value. Memory address of the first instruction to be fetched and executed. |
| **`CLOCK_FREQUENCY`**  | `50000000`       | Integer. Frequency (in hertz) of the **clock** input signal.                                  |
| **`UART_BAUD_RATE`**   | `9600`           | Integer. UART baud rate (in bauds per second).                                                |
| **`MEMORY_SIZE`**      | `8192`           | Integer. RAM memory size (in bytes).                                             |
| **`MEMORY_INIT_FILE`** | `(empty string)` | String. Path to a memory initialization file.                                                 |

## Instantiation template

An instantiation template for RISC-V Steel SoC IP top module is provided below.

``` systemverilog
rvsteel_soc #(

  // Configuration parameters. For more information read the 'Configuration'
  // section of RISC-V Steel SoC IP Reference Guide

  .BOOT_ADDRESS             (),  // Default value: 32'h00000000
  .CLOCK_FREQUENCY          (),  // Default value: 50000000
  .UART_BAUD_RATE           (),  // Default value: 9600
  .MEMORY_SIZE              (),  // Default value: 8192
  .MEMORY_INIT_FILE         ())  // Default value: Empty string (uninitialized)

  rvsteel_soc_instance (

  // I/O signals. For more information read the 'I/O signals'
  // section of RISC-V Steel SoC IP Reference Guide

  .clock                    (),  // Connect this pin to a clock source
  .reset                    (),  // Connect this pin to a reset switch/button. The reset is active-high.
  .uart_rx                  (),  // Connect this to the TX pin of another UART device
  .uart_tx                  ()   // Connect this to the RX pin of another UART device

);
```

## Adding devices

A new device can be added to the SoC IP by modifying the system bus module (`system-bus.v`) and the top module (`rvsteel-soc.v`). All modifications that need to be made were left as comments in the source code of these files.

The parts that need to be uncommented follow the template:

``` systemverilog
  /* Uncomment to add new devices

  ... code for adding the new device ...

  */
```

The new device will be assigned the memory region you define in the `DEVICEx_START_ADDRESS` and `DEVICEx_FINAL_ADDRESS` parameters. You can assign the device to any free region in the address space (see [Memory Map](#memory-map)).

## Components

### RISC-V Steel Processor Core

RISC-V Steel Processor Core is the processing unit of RISC-V Steel SoC IP. Its design is quite large so it has its own [Reference Guide](core.md). Please check it out for more information.

### RAM memory

RISC-V Steel SoC IP has a RAM memory tightly coupled to the processor core, with read/write latency of a single clock cycle. The memory size can be changed by adjusting the `MEMORY_SIZE` parameter (see [Configuration](#configuration)). 

### UART

RISC-V Steel SoC IP has an UART module with configurable baud rate. The module works with 8 data bits, 1 stop bit, no parity bits and no flow control signals (most UARTs work the same way).

### System Bus

The system bus module interconnects RISC-V Steel Processor Core (manager device) to the UART and the RAM memory (subordinate devices) as shown in [Figure 1](#figure-1). The module multiplexes the signals from the processor's I/O interface to the appropriate subordinate device according to the address the processor requests.

</br>
</br>