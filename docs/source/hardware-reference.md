## Devices overview 

RISC-V Steel features de following hardware devices:

### 32-bit RISC-V processor

At the core of RISC-V Steel is a 32-bit RISC-V processor that implements the RV32I integer ISA, the Zicsr extension and the Machine-mode privileged architecture of the RISC-V specifications. The processor core is unpipelined and was written in Verilog. It implements an AXI4-Lite Manager interface for communication with other devices.

The set of features present in the processor core makes it perfect for embedded systems and systems-on-a-chip (SoCs). The core is capable of running both real-time operating systems and bare-metal embedded software. Also, it can easily interconnect with a myriad of pre-existing devices compatible with the AXI architecture.

**Table 1.** RISC-V Processor features summary

| Feature     | Notes                                    |
| ----------- | ---------------------------------------- |
| RV32I Integer ISA | Version 2.1. [Link to specifications](https://riscv.org/technical/specifications/). |
| Zicsr Extension   | Version 2.0. [Link to specifications](https://riscv.org/technical/specifications/). |
| Machine-mode privileged architecture | Version 1.12. [Link to specifications](https://riscv.org/technical/specifications/). |
| AXI4-Lite Manager interface | [Link to specifications](https://developer.arm.com/documentation/ihi0022/latest/). |

### Programmable memory

RISC-V Steel has a programmable RAM memory tighly coupled to the processor core. The size of this memory can be adjusted to suit your FPGA capacity. The more powerful your FPGA, the more memory you can get. By default, the size of the memory is set to the small amount of 8KB.

### UART interface

RISC-V Steel has a UART module with adjustable baud rate, and Steel API provides an interface to easily send and receive data over UART protocol. The configuration parameters for the UART are shown below.

**Table 2.** UART module configuration

| Configuration   | Value                                    |
| --------------- | ---------------------------------------- |
| Baud rate       | Adjustable (see [Configuration parameters](#configuration-parameters)). Default value is 9600. |
| Data bits       | 8 |
| Stop bits       | 1 |
| Parity bits     | 0 |
| Flow control    | None |

### AXI4 Crossbar

The AXI4 Crossbar is the medium that interconnects all components in the system. The RISC-V processor acts as an AXI manager. The UART and the RAM memory, in turn, act as subordinates, peripheral devices.

The memory address space is shared between memory and other peripherals in the RISC-V architecture. Each component is assigned a range of the available address space. In RISC-V Steel the AXI crossbar maps the subordinate components to the following memory addresses:

**Table 3.** RISC-V Steel memory map

| Start address   | Final address | Device |
| --------------- | ------------- | ------ |
| 0x00000000      | 0x(MEMORY_SIZE-1) | RAM memory |
| 0x10000000      | 0x10000004    | UART module |

## Top module

The top module of RISC-V Steel is located at `riscv-steel/hardware/rvsteel-soc.v`. It instantiates and interconnects all hardware devices in the system.

**Figure 1.** Top module design overview

![Image title](images/rvsteel-soc.drawio.svg)

## I/O signals

The top module has 4 interface signals in total, described in detail below.

| Pin name    | Direction | Size  | Description          |
| ----------- | --------- | ----- | -------------------- |
| clock       | Input     | 1 bit | Clock input.         |
| reset       | Input     | 1 bit | Reset (active-high). |
| uart_rx     | Input     | 1 bit | UART receiver.       |
| uart_tx     | Output    | 1 bit | UART transmitter.    |

## Configuration parameters

The table below describes the available configuration parameters. The value for a parameter is set to default if ommited or not set during instantiation.

| Parameter name | Expected value | Default value | Description |
| -------------- | -------------- | ------------- | ----------- |
| BOOT_ADDRESS | 32-bit hexadecimal value | 32'h00000000 | The memory address of the first instruction to be fetched and executed. |
| CLOCK_FREQUENCY | The clock frequency in Hz. | 50000000 | The frequency (in Hertz) of the clock signal. |
| UART_BAUD_RATE  | Baud rate in bauds per second. | 9600 | The desired baud rate (in bauds per second) for the UART module. |
| MEMORY_SIZE     | Memory size in bytes. | 8192 | The size (in bytes) for the RAM memory. The value must be a multiple of 32. |
| MEMORY_INIT_FILE | A string with the path to a memory initialization file | Empty string (does not initialize memory) | The memory initialization file may contain a program to be run, data or both. |
| FILL_UNUSED_MEMORY_WITH | 32-bit hexadecimal value | 32'hdeadbeef | A value to fill every unused memory position. For example, if your memory initialization file has 2K and your RAM has 8K, the unused 6K will be filled with the value set by this parameter. |

## Instantiation

An instantiation template for the top module is provided below. The values for the parameters are the same used for the Hello World demo and were left as an example.

``` systemverilog
rvsteel_soc                 #(

  .BOOT_ADDRESS             (32'h00000000         )
  .CLOCK_FREQUENCY          (50000000             ),
  .UART_BAUD_RATE           (9600                 ),
  .MEMORY_SIZE              (8192                 ),
  .MEMORY_INIT_FILE         ("hello-world.mem"    ),
  .FILL_UNUSED_MEMORY_WITH  (32'hdeadbeef         ),

) rvsteel_soc_instance      (

  .clock                    (board_clock          ),
  .reset                    (board_reset          ),
  .uart_rx                  (board_uart_tx        ),
  .uart_tx                  (board_uart_rx        )

);
```

</br>
</br>
</br>
</br>
</br>