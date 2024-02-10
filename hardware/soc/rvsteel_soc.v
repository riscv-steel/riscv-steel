// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvsteel_soc #(

  // Frequency of 'clock' signal
  parameter CLOCK_FREQUENCY = 50000000  ,
  // Desired baud rate for UART unit
  parameter UART_BAUD_RATE = 9600       ,
  // Memory size in bytes - must be a power of 2
  parameter MEMORY_SIZE = 8192          ,
  // Text file with program and data (one hex value per line)
  parameter MEMORY_INIT_FILE = ""       ,
  // Address of the first instruction to fetch from memory
  parameter BOOT_ADDRESS = 32'h00000000

  )(

  input   wire  clock,
  input   wire  reset,
  input   wire  halt,
  input   wire  uart_rx,
  output  wire  uart_tx

  );

  // System bus configuration

  localparam NUM_DEVICES    = 2;
  localparam D0_RAM         = 0;
  localparam D1_UART        = 1;

  wire  [NUM_DEVICES*32-1:0] device_start_address;
  wire  [NUM_DEVICES*32-1:0] device_region_size;

  assign device_start_address [32*D0_RAM  +: 32]  = 32'h0000_0000;
  assign device_region_size   [32*D0_RAM  +: 32]  = 8192;

  assign device_start_address [32*D1_UART +: 32]  = 32'h8000_0000;
  assign device_region_size   [32*D1_UART +: 32]  = 8;

  // RISC-V Steel 32-bit Processor (Manager Device) <=> System Bus

  wire  [31:0]                manager_rw_address      ;
  wire  [31:0]                manager_read_data       ;
  wire                        manager_read_request    ;
  wire                        manager_read_response   ;
  wire  [31:0]                manager_write_data      ;
  wire  [3:0 ]                manager_write_strobe    ;
  wire                        manager_write_request   ;
  wire                        manager_write_response  ;

  // System Bus <=> Managed Devices

  wire  [31:0]                device_rw_address       ;
  wire  [NUM_DEVICES*32-1:0]  device_read_data        ;
  wire  [NUM_DEVICES-1:0]     device_read_request     ;
  wire  [NUM_DEVICES-1:0]     device_read_response    ;
  wire  [31:0]                device_write_data       ;
  wire  [3:0]                 device_write_strobe     ;
  wire  [NUM_DEVICES-1:0]     device_write_request    ;
  wire  [NUM_DEVICES-1:0]     device_write_response   ;

  // Interrupt signals

  wire          irq_uart;
  wire          irq_uart_response;
  wire  [15:0]  irq_fast_vector;
  wire  [15:0]  irq_fast_response_vector;

  // Fast interrupt vector configuration

  assign irq_fast_vector = {15'b0, irq_uart};
  assign irq_uart_response = irq_fast_response_vector[0];

  rvsteel_core #(

    .BOOT_ADDRESS                   (BOOT_ADDRESS                       )

  ) rvsteel_core_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),
    .halt                           (halt                               ),

    // IO interface

    .rw_address                     (manager_rw_address                 ),
    .read_data                      (manager_read_data                  ),
    .read_request                   (manager_read_request               ),
    .read_response                  (manager_read_response              ),
    .write_data                     (manager_write_data                 ),
    .write_strobe                   (manager_write_strobe               ),
    .write_request                  (manager_write_request              ),
    .write_response                 (manager_write_response             ),

    // Interrupt request signals (hardwire to zero if unused)

    .irq_fast                       (irq_fast_vector                    ),
    .irq_external                   (0), // unused
    .irq_timer                      (0), // unused
    .irq_software                   (0), // unused

    // Interrupt response signals (leave unconnected if unused)

    .irq_fast_response              (irq_fast_response_vector           ),
    .irq_external_response          (),  // unused
    .irq_timer_response             (),  // unused
    .irq_software_response          (),  // unused

    // Real Time Clock (hardwire to zero if unused)

    .real_time_clock                (0)  // unused

  );

  rvsteel_bus #(

    .NUM_DEVICES(NUM_DEVICES)

  ) rvsteel_bus_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // Interface with the manager device (Processor Core IP)

    .manager_rw_address             (manager_rw_address                 ),
    .manager_read_data              (manager_read_data                  ),
    .manager_read_request           (manager_read_request               ),
    .manager_read_response          (manager_read_response              ),
    .manager_write_data             (manager_write_data                 ),
    .manager_write_strobe           (manager_write_strobe               ),
    .manager_write_request          (manager_write_request              ),
    .manager_write_response         (manager_write_response             ),

    // Interface with the managed devices

    .device_rw_address              (device_rw_address                  ),
    .device_read_data               (device_read_data                   ),
    .device_read_request            (device_read_request                ),
    .device_read_response           (device_read_response               ),
    .device_write_data              (device_write_data                  ),
    .device_write_strobe            (device_write_strobe                ),
    .device_write_request           (device_write_request               ),
    .device_write_response          (device_write_response              ),

    // Base addresses and masks of the managed devices

    .device_start_address          (device_start_address                ),
    .device_region_size            (device_region_size                  )

  );

  rvsteel_ram #(

    .MEMORY_SIZE                    (MEMORY_SIZE                        ),
    .MEMORY_INIT_FILE               (MEMORY_INIT_FILE                   )

  ) rvsteel_ram_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // IO interface

    .rw_address                     (device_rw_address                  ),
    .read_data                      (device_read_data[32*D0_RAM +: 32]  ),
    .read_request                   (device_read_request[D0_RAM]        ),
    .read_response                  (device_read_response[D0_RAM]       ),
    .write_data                     (device_write_data                  ),
    .write_strobe                   (device_write_strobe                ),
    .write_request                  (device_write_request[D0_RAM]       ),
    .write_response                 (device_write_response[D0_RAM]      )

  );

  rvsteel_uart #(

    .CLOCK_FREQUENCY                (CLOCK_FREQUENCY                    ),
    .UART_BAUD_RATE                 (UART_BAUD_RATE                     )

  ) rvsteel_uart_instance (

    // Global signals

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // IO interface

    .rw_address                     (device_rw_address                  ),
    .read_data                      (device_read_data[32*D1_UART +: 32] ),
    .read_request                   (device_read_request[D1_UART]       ),
    .read_response                  (device_read_response[D1_UART]      ),
    .write_data                     (device_write_data[7:0]             ),
    .write_request                  (device_write_request[D1_UART]      ),
    .write_response                 (device_write_response[D1_UART]     ),

    // RX/TX signals

    .uart_tx                        (uart_tx                            ),
    .uart_rx                        (uart_rx                            ),

    // Interrupt signaling

    .uart_irq                       (irq_uart                           ),
    .uart_irq_response              (irq_uart_response                  )

  );

endmodule
