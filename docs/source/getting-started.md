# Getting started

### Overview

This guide will show you how to get Steel's **Hello World** project working on the [Arty A7-35T](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/) development board. It sends a "Hello World" message over a UART serial interface to your computer, and can serve as a starting point for your designs.

### Install prerequisites

Before you start make sure you have the following software installed on your machine:

#### Xilinx Vivado

At the heart of the [Arty A7-35T](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/) board is a Xilinx Artix-7 FPGA so you need Vivado installed on your machine to be able to program the board.

The latest version of Vivado is available for [download here](https://www.xilinx.com/support/download.html).

!!! tip 
    During installation, remember to include support for the Artix-7 device family and the cable drivers!

#### pySerial

[pySerial](https://pyserial.readthedocs.io/en/latest/index.html) is a Python package that allows your computer to communicate over UART serial protocol. After installation, your computer will be able to send and receive messages to and from the Hello World system.

To install pySerial open a terminal and run:

```
$ python -m pip install pyserial
```

### Download the Steel Core

You can clone the Steel Core repository from GitHub:

```
$ git clone https://github.com/rafaelcalcada/steel-core.git
```

Or, if you prefer, you can [download it here](https://github.com/rafaelcalcada/steel-core/archive/refs/heads/main.zip).

### Start a serial terminal

Before starting the serial terminal, connect the Arty A7-35T Board to your computer using the USB cable. Make sure the board is powered on (a red LED should be lit).

Then open a terminal and start pySerial's Miniterm:

```
$ python -m serial.tools.miniterm
```

A list of available serial ports will show up on the screen. Select the USB serial port the board is connected to.

!!! tip
    If your computer shows more than one available serial port and you're not sure which one is your board's you can find it out by running the command above with the board disconnected and then running it again with the board connected. The "extra" port in the list when the board is connected is the port you're looking for.

After choosing the port the terminal will be waiting for messages from the board. Keep the terminal open.

### Programming the FPGA

Follow the steps below in Vivado to get the Hello World project running on the [Arty A7](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/) board.

1. Open the `hello_world.xpr` file located in the `hello_world/vivado/` folder on Vivado.

2. Click on *Open Hardware Manager*, located in the section *Program and Debug* of the *Flow Navigator* (the navigation bar on the left).

3. Next, click on *Open Target > Auto Connect*.

4. Vivado will autodetect Arty's FPGA and the device `xc7a35t_0` should appear in the Hardware box. Right-click on `xc7a35t_0` and choose *Program Device*.

5. The bitstream file `hello_world.bit` (located at `hello_world.runs/impl_1/`) should appear in the file input box. To program the FPGA, click on the *Program* button.

The FPGA is now programmed with the Hello World project!

### Interact with the Hello World system

The board will send the following message immediately after the FPGA is programmed:

![pyserial-hello](images/getting-started/pyserial-1.png)

If you type a character it is echoed back on the screen. If you press Enter, the message "You pressed Enter key" is shown.

Although it seems simple, the UART connection between the board and your computer allows you to:

- Send commands to control devices on the board from your computer
- Obtain and display information about the status of the board devices

</br>

