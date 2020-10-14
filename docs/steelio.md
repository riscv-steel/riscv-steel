# I/O signals

Steel has 4 communication interfaces, shown in the figure below:

![Steel IO](images/steel-interface.png)

The core was designed to be connected to a memory with one clock cycle read/write latency, which means that the memory should take one clock cycle to complete both read and write operations.

The interrupt request interface has signals to request for external, timer and software interrupts, respectively. They can be connected to a single device or to an interrupt controller managing interrupt requests from several devices. If your system does not need interrupts you should hardwire these signals to zero.

The real-time counter interface provides a 64-bit bus to read the value from a real-time counter and update the time register. If your system does not need hardware timers, you should hardwire this signal to zero.

To learn about the core's communication with the devices mentioned above, read the section [Timing diagrams](timing.md).

## Interrupt controller interface

The interrupt controller interface has three signals used to request external, timer and software interrupts, shown in the table below. The interrupt request process is explained in the sections [Exceptions and interrupts](traps.md) and [Timing diagrams](timing.md#interrupt-request).

| **Signal**         | **Width**  | **Direction**  | **Description**                                                                                                                                                                        |
| :----------------- | :--------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *E_IRQ*           | 1 bit      | Input          | When set high indicates an external interrupt request.                                                                                                                                     |
| *T_IRQ*           | 1 bit      | Input          | When set high indicates a timer interrupt request.                                                                                                                                         |
| *S_IRQ*           | 1 bit      | Input          | When set high indicates a software interrupt request.                                                                                                                                      |

## Instruction fetch interface

The instruction fetch interface has two signals used in the instruction fetch process, shown in the table below. The process of fetching instructions is explained in the section [Timing diagrams](timing.md#instruction-fetch).

| **Signal**        | **Width**  | **Direction**  | **Description**                                                                                                                                                                        |
| :---------------- | :--------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *INSTR*           | 32 bits    | Input          | Contains the instruction fetched from memory.                                                                                                                                          |
| *I_ADDR*         | 32 bits    | Output         | Contains the address of the instruction the core wants to fetch from memory.                                                                                                           |

## Data read/write interface

The data read/write interface has five signals used in the process of reading/writing data from/to memory. The signals are shown in the table below. The processes of fetching and writing data to memory are explained in the section [Timing diagrams](timing.md#data-writing).

| **Signal**        | **Width**  | **Direction**  | **Description**                                                                                                                                                                                                                                                                               |
| :---------------- | :--------- | :------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *DATA_IN*        | 32 bits    | Input          | Contains the data fetched from memory.                                                                                                                                                                                                                                                        |
| *D_ADDR*         | 32 bits    | Output         | In a write operation, contains the address of the memory position where the data will be stored. In a read operation, contains the address of the memory position where the data to be fetched is. The address is always aligned on a four byte boundary (the last two bits are always zero). |
| *DATA_OUT*       | 32 bits    | Output         | Contains the data to be stored in memory. Used only with write operations.                                                                                                                                                                                                                    |
| *WR_REQ*         | 1 bit      | Output         | When high, indicates a request to write data. Used only with write operations.                                                                                                                                                                                                                |
| *WR_MASK*        | 4 bits     | Output         | Contains a mask of four *byte-write enable* bits. A bit high indicates that the corresponding byte must be written. Used only with write operations.                                                                                                               |

## Real-time counter interface

The real time counter interface has just one signal used to update the **time** CSR, shown in the table below. The process of updating the **time** register is explained in the section [Timing diagrams](timing.md#time-csr-update).

| **Signal**  | **Width**  | **Direction**  | **Description**                                                                                                                                                                        |
| :---------- | :--------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *REAL_TIME*  | 64 bits    | Input          | Contains the current value read from a real time counter.                                                                                                                              |

## CLK and RESET signals

The core has **CLK** and **RESET** input signals, which were not shown in the figure presented above. The **CLK** signal must be connected to a clock source. The **RESET** signal is active high and resets the core synchronously.
