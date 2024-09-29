# GPIO

## Initialization

1. Write port direction in register `OE`.
2. Read from register `IN` or write to register `OUT`.
3. Write `1<<PIN` to register `CLR` if you want to clear the port output to 0.
4. Write `1<<PIN` to register `SET` if you want to set the port output to 1.

![RISC-V Steel GPIO Diagram](../images/rvsteel_gpio_blockdiagram.svg)

## Register Access

Registers are accessed via 32-bit access operations. Attempts to access an misaligned address will be ignored.

## Registers

| Name                       | Offset | Bits  | Description            |
|:---------------------------|:-------|------ |:-----------------------|
| `IN`                       | 0x0    |   32  | GPIO Input data        |
| `OE`                       | 0x4    |   32  | GPIO Output Enable     |
| `OUT`                      | 0x8    |   32  | GPIO Output data       |
| `CLR`                      | 0xC    |   32  | GPIO Clear mask        |
| `SET`                      | 0x10   |   32  | GPIO Set mask          |
