# Getting Started

This guide shows you how to synthesize the Hello World demo for some popular FPGAs so that you can quickly get started with RISC-V Steel SoC.

The Hello World demo is an instance of RISC-V Steel SoC that sends a Hello World message to a host computer via UART protocol. The goal is to introduce you to the SoC design so that you can expand it and develop your own embedded applications.

## Pre-requisites

To follow this guide you'll need one of the following FPGA boards:

* [**Digilent Arty A7**](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual)

* [**Digilent Cmod A7**](https://digilent.com/reference/programmable-logic/cmod-a7/reference-manual)

Also, make sure you have the following software installed on your computer:

* **AMD Xilinx Vivado**

    The latest version of AMD Xilinx Vivado is available for [download here](https://www.xilinx.com/support/download.html).

    During installation, remember to include support for the Artix-7 device family and the cable drivers.

* **PySerial**

    [PySerial](https://pyserial.readthedocs.io/en/latest/index.html) is a Python package for communication over serial protocol. It can be installed by running:

    ```
    python -m pip install pyserial
    ```

## Get RISC-V Steel

Clone RISC-V Steel repository from GitHub:

```
git clone https://github.com/riscv-steel/riscv-steel.git
```

## Start PySerial

Connect the board to your computer using a USB cable and start PySerial terminal by running:

```
python -m serial.tools.miniterm
```

A list of available serial ports will follow. Select the port your board is connected to and **keep the terminal open** for the next steps.

<figure markdown>
  ![](images/pyserial.png){ width="500" }
</figure>

## Program the FPGA

Open **AMD Xilinx Vivado** and follow the steps:

1. Click on **Open Hardware Manager** in the **Flow** menu.

2. Click on **Auto Connect** in the **Tools** menu.

3. The hardware box will show the name of your device, either **xc7a35t_0** or **xc7a100t_0**

4. Right-click on your device name and next on **Program Device**.

5. A dialog box asking you to provide the bitstream programming file will open.

6. Search for **`hello_world_<board-name>.bit`**.

    This file is located at **`riscv-steel/hello-world/<board-name>/`**.

7. Click on **Program** and wait it finish programming the FPGA.

Now go back to PySerial terminal window. You should see the message below:

<figure markdown>
  ![](images/hello-world.png){ width="500" }
</figure>

## Next steps

If you've reached this point, congratulations! You have a working instance of RISC-V Steel SoC. You can now change it to create your own embedded applications.

- **Run your own software**

    The [Software Guide](software-guide.md) shows you how to write, compile, run and debug RISC-V applications for RISC-V Steel SoC. Also, [Steel API](steel-api.md) provides you a collection of function calls that makes it easier for you to write your own software.

- **Configure and expand the hardware**

    The [RISC-V Steel SoC Reference Guide](soc-reference.md) contains detailed information about RISC-V Steel SoC design. You can configure the design to meet your project requirements and expand it by adding new hardware resources.

</br>
</br>