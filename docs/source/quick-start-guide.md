RISC-V Steel comes with a [Hello World Project](https://github.com/riscv-steel/riscv-steel-core/tree/main/hello-world-project) to quickly get you started in hardware development with the core. The project is designed to provide you with some basic elements for your own projects as the core alone does not form a complete system. In this guide, we'll show you how to run the project on the [Arty A7-35T](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/) development board, which was chosen because it is a relatively popular platform among hardware developers.

We want to create versions of this guide for other FPGAs and development boards, so if you want to have this guide ported to another platform please let us know by opening a [new issue](https://github.com/riscv-steel/riscv-steel-core/issues) on GitHub.

## Hello World Project overview

The figure below shows the project's main hardware devices and how they interconnect. A Hello World design composed of a RISC-V Steel instance, an AXI Crossbar, a RAM memory and a UART unit will be programmed into Arty's FPGA and connected to its UART-USB bridge. Then, with a USB cable, you can connect the board to your computer and interact with the Hello World program (loaded into the 8K RAM during programming) from a serial terminal.

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

* Clone RISC-V Steel Core repository from GitHub:

    ```
    $ git clone https://github.com/riscv-steel/riscv-steel-core.git
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

- Open project at `hello-world-project/hello-world-arty-a7-35t.xpr` on Xilinx Vivado.

- In Vivado, click on *Open Hardware Manager*.

- Next, click on *Open Target* -> *Auto Connect*.

- Vivado will autodetect Arty's FPGA device. The hardware box will show `xc7a35t_0` - right-click on it and choose *Program Device*.

- In the *Bitstream file* input box choose the file `hello_world_arty_a7_35t.bit`.

    This file is located at `hello-world-project/hello-world-arty-a7-35t.runs/impl_1`

- Click on the *Program* button.

- Get back to the serial terminal window. The board sends the following message to your computer as soon Vivado finishes programming the FPGA:

<figure markdown>
  ![pyserial-hello](images/getting-started/pyserial-0.png)
</figure>