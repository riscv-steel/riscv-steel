## Introduction

The easiest way to get started with RISC-V Steel is to modify its [Hello World Project](https://github.com/riscv-steel/riscv-steel/tree/main/hello-world). It runs on RISC-V Steel a simple program that sends the classic "Hello World!" message to your computer over UART protocol. This guide shows how to implement this project on an [Arty A7-35T FPGA board](https://digilent.com/shop/arty-a7-100t-artix-7-fpga-development-board/), but you can implement it on other FPGAs from the source files by following similar steps.

Arty was chosen because it is a relatively popular FPGA. If you'd like to have this guide ported to another platform please let us know by opening a [new issue](https://github.com/riscv-steel/riscv-steel/issues) on GitHub. We are creating versions of this guide for other FPGA boards and kits.

## The Hello World Project

The figure below shows the main hardware devices in the Hello World Project and how they interconnect. A RISC-V Steel processor core instance interfaces with a RAM memory and a UART unit through an AXI4 crossbar, and Arty's UART-USB bridge provides the interface between the system and your computer. By connecting Arty to your computer via USB cable to you can interact with the Hello World program (loaded into the 8K RAM during programming) from a serial terminal.

<figure markdown>
  ![](images/hello-world.svg)
</figure>

## Required software

Make sure you have the following software installed on your machine before you start:

* **AMD Xilinx Vivado**

    The latest version of AMD Xilinx Vivado is available for [download here](https://www.xilinx.com/support/download.html). During installation, remember to include support for the Artix-7 device family and the cable drivers.

* **PySerial**

    [PySerial](https://pyserial.readthedocs.io/en/latest/index.html) is a Python package for communication over serial protocol (UART). It can be installed by running:

    ```
    $ python -m pip install pyserial
    ```

## 1. Get RISC-V Steel

* Clone RISC-V Steel repository from GitHub:

    ```
    $ git clone https://github.com/riscv-steel/riscv-steel.git
    ```

## 2. Open a serial terminal

* Connect Arty to your computer using a USB cable.
* Start a PySerial terminal by running:

    ```
    $ python -m serial.tools.miniterm
    ```

* A list of available serial ports will follow. Select the serial port the board is connected to.
* **Keep the terminal open** for the next steps.

## 3. Program the FPGA

- Open project at `./hello-world/arty-a7-35t-board/hello-world.xpr` on Xilinx Vivado.

- Click on *Open Hardware Manager*.

- Next, click on *Open Target* -> *Auto Connect*.

- Vivado will autodetect Arty's FPGA device. The hardware box will show `xc7a35t_0` - right-click on it and choose *Program Device*.

- In the *Bitstream file* input box choose `hello_world_arty.bit` (located at `./hello-world/arty-a7-57t-board/`).

- Click on *Program*.

- Go back to the serial terminal window. The board sends the following message to your computer as soon as Vivado finishes programming the FPGA:

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