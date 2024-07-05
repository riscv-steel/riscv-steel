# RISC-V Steel Microcontroller Unit { class="main-section-title" }
<h2 class="main-section-subtitle">Documentation</h2>

## Architectural overview

RISC-V Steel Microcontroller Unit is the top hardware module of RISC-V Steel. It contains an instance of RISC-V Steel Processor Core, the main component of its design, and an instance of RISC-V Steel UART, GPIO, SPI, timer and memory modules.

The processor core is integrated to the memory, timer, UART, GPIO and SPI modules via a shared bus that coordinates memory accesses.

![Image title](images/rvsteel_mcu.svg){ width=100% }

## Source files

The Verilog source files of RISC-V Steel Microcontroller Unit are saved in the `hardware/mcu/` folder of RISC-V Steel repository.

## Instantiation template

``` systemverilog
rvsteel_mcu #(

  // See Configuration paramaters below for more information.

  .CLOCK_FREQUENCY      (50000000       ),
  .UART_BAUD_RATE       (9600           ),
  .MEMORY_SIZE          (8192           ),
  .MEMORY_INIT_FILE     ("mem_init.hex" ),
  .BOOT_ADDRESS         (32'h00000000   ),
  .GPIO_WIDTH           (1              ),
  .SPI_NUM_CHIP_SELECT  (1              ))

  rvsteel_mcu_instance  (

  // See I/O signals below for more information.

  .clock                (),
  .reset                (),
  .halt                 (),
  .uart_rx              (),
  .uart_tx              (),
  .gpio_input           (),
  .gpio_oe              (),
  .gpio_output          (),
  .sclk                 (),
  .pico                 (),
  .poci                 (),
  .cs                   ());
```

## Configuration parameters

| Parameter name and description        | Value type | Default value    |
| ---------------------- | ---------------- | ---|
| **BOOT_ADDRESS**</br>Memory address of the first instruction to be fetched and executed.  | 32-bit hexadecimal   | `32'h00000000`   |
| **CLOCK_FREQUENCY**</br>Frequency (in Hertz) of the `clock` signal.  | Integer | `50000000`       |
| **UART_BAUD_RATE**</br>Baud rate of the UART module (in bauds per second).   | Integer | `9600`           | 
| **MEMORY_SIZE**</br>Size of the Memory module (in bytes).     | Integer | `8192`           | 
| **MEMORY_INIT_FILE**</br>Absolute path to the memory initialization file. | String | `(empty string)` |
| **GPIO_WIDTH**</br>Number of general-purpose I/O pins.     | Integer | `1`           | 
| **SPI_NUM_CHIP_SELECT**</br>Number of Chip Select (CS) lines for the SPI controller. | Integer | `1` |

## I/O signals

| Pin name and description      | Direction | Size  |
| -------------- | --------- | ----- |
| **clock**</br>Clock input.      | Input     | 1 bit |
| **reset**</br>Reset pin (active-high).      | Input     | 1 bit |
| **halt**</br>Halt pin (active-high).       | Input     | 1 bit |
| **uart_rx**</br>UART receiver pin. | Input     | 1 bit |
| **uart_tx**</br>UART transmitter pin. | Output    | 1 bit |
| **gpio_input**</br>GPIO input signals. | Input     | `GPIO_WIDTH` |
| **gpio_oe**</br>GPIO output enable.    | Output    | `GPIO_WIDTH` |
| **gpio_output**</br>GPIO output signals. | Output    | `GPIO_WIDTH` |
| **sclk**</br>SPI Controller clock. | Output    | 1 bit |
| **pico**</br>SPI Peripheral In Controller Out.       | Output    | 1 bit |
| **poci**</br>SPI Peripheral Out Controller In.       | Input     | 1 bit |
| **cs**</br>SPI Chip Select lines.         | Output    | `SPI_NUM_CHIP_SELECT` |

## Memory Map

