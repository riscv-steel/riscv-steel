<p align="center"><img src="docs/source/images/rvx_logo.png" width="100"/></p><p align="center"><strong>RISC-V Microcontroller IP</strong></p>

### What Is RVX?

**RVX** is a RISC-V microcontroller written in Verilog for embedded, FPGA, and ASIC applications. It combines a configurable IP core with firmware and development tools to help engineers develop solutions for real-time control, sensor monitoring, data acquisition, and industrial automation.

Designed for flexibility and ease of integration, RVX is packed with a comprehensive set of architectural features and development resources to accelerate your hardware and software workflow.

### Features

- **RISC-V ISA** — Implements the RV32I integer instruction set and the Zicsr and Zmmul extensions.
- **SDK** — The [RVX Software Development Kit][1] provides a complete embedded development stack for RVX, including peripheral drivers, startup code, linker scripts, and build integration.
- **FreeRTOS** — RVX can run FreeRTOS, enabling multitasking and real-time applications.
- **Integrated Peripherals** — RVX includes I2C, SPI, GPIO, UART, and timer controllers for device communication, digital I/O, and timing.
- **Documentation** — Includes [Developer Guide][2], [IP Reference][3], and several [Example Projects][4].

### Architecture

<p align="center"><img src="docs/source/images/rvx_architecture.png" width="75%"/></p>

### Getting Started

The fastest way to evaluate RVX is to build and run one of the example projects for your FPGA board.

If you are new to RVX, we recommend starting with the [Hello World][5] example. It demonstrates how to build and run a simple "Hello, World!" program for RVX, introducing the [RVX SDK][1] and development workflow.

Each example contains:

- Step-by-step build and run instructions
- Complete RTL and software source code
- Pre-built FPGA bitstreams for featured boards

### Examples

- [Hello World][5] - Introduces the RVX toolchain and development workflow with a simple "Hello, World!" program.
- [FreeRTOS][6] - Runs FreeRTOS on RVX, showcasing multitasking and real-time capabilities.

### Documentation

The documentation for RVX includes:

- [Developer Guide][2] — Guide for developing applications with RVX.
- [IP Reference][3] — Information on the RVX design, including architectural overview, optional features, I/O interfaces, and memory map.
- [Example Projects][4] — Complete source code and instructions for building and running the example applications.

### License

RVX is free and open source, distributed under the [MIT License][7].

[1]: https://github.com/rafaelcalcada/rvx-sdk
[2]: https://rafaelcalcada.github.io/rvx/developer-guide
[3]: https://rafaelcalcada.github.io/rvx/ip-reference
[4]: https://rafaelcalcada.github.io/rvx/examples
[5]: https://rafaelcalcada.github.io/rvx/examples/helloworld
[6]: https://rafaelcalcada.github.io/rvx/examples/freertos
[7]: LICENSE

<p align="center"></br><a href="https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml"><img src="https://github.com/rafaelcalcada/rvx/actions/workflows/tests.yml/badge.svg"></a></p>
