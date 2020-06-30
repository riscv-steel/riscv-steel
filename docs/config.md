# Configuration

Steel configuration parameters can be modified by editing the `globals.vh` file (located inside the `rtl` directory). The following subsections describe the parameters that can be changed.

## Boot address

The `BOOT_ADDRESS` parameter sets the memory position of the first instruction the core will fetch after reset. It can be changed to any 32-bit value.

## CSRs reset values

The reset value of several control and status registers (CSRs) can be modified. The table below shows these CSRs and the accepted values.
 
| **Parameter name**     | **Description**                                                                                                                                                                     |
| :--------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *MCYCLE_RESET*           | Value of the `mcycle`  CSR after reset. It can be changed to any 32-bit value.                                                                                                   |
| *MCYCLEH_RESET*          | Value of the `mcycleh` CSR after reset. It can be changed to any 32-bit value.                                                                                                   |
| *TIME_RESET*             | Value of the `time` CSR after reset. It can be changed to any 32-bit value.                                                                                                      |
| *TIMEH_RESET*            | Value of the `timeh` CSR after reset. It can be changed to any 32-bit value.                                                                                                     |
| *MINSTRET_RESET*         | Value of the `minstret` CSR after reset. It can be changed to any 32-bit value.                                                                                                  |
| *MINSTRETH_RESET*        | Value of the `minstreth` CSR after reset. It can be changed to any 32-bit value.                                                                                                 |
| *MTVEC_BASE_RESET*       | Value of the `base` field of `mtvec` CSR after reset. The value is used in the trap handler address calculation. It can be changed to any 30-bit value.             |
| *MTVEC_MODE_RESET*       | Value of the `mode` field of `mtvec` CSR after reset. It defines the interrupt mode and can be changed to the value 00 (direct mode) or 01 (vectored mode).         |
| *MSCRATCH_RESET*         | Value of the `mscratch` CSR after reset. It can be changed to any 32-bit value.                                                                                                  |
| *MEPC_RESET*             | Value of the `mepc` CSR after reset. It can be changed to any 32-bit address aligned on a four byte boundary (the last two bits must be set to zero).                            |
| *MCOUNTINHIBIT_CY_RESET* | Enables or inhibits cycle counting (1 inhibits, 0 enables).                                                                                                                         |
| *MCOUNTINHIBIT_IR_RESET* | Enables or inhibits instructions retired counting (1 inhibits, 0 enables).                                                                                                          |
