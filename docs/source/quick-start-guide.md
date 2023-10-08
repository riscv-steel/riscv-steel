## Introduction

**RISC-V Steel** is a free and open platform for embedded systems development based on the RISC-V instruction set architecture. It is intended for use as a soft-core on FPGA boards and kits and features a 32-bit RISC-V processor core, programmable memory, UART transceiver and an API for software development.

The easiest way to get started with RISC-V Steel is to implement its [Hello World](https://github.com/riscv-steel/riscv-steel/tree/main/hello-world) project on an FPGA development board and expand it to meet your project requirements. In this [Quick Start Guide](https://riscv-steel.github.io/riscv-steel/quick-start-guide/) we will show you the steps to implement this project on three FPGA boards: **Arty A7-35T**, **Arty A7-100T**, and **Cmod-A7**.

If you'd like to have this guide ported to another platform please let us know by opening a [new discussion](https://github.com/riscv-steel/riscv-steel/discussions) on GitHub. We have been working on creating versions of this guide for other FPGA boards and kits.

## Hello World project overview

The Hello World project was developed to be a minimal system easily portable to different FPGA boards, upon which it can then be expanded.

FPGA boards often include a UART-USB bridge for communicating with a host computer. The Hello World project takes advantage of this feature to send a *Hello World!* message via UART protocol. This message can be read on a host computer connected via USB cable to the FPGA's UART-USB bridge.

To send the message, a *Hello World!* program is loaded into memory and executed by the RISC-V processor in RISC-V Steel. The program controls the UART interface by sending the message and echoing back any bytes received in response.

The figure below depicts the main hardware devices in the Hello World project and how they interconnect. The RISC-V processor interfaces with the memory and the UART unit through an AXI4 crossbar. The UART interface is connected to the UART-USB bridge, which provides the interface between the system and a host computer.

<figure markdown>
  ![](images/hello-world.svg)
</figure>

## Requirements

### Hardware

To follow this guide you need one of the following development boards:

* **Digilent** [**Arty A7-35T**](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual)

* **Digilent** [**Arty A7-100T**](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual)

* **Digilent** [**Cmod A7**](https://digilent.com/reference/programmable-logic/cmod-a7/reference-manual)

### Software

Make sure you have the following software installed on your machine before you start:

* **AMD Xilinx Vivado**

    The latest version of AMD Xilinx Vivado is available for [download here](https://www.xilinx.com/support/download.html). During installation, remember to include support for the Artix-7 device family and the cable drivers.

* **PySerial**

    [PySerial](https://pyserial.readthedocs.io/en/latest/index.html) is a Python package for communication over serial protocol (UART). It can be installed by running:

    ```
    $ python -m pip install pyserial
    ```

## Step by step guide
### 1. Get RISC-V Steel

* First, clone RISC-V Steel repository from GitHub:

    ```
    $ git clone https://github.com/riscv-steel/riscv-steel.git
    ```

### 2. Start a serial terminal

* Connect the development board to your computer using a USB cable.
* Start a PySerial terminal by running:

    ```
    $ python -m serial.tools.miniterm
    ```

* A list of available serial ports will follow. Select the serial port the board is connected to ([see picture](images/pyserial.png)).
* **Keep the terminal open** for the next steps.

### 3. Program the FPGA

- Open the project at `./hello-world/<board-name>/hello-world.xpr` on AMD Xilinx Vivado.

- Click on *Open Hardware Manager* ([see picture](images/open-hardware-manager.png)).

- Next, click on *Open Target* -> *Auto Connect* ([see picture](images/auto-connect.png)).

- Vivado will autodetect the FPGA. The hardware box will show either `xc7a35t_0` or `xc7a100t_0`. Right-click on the device name and choose *Program Device* ([see picture](images/program-device.png)).

- A dialog box asking you to choose a bitstream programming file will open. Choose the file `hello_world_<board-name>.bit`, located at `./hello-world/<board-name>/` ([see picture](images/bitstream.png)).

- Click on *Program* ([see picture](images/bitstream.png)).

- Go back to the serial terminal window. The following message should appear on the terminal as soon as Vivado finishes programming the FPGA ([see picture](images/hello-world.png)):

    ```
    RISC-V Steel Hello World Project!
    Type something and press enter:
    ```

If you've reached this point, congratulations! You now have a working instance of RISC-V Steel that you can modify to meet your project needs.

</br>
</br>
</br>
</br>
</br>