# RISC-V Steel System-on-Chip IP

## Introduction

RISC-V Steel SoC IP is a configurable system-on-chip design featuring RISC-V Steel 32-bit Processor Core, a programmable memory and an UART module. It comes with an API for software development that makes it easier for hardware engineers to develop and deploy new RISC-V embedded applications.

## Design overview

The figure below depicts the on-chip devices of RISC-V Steel SoC IP and how they interconnect. An overview of each device is provided in the [On-chip devices](#on-chip-devices) section.

<figure markdown>
  ![Image title](images/rvsteel-soc.drawio.svg)
  <figcaption>RISC-V Steel SoC design overview</figcaption>
</figure>

## Source files

The table below lists the source files of RISC-V Steel SoC modules. They are all written in Verilog and saved in the **`riscv-steel/hardware/`** folder.

???+ info

    The top module depends on all source files so you need to import them all into your project.

**Table 1.** RISC-V Steel SoC modules and source files

| Module name                  | File name                  | Description                         |
| ---------------------------- | -------------------------- | ----------------------------------- |
| **`rvsteel_soc`**            | `rvsteel-soc.v`            | RISC-V Steel SoC Top Module         |
| **`rvsteel_core`**           | `rvsteel-core.v`           | RISC-V Steel 32-bit Processor Core  |
| **`ram`**                    | `ram.v`                    | Programmable RAM Memory             |
| **`uart`**                   | `uart.v`                   | UART Receiver / Transmitter         |
| **`bus_mux`**                | `bus-mux.v`                | Bus Multiplexer                     |

## Instantiation

An instantiation template for RISC-V Steel SoC top module is provided below.

``` systemverilog
rvsteel_soc #(

  // Configuration parameters. For more information read the 'Configuration'
  // section of RISC-V Steel SoC Reference Guide

  .BOOT_ADDRESS             (),  // Default value: 32'h00000000
  .CLOCK_FREQUENCY          (),  // Default value: 50000000
  .UART_BAUD_RATE           (),  // Default value: 9600
  .MEMORY_SIZE              (),  // Default value: 8192
  .MEMORY_INIT_FILE         ())  // Default value: Empty string (uninitialized)

rvsteel_soc_instance (

  // I/O signals. For more information read the 'I/O signals'
  // section of RISC-V Steel SoC Reference Guide

  .clock                    (),  // Connect this pin to a clock source
  .reset                    (),  // Active-high reset. Connect to a reset switch
  .uart_rx                  (),  // Connect to the TX pin of other UART
  .uart_tx                  ()); // Connect to the RX pin of other UART
```

## Configuration

The table below presents RISC-V Steel SoC configuration parameters, their default values and the allowed value type for each parameter.

???+ info

    If you leave a parameter blank it will be set to its default value.

**Table 2.** RISC-V Steel SoC configuration parameters

| Parameter name   | Default value  | Value type / description                                                             |
| ---------------- | -------------- | ------------------------------------------------------------------------------------ |
| BOOT_ADDRESS     | 32'h00000000   | 32-bit value. Memory address of the first instruction to be fetched and executed.    |
| CLOCK_FREQUENCY  | 50000000       | Integer value. Frequency (in Hertz) of the **clock** input signal.                   |
| UART_BAUD_RATE   | 9600           | Integer value. The desired baud rate (in bauds per second) for the UART.             |
| MEMORY_SIZE      | 8192           | Integer value. The desired size (in bytes) for the programmmable memory.             |
| MEMORY_INIT_FILE | (empty string) | String value. Path to a memory initialization file containing your program and data. |

## I/O signals

RISC-V Steel SoC top module has 4 input/output signals, described below.

| Pin name       | Direction | Size  | Description          |
| -------------- | --------- | ----- | -------------------- |
| **`clock`**    | Input     | 1 bit | Clock input. Connect it to a clock source and inform its frequency via CLOCK_FREQUENCY parameter. |
| **`reset`**    | Input     | 1 bit | Reset (active-high). Connect it to a switch, button, or tie it to logic HIGH. |
| **`uart_rx`**  | Input     | 1 bit | UART receiver pin. It must be connected to the transmitter (TX) pin of the UART device. |
| **`uart_tx`**  | Output    | 1 bit | UART transmitter pin. It must be connected to the receiver (RX) pin of the UART device. |

## Memory Map

In the RISC-V architecture all peripheral devices communicate with the processor via memory-mapped I/O. The processor address space is shared between main memory and peripherals, and each device is mapped to part of the address space. This is achieved by multiplexing the memory signals according to the address the processor tries to access.

In RISC-V Steel SoC the processor address space is shared between the programmable memory and the UART. The memory range that each device is mapped to is shown in Table 3.

???+ info
    Reading data from a region not mapped to any device will return 0, and writing data to these regions will have no effect.

**Table 3.**{#table-3} RISC-V Steel SoC Memory Map

| Start address     | Final address       | Mapped device              |
| ----------------- | ------------------- | -------------------------- |
| `0x00000000`      | `0x(MEMORY_SIZE-1)` | Programmable memory        |
| `0x(MEMORY_SIZE)` | `0x7fffffff`        | No device                  |
| `0x80000000`      | `0x80000004`        | UART module                |
| `0x80000005`      | `0xffffffff`        | No device                  |

## On-chip devices

This section provides further information about RISC-V Steel SoC on-chip devices.

### 32-bit Processor Core

RISC-V Steel 32-bit Processor Core is the processing unit of RISC-V Steel SoC. The processor implements the RV32I instruction set, the Zicsr extension and the Machine-mode privileged architecture of RISC-V.

The design of the processor core is quite large so it has its own [Reference Guide](core-reference.md). Check it out for more information.

### Programmable memory

RISC-V Steel has an on-chip programmable random access memory tightly coupled to the processor core. The size of the memory is 8 KB by default but it can be adjusted by changing the value of the `MEMORY_SIZE` parameter. 

To initialize the memory contents on power-up you need to provide a memory initialization file via `MEMORY_INIT_FILE` parameter. You find the instructions on how to generate this file in the [Software Guide](#software-guide) section.

### UART

RISC-V Steel SoC has an on-chip UART module with adjustable baud rate, and Steel API provides function calls to send and receive data over the UART.

The table below provides the configuration parameters for the UART.

**Table 2.** RISC-V Steel SoC UART module configuration

| Configuration   | Value                                    |
| --------------- | ---------------------------------------- |
| Baud rate       | Adjustable (see the [Configuration](#configuration) section). The default value is 9600. |
| Data bits       | 8 bits |
| Stop bits       | 1 bit |
| Parity bits     | None |
| Flow control    | None |

### Bus multiplexer

The bus multiplexer interconnects all components of RISC-V Steel SoC, multiplexing memory signals according to the address the processor tries to access. On one side, it is connected to the processor's memory interface, and on the other side, it is connected to subordinate devices (the UART and programmable memory). The processor acts as a manager, requesting access to subordinate devices one at a time.

The [Memory Map](#memory-map) section above lists the address range assigned to each subordinate device. The memory signals are multiplexed by the bus multiplexer module according to [Table 3](#table-3).

</br>
</br>
</br>
</br>
</br>