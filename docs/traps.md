# Exceptions and interrupts

## Supported exceptions and interrupts

Steel supports the exceptions and interrupts shown in the table below. They are listed in descending priority order (the highest priority is at the top of the table). If two or more exceptions/interrupts occur at the same time, the one with the highest priority is taken.

Exceptions always cause a trap to be taken. An interrupt will cause a trap only if enabled. Each type of interrupt has an interrupt-enable bit in the **mie** register. Interrupts are globally enable/disabled by setting the MIE bit of **mstatus** register.

|  **Exception / Interrupt**               | ***mcause*** **interrupt bit**     | ***mcause*** **exception code**  |
| :--------------------------------------- | ----------------: | ------------------: |
| Machine external interrupt               | 1                 | 11                  |
| Machine software interrupt               | 1                 | 3                   |
| Machine timer interrupt                  | 1                 | 7                   |
| Illegal instruction exception            | 0                 | 2                   |
| Instruction address-misaligned exception | 0                 | 0                   |
| Environment call from M-mode exception   | 0                 | 11                  |
| Environment break exception              | 0                 | 3                   |
| Store address-misaligned exception       | 0                 | 6                   |
| Load address-misaligned exception        | 0                 | 4                   |

## Trap handling in Steel

Exceptions and interrupts are handled by a trap handler routine stored in memory. The address of the trap handler first instruction is configured using the **mtvec** register. Steel supports both direct and vectorized interrupt modes.

When a trap is taken, the core proceeds as follows:

* the address of the interrupted instruction (or the instruction that encountered the exception) is saved in the **mepc** register;
* the value of the **mtval** register is set to:
    * the misaligned address that caused the exception for all types of address-misaligned exceptions, or
    * zero otherwise;
* the value of the **mstatus** MIE bit is saved in the MPIE field and then set to zero;
* the program counter is set to the address of the trap handler first instruction.

The **mret** instruction is used to return from traps. When executed, the core proceeds as follows:

* the value of the **mstatus** MPIE bit is saved in the MIE field and then set to one;
* the program counter is set to the value of **mepc** register.

## Nested interrupts capability

The core globally disables new interrupts when takes into a trap. The trap handler can re-enable interrupts by setting the **mstatus** MIE bit to one, thus enabling nested interrupts. To return from nested traps, the trap handler must stack and manage the values of the **mepc** register in memory.
