# Getting Started

This guide shows you how to synthesize the Hello World demo for some popular FPGAs so you can quickly get started with RISC-V Steel SoC IP.

The Hello World demo is an instance of the SoC IP that sends a Hello World message to a host computer via UART protocol. Its goal is to introduce you to the SoC design so that you can expand it and develop your own embedded applications.

## Prerequisites

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

1. Click **Run Tcl Script** in the **Tools** menu.

2. Search for `create-project-XXX.tcl` and click **Ok**. `XXX` stands for your board name.

    This file is located at `hello-world/XXX/`.

    Running this script will create a new Vivado project for your FPGA board with the Hello World demo.
    
    To save your time, we provide a precompiled bitstream to program the FPGA in the same directory as the script.
    
    Generating the bitstream might be a bit slow. If you want to generate it anyway click **Generate Bitstream** in the **Flow** menu.

3. Click **Open Hardware Manager** in the **Flow** menu.

4. Click **Auto Connect** in the **Tools** menu.

5. The hardware box will show the name of your device.

6. Right-click on your device name and next on **Program Device**.

7. A dialog box asking you to provide the bitstream will open.

8. Search for `hello_world_XXX.bit`.

    This file is located at `hello-world/XXX/`.

    In case you generated the bitstream yourself you can find it at `hello-world/XXX/hello-world-XXX/hello-world-XXX.runs/impl_1`.

9. Click on **Program** and wait for Vivado to finish programming the FPGA.

Now go back to PySerial terminal window. You should see the message below:

<figure markdown>
  ![](images/hello-world.png){ width="500" }
</figure>

## Next steps

If you've reached this point, congratulations! You have a working instance of the SoC IP. You can now change it to create your own embedded applications.

- **Run your own software**

    In the [SoC IP Software Guide](software-guide.md) you find how to write, compile, and run software applications for RISC-V Steel SoC IP.

- **Expand the hardware**

    In the [SoC IP Reference Guide](soc.md) you find detailed information about the design so that you can expand it to create larger projects.

</br>
</br>