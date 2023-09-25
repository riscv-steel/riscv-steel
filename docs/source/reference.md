# Introduction

**RISC-V Steel** is a free and open 32-bit microprocessor core written in **Verilog** (IEEE 1364-2005) that implements the following features of the [RISC-V Instruction Set Architecture specifications](https://riscv.org/technical/specifications/):

- RV32I base integer instruction set **v2.1**
- Zicsr extension **v2.0**
- Machine ISA **v1.12**

As its name suggests, RISC-V Steel is a **microprocessor core** - a hardware unit within a larger design that  fetches, decodes, and executes instructions. A microprocessor core alone is useless. You need to connect it to other devices (memory and I/O) to make it do work. You can build many different systems by varying the size and type of memory and the I/O devices in the system.

This *Reference Guide* contains all the information you need to build a RISC-V based system with RISC-V Steel:

- An introduction to RISC-V Steel microarchitecture
- A description of all interface signals so you can connect other devices to it
- Timing diagrams detailing how it communicates with other devices
- How it behaves on interrupts and exceptions (trap handling)