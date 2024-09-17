# FreeRTOS Example

## Introduction

The FreeRTOS example is a more sophisticated application that runs on top of [FreeRTOS](https://www.freertos.org/), an open-source real-time operating system. The application uses the GPIO controller to make 2 LEDs blink in a specific pattern.

## Prerequisites

To run this example you need an FPGA board with at least 2 LEDs and 32KB of BRAM.

Additionally, you need to have the RISC-V GNU Toolchain installed on your machine to build the example. You can find instructions on how to install the RISC-V GNU Toolchain in the [User Guide](../userguide.md#prerequisites).

## Building the example

Run the commands below to build the example:

```bash
# Clone RISC-V Steel repository (if not cloned yet)
git clone https://github.com/riscv-steel/riscv-steel

# Build the software for the FreeRTOS example
# -- PREFIX: Absolute path to the RISC-V GNU Toolchain installation folder
# -- CLOCK_FREQUENCY: Frequency of the clock source connected to 'rvsteel_mcu'
cd riscv-steel/examples/freertos/software
make PREFIX=/opt/riscv CLOCK_FREQUENCY=<freq_in_hertz>
```

The building process will generate a `freertos.hex` file in the `build/` folder. This file is used in the next step to initialize the Microcontroller IP memory.

## FPGA implementation

Using your preferred text editor, create a Verilog file name `freertos.v` and add the source code below. Change the source code as follow:

- Fill in the `MEMORY_INIT_FILE` parameter with the absolute path to the `freertos.hex` file (generated in the previous step).
- Fill in the `CLOCK_FREQUENCY` parameter with the frequency (in Hertz) of the clock source connected to `rvsteel_mcu`.

```verilog
module freertos  #(
  
  parameter GPIO_WIDTH = 2

  )(

  input   wire clock,
  input   wire reset,
  output  wire [GPIO_WIDTH-1:0] gpio

  );

  // Reset button debouncing
  reg reset_debounced;
  always @(posedge clock) begin
    reset_debounced <= reset;
  end

  rvsteel_mcu #(

  // Please adjust these parameters accordingly
  .CLOCK_FREQUENCY          (50000000                   ),
  .MEMORY_SIZE              (32768                      ),
  .MEMORY_INIT_FILE         ("/path/to/freertos.hex"    ),
  .GPIO_WIDTH               (GPIO_WIDTH                 )

  ) rvsteel_mcu_instance (

  .clock                    (clock                      ),
  .reset                    (reset_debounced            ),
  .gpio_output              (gpio                       ),

  // Unused inputs need to be hardwired to zero
  .halt                     (1'b0                       ),
  .uart_rx                  (1'b0                       ),
  .gpio_input               ({GPIO_WIDTH{1'b0}}         ),
  .poci                     (1'b0                       ),

  // Unused outputs can be left open
  .uart_tx                  (                           ),  
  .gpio_oe                  (                           ),
  .sclk                     (                           ),
  .pico                     (                           ),  
  .cs                       (                           ));

endmodule
```

To implement this module on an FPGA, follow the steps below:

- Start a new project on the EDA tool provided by your FPGA vendor (e.g. AMD Vivado, Intel Quartus, Lattice iCEcube)
- Add the following files to the project:
    - The Verilog file you just created, `freertos.v`.
    - All Microcontroller IP [source files](../hardware/mcu.md#source-files).
- Create a design constraints file and map the ports of `freertos.v` to the respective devices on the FPGA board.
    - Map the `gpio` outputs to 2 LEDs on the board
    - Map the `reset` input to a push-button or switch on the board
    - Map the `clock` input to a clock source
- Run synthesis, place and route, and any other intermediate step needed to generate a bitstream for the FPGA.
- Generate the bitstream and program the FPGA with it.

The LEDs should start blinking once you've finished programming the FPGA!

## Featured boards

We provide a complete FreeRTOS example project for some featured FPGA boards.

If you have any of the FPGA boards below, follow the steps specific to your board:

### Arty A7

- Build the FreeRTOS application as instructed in [Building the example](#building-the-example), using `CLOCK_FREQUENCY=50000000`

    The Arty A7 100 MHz clock source is internally divided by 2 so that the design can meet timing constraints.

- On AMD Vivado, click __Tools / Run Tcl Script__

    Select `examples/freertos/boards/arty_a7/create_project_arty_a7_<variant>t.tcl`, where &lt;variant&gt; is the variant of your board (either 35T or 100T).

- Click **Generate Bitstream** and program the FPGA as usual
- The LEDs should start blinking once you've finished programming the FPGA!

### Cmod A7

- Build the FreeRTOS application as instructed in [Building the example](#building-the-example), using `CLOCK_FREQUENCY=12000000`
- On AMD Vivado, click __Tools / Run Tcl Script__

    Select `examples/freertos/boards/cmod_a7/create_project_cmod_a7.tcl`.

- Click **Generate Bitstream** and program the FPGA as usual
- The LEDs should start blinking once you've finished programming the FPGA!

</br>
</br>