| Start address | Final address       | Block size (Bytes) | Device                     |
| ------------- | ------------------- | ------------------ | -------------------------- |
| `0x00000000`  | `0x(MEMORY_SIZE-1)` | `MEMORY_SIZE`      | RAM                        |
| `0x80000000`  | `0x8000000f`        | 16                 | UART                       |
| `0x80010000`  | `0x8001001f`        | 32                 | Timer                      |
| `0x80020000`  | `0x8002001f`        | 32                 | GPIO                       |
| `0x80030000`  | `0x8003001f`        | 32                 | SPI                        |

## Adding new devices

*1. Open `rvsteel_mcu.v` and look for the system bus configuration*

``` systemverilog
  // System bus configuration

  localparam NUM_DEVICES    = 5;
  localparam D0_RAM         = 0;
  localparam D1_UART        = 1;
  localparam D2_MTIMER      = 2;
  localparam D3_GPIO        = 3;
  localparam D4_SPI         = 4;
```

*2. Increment the `NUM_DEVICES` parameter value*

The `NUM_DEVICES` parameter sets the total number of devices and is used to size the width of the system bus. 

``` systemverilog
  localparam NUM_DEVICES    = 6;
```

*3. Create a parameter holding the index that will be used to address the new device*

The system bus configuration should look as follows:

``` systemverilog
  localparam NUM_DEVICES    = 6;
  localparam D0_RAM         = 0;
  localparam D1_UART        = 1;
  localparam D2_MTIMER      = 2;
  localparam D3_GPIO        = 3;
  localparam D4_SPI         = 4;
  localparam D5_NEW_DEVICE  = 5; // your new device
```

*4. Assign the new device a memory region*

You can assign the new device to any free region (see [Memory Map](#memory-map)). The region cannot overlap the address space of other devices and its size must be a power of 2. 

In the example below, the new device `D5_NEW_DEVICE` is assigned a 32KB region starting at `0x80040000`:

``` systemverilog
  wire  [NUM_DEVICES*32-1:0] device_start_address;
  wire  [NUM_DEVICES*32-1:0] device_region_size;

  assign device_start_address [32*D0_RAM       +: 32]  = 32'h0000_0000;
  assign device_region_size   [32*D0_RAM       +: 32]  = MEMORY_SIZE;

  assign device_start_address [32*D1_UART      +: 32]  = 32'h8000_0000;
  assign device_region_size   [32*D1_UART      +: 32]  = 16;

  assign device_start_address [32*D2_MTIMER    +: 32]  = 32'h8001_0000;
  assign device_region_size   [32*D2_MTIMER    +: 32]  = 32;

  assign device_start_address [32*D3_GPIO      +: 32]  = 32'h8002_0000;
  assign device_region_size   [32*D3_GPIO      +: 32]  = 32;

  assign device_start_address [32*D4_SPI       +: 32]  = 32'h8003_0000;
  assign device_region_size   [32*D4_SPI       +: 32]  = 32;

  // Your new device
  assign device_start_address [32*D5_NEW_DEVICE+: 32]  = 32'h8004_0000;
  assign device_region_size   [32*D5_NEW_DEVICE+: 32]  = 32768;

```

*5. Instantiate the new device*

Finally, you have to instantiate the new device in the `rvsteel_mcu` module and connect it to the system bus interface.

A template for instantiating and connecting the new device to the system bus is provided below:

``` systemverilog
  // Instantiate the new device in the rvsteel_mcu.v module like this:

  new_device
  new_device_instance (

    // I/O interface of the new device

    .new_device_rw_address      (device_rw_address                        ),
    .new_device_read_data       (device_read_data[32*D2_NEW_DEVICE +: 32] ),
    .new_device_read_request    (device_read_request[D2_NEW_DEVICE]       ),
    .new_device_read_response   (device_read_response[D2_NEW_DEVICE]      ),
    .new_device_write_data      (device_write_data                        ),
    .new_device_write_strobe    (device_write_strobe                      ),
    .new_device_write_request   (device_write_request[D2_NEW_DEVICE]      ),
    .new_device_write_response  (device_write_response[D2_NEW_DEVICE]     )

  );
```

!!!info

     RISC-V Steel Processor Core will issue read and write requests to the new device as described in the [I/O Operations](core.md#io-operations) section. The new device must comply with this protocol.

</br>
</br>