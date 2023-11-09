This Reference Guide contains detailed information about RISC-V Steel IP cores.

### RISC-V Steel SoC

The image below depicts the main components of RISC-V Steel SoC and their interconnections.

![Image title](images/rvsteel-soc.drawio.svg)

#### Files

#### Instantiation

An instantiation template for the top module is provided below. The values for the parameters are the same used for the Hello World demo and were left as an example.

``` systemverilog
rvsteel_soc                 #(

  .BOOT_ADDRESS             (32'h00000000         )
  .CLOCK_FREQUENCY          (50000000             ),
  .UART_BAUD_RATE           (9600                 ),
  .MEMORY_SIZE              (8192                 ),
  .MEMORY_INIT_FILE         ("hello-world.mem"    )

) rvsteel_soc_instance      (

  .clock                    (board_clock          ),
  .reset                    (board_reset          ),
  .uart_rx                  (board_uart_tx        ),
  .uart_tx                  (board_uart_rx        )

);
```

#### Tightly Coupled Memory

RISC-V Steel has a programmable RAM memory tighly coupled to the processor core. The size of this memory can be adjusted to suit your FPGA capacity. The more powerful your FPGA, the more memory you can get. By default, the size of the memory is set to the small amount of 8KB.

#### UART

RISC-V Steel has a UART module with adjustable baud rate, and Steel API provides an interface to easily send and receive data over UART protocol. The configuration parameters for the UART are shown below.

**Table 2.** UART module configuration

| Configuration   | Value                                    |
| --------------- | ---------------------------------------- |
| Baud rate       | Adjustable (see [Configuration parameters](#configuration-parameters)). Default value is 9600. |
| Data bits       | 8 |
| Stop bits       | 1 |
| Parity bits     | 0 |
| Flow control    | None |

#### Bus Crossbar

The AXI4 Crossbar is the medium that interconnects all components in the system. The RISC-V processor acts as an AXI manager. The UART and the RAM memory, in turn, act as subordinates, peripheral devices.

The memory address space is shared between memory and other peripherals in the RISC-V architecture. Each component is assigned a range of the available address space. In RISC-V Steel the AXI crossbar maps the subordinate components to the following memory addresses:

**Table 3.** RISC-V Steel memory map

| Start address   | Final address | Device |
| --------------- | ------------- | ------ |
| 0x00000000      | 0x(MEMORY_SIZE-1) | RAM memory |
| 0x10000000      | 0x10000004    | UART module |

#### I/O signals

The top module has 4 interface signals in total, described in detail below.

| Pin name    | Direction | Size  | Description          |
| ----------- | --------- | ----- | -------------------- |
| clock       | Input     | 1 bit | Clock input.         |
| reset       | Input     | 1 bit | Reset (active-high). |
| uart_rx     | Input     | 1 bit | UART receiver.       |
| uart_tx     | Output    | 1 bit | UART transmitter.    |

#### Configuration parameters

The table below describes the available configuration parameters. The value for a parameter is set to default if ommited or not set during instantiation.

| Parameter name     | Default value  | Unit  | Description                                                                                                         |
| ----------------   | ---------------| ------| ------------------------------------------------------------------------------------------------------------------- |
| `BOOT_ADDRESS`     | `32'h00000000` | -     | Memory address of the first instruction to be fetched and executed.                                                 |
| `CLOCK_FREQUENCY`  | `50000000`     | Hz    | Frequency (in Hertz) of the **clock** input signal.                                                                 |
| `UART_BAUD_RATE`   | `9600`         | Bps   | The desired baud rate (in bauds per second) for the UART.                                                           |
| `MEMORY_SIZE`      | `8192`         | Bytes | The desired size (in bytes) for the tightly coupled memory. Value must be a multiple of                             |
| `MEMORY_INIT_FILE` | `""`           | -     | A string with the path to a memory initialization file. By default the memory is left uninitialized (empty string). |

### RISC-V 32-bit Processor

#### Overview

RISC-V Steel 32-bit processor core implements the RV32I instruction set, the Zicsr extension and the Machine-mode privileged architecture of the RISC-V specifications. It communicates with other devices through an AXI4-Lite Manager interface.

The set of features present in the processor core makes it perfect for embedded and system-on-a-chip (SoC) designs. The core is capable of running both real-time operating systems and bare-metal embedded software. Also, it can easily interconnect with a myriad of pre-existing devices compatible with the AXI architecture.

**Table 1.** RISC-V Processor features summary

| Feature                              | Notes                                                                                |
| ------------------------------------ | ------------------------------------------------------------------------------------ |
| RV32I Integer ISA                    | Version 2.1. [Link to specifications](https://riscv.org/technical/specifications/).  |
| Zicsr Extension                      | Version 2.0. [Link to specifications](https://riscv.org/technical/specifications/).  |
| Machine-mode privileged architecture | Version 1.12. [Link to specifications](https://riscv.org/technical/specifications/). |
| AXI4-Lite Manager interface          | [Link to specifications](https://developer.arm.com/documentation/ihi0022/latest/).   |

#### Files

#### I/O signals

#### Configuration parameters

#### AXI4 Manager interface

#### Interrupt handling

#### Real-time clock

</br>
</br>
</br>
</br>
</br>