The figure below shows the architecture of an example system that uses Steel, built with the free edition of Vivado ([link](https://www.xilinx.com/products/design-tools/vivado.html)) for an Artix-7 FPGA (Digilent Arty-A7 35T board, [link](https://store.digilentinc.com/arty-a7-artix-7-fpga-development-board/)). This project files are stored at **soc/vivado** and, of course, you need Vivado installed on your machine and an Arty A7-35T board to run this project.

The system is formed by Steel + RAM + UART interface. The UART interface was designed to have 9600 baud rate, 1 stop bit, no parity and no control.

<p align="center">
<img src="../images/steel-soc.png" width="70%"></img>
</br>
</br>
<strong>Example system built with Steel</strong>
</p>


Note that the RAM and the UART share the processor interface to read/write data. A bus arbiter is used to multiplex this interface signals according to the address the core wants to access. In this example, the address 0x00010000 is used to access the UART transmitter. The address 0x00020000 is used to access the UART receiver. RAM addresses start at 0x00000000 and end at 0x00001fff. All other addresses are invalid.

A program compiled to run with this project is stored at the **software** directory. The program sends the string "Hello World, Steel!" through the UART transmitter.

If you have an Arty A7-35T board and Vivado you can run the project following these instructions:

1. Run Vivado and open the project (the file named **example_soc.xpr** at **soc/vivado** folder)
2. Connect the board to your computer using a USB cable
3. Find the name that your system gave to the board USB-UART interface. In Windows it should be something like COMX, and in Linux systems something like /dev/ttyUSBX (X is a number given by the OS)
4. Download a program to emulate a serial terminal, like PuTTY (available for Windows and Linux systems)
5. Configure a serial connection for the USB-UART interface to 9600 baud rate, 8 data bits, 1 stop bit, no parity and no control
6. Open the serial terminal after configuration
7. Generate the bitstream and program the board in Vivado

After that you should see this message on the terminal:

![Hello World, Steel!](images/steel-hello.png)

