# Hello World Example

## Introduction

The Hello World example is a bare-metal application that uses the UART controller of RISC-V Steel to send a Hello World message to a host computer.

## Prerequisites

To run this example, you need an FPGA board that has a UART-USB bridge, a common feature on most FPGAs.

Additionally, you need to have the [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) installed on your machine to build the example. You can find instructions on how to install the RISC-V GNU Toolchain in the [User Guide](../userguide.md#prerequisites).

## Building the example

Run the commands below to build the Hello World example:

```bash
# Clone RISC-V Steel repository (if not cloned yet)
git clone https://github.com/riscv-steel/riscv-steel

# Build the software for the Hello World example
# -- PREFIX: Absolute path to the RISC-V GNU Toolchain installation folder
cd riscv-steel/examples/hello_world/software
make PREFIX=/opt/riscv
```

The building process will generate a `hello_world.hex` file in the `build/` folder. This file is used in the next step to initialize the memory of RISC-V Steel.

## FPGA implementation

Using your preferred text editor, create a Verilog file name `hello_world.v` and add the source code below. Change the source code as follows:

- Fill in `MEMORY_INIT_FILE` with the absolute path to the `hello_world.hex` file generated in the previous step.
- Fill in `CLOCK_FREQUENCY` with the frequency (in Hertz) of the `clock` input.

```verilog
module hello_world (

  input   wire clock,
  input   wire reset,
  output  wire uart_tx

  );

  // Reset button debouncing
  reg reset_debounced;
  always @(posedge clock) begin
    reset_debounced <= reset;
  end

  rvsteel_mcu #(

  // Please adjust these two parameters accordingly
  .CLOCK_FREQUENCY          (50000000                   ),
  .MEMORY_INIT_FILE         ("/path/to/hello_world.hex" )

  ) rvsteel_mcu_instance (

  .clock                    (clock                      ),
  .reset                    (reset_debounced            ),
  .uart_tx                  (uart_tx                    ),

  // Unused inputs need to be hardwired to zero
  .halt                     (1'b0                       ),
  .uart_rx                  (1'b0                       ),
  .gpio_input               (1'b0                       ),
  .poci                     (1'b0                       ),

  // Unused outputs can be left open  
  .gpio_oe                  (                           ),
  .gpio_output              (                           ),
  .sclk                     (                           ),
  .pico                     (                           ),  
  .cs                       (                           ));

endmodule
```

To implement this module on FPGA, follow the steps below:

- Start a new project on the EDA tool provided by your FPGA vendor (e.g. AMD Vivado, Intel Quartus, Lattice iCEcube)
- Add the following files to the project:
    - The Verilog file you just created, `hello_world.v`.
    - All [source files](../hardware/mcu.md#source-files) of RISC-V Steel.
- Create a design constraints file and map the ports of `hello_world.v` to the respective devices on the FPGA board.
    - Map the `uart_tx` output to the UART-USB bridge
    - Map the `reset` input to a push-button or switch
    - Map the `clock` input to a clock source
- Run synthesis, place and route, and any other intermediate step needed to generate a bitstream for the FPGA.
- Generate the bitstream and program the FPGA with it.

## Running the application

Now that the FPGA is programmed, you can see the Hello World message on a host computer with the help of a serial terminal emulator like PySerial:

- Connect the FPGA board to your computer (if not already connected)
- Install PySerial (or other serial terminal emulator):
    
    ```
    python3 -m pip install pyserial
    ```

- Open a serial terminal

    With PySerial, a serial terminal can be opened by running:
    
    ```
    python3 -m serial.tools.miniterm
    ```

    PySerial will show the available serial ports, one of which is the UART-USB bridge of the FPGA board. Choose it to connect.

- Finally, press the reset button.

You should now see the Hello World message!

## Featured boards

We provide specific projects for some featured FPGA boards.

Follow the steps specific to your board if you have any of the boards below:

### Arty A7

- Build the Hello World application as instructed in [Building the example](#building-the-example)
- On AMD Vivado, click __Tools / Run Tcl Script__

    Select `examples/hello_world/boards/arty_a7/create_project_arty_a7_<variant>.tcl`, where `<variant>` is the variant of your board (either 35T or 100T).

- Click **Generate Bitstream** and program the FPGA as usual
- Run the example as instructed in [Running the application](#running-the-application)

### Cmod A7

- Build the Hello World application as instructed in [Building the example](#building-the-example)
- On AMD Vivado, click __Tools / Run Tcl Script__

    Select `examples/hello_world/boards/cmod_a7/create_project_cmod_a7.tcl`.

- Click **Generate Bitstream** and program the FPGA as usual
- Run the example as instructed in [Running the application](#running-the-application)

</br>
</br>