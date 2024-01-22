/**************************************************************************************************

This is a rewriting of the rvsteel_soc module using the new sys_bus module. This module was
tested on Arty-A7 to check the correct functionality of sys_bus.

**************************************************************************************************/

module soc_top #(

  // Frequency of 'clock' signal
  parameter CLOCK_FREQUENCY = 50000000,

  // Desired baud rate for UART unit
  parameter UART_BAUD_RATE = 9600,

  // Memory size in bytes - must be a multiple of 32
  parameter MEMORY_SIZE = 8192,

  // Text file with program and data (one hex value per line)
  parameter MEMORY_INIT_FILE = "hello-world.hex",

  // Address of the first instruction to fetch from memory
  parameter BOOT_ADDRESS = 32'h00000000

  )(

  input   wire  clock,
  input   wire  reset,
  input   wire  halt,
  input   wire  uart_rx,
  output  wire  uart_tx

  );

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;
  always @(posedge clock) clock_50mhz <= !clock_50mhz;

  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
    halt_debounced <= halt;
  end

  localparam NUM_DEVICE   = 'd2;
  localparam D_RAM        = 'd0;
  localparam D_UART       = 'd1;

  wire          irq_external;
  wire          irq_external_response;

  // RISC-V Steel 32-bit Processor (Manager Device) <=> System Bus

  wire  [31:0]  rw_address;
  wire  [31:0]  read_data;
  wire          read_request;
  wire          read_response;
  wire  [31:0]  write_data;
  wire  [3:0 ]  write_strobe;
  wire          write_request;
  wire          write_response;

  // Device
  wire    [NUM_DEVICE*32-1:0] device_rw_address       ;
  wire    [NUM_DEVICE*32-1:0] device_read_data        ;
  wire    [NUM_DEVICE-1:0]    device_read_request     ;
  wire    [NUM_DEVICE-1:0]    device_read_response    ;
  wire    [NUM_DEVICE*32-1:0] device_write_data       ;
  wire    [NUM_DEVICE*4-1:0]  device_write_strobe     ;
  wire    [NUM_DEVICE-1:0]    device_write_request    ;
  wire    [NUM_DEVICE-1:0]    device_write_response   ;

  // Base and mask
  wire    [NUM_DEVICE*32-1:0] addr_base               ;
  wire    [NUM_DEVICE*32-1:0] addr_mask               ;

  // 8192 KB
  assign addr_base[32*D_RAM +: 32]    =  32'h0000_0000;
  assign addr_mask[32*D_RAM +: 32]    = ~32'h7F_FFFF;

  assign addr_base[32*D_UART +: 32]   =  32'h8000_0000;
  assign addr_mask[32*D_UART +: 32]   =  32'hFFFF_FFF8;

  rvsteel_core #(

    .BOOT_ADDRESS                   (BOOT_ADDRESS                       )

  ) rvsteel_core_instance (

    // Global signals

    .clock                          (clock_50mhz                        ),
    .reset                          (reset_debounced                    ),
    .halt                           (halt_debounced                     ),

    // IO interface

    .rw_address                     (rw_address                         ),
    .read_data                      (read_data                          ),
    .read_request                   (read_request                       ),
    .read_response                  (read_response                      ),
    .write_data                     (write_data                         ),
    .write_strobe                   (write_strobe                       ),
    .write_request                  (write_request                      ),
    .write_response                 (write_response                     ),

    // Interrupt signals (hardwire inputs to zero if unused)

    .irq_external                   (irq_external                       ),
    .irq_external_response          (irq_external_response              ),
    .irq_timer                      (0), // unused
    .irq_timer_response             (),  // unused
    .irq_software                   (0), // unused
    .irq_software_response          (),  // unused

    // Real Time Clock (hardwire to zero if unused)

    .real_time_clock                (0)  // unused

  );

  system_bus #
  (
      .NUM_DEVICE(NUM_DEVICE)
  )
  system_bus_instance
  (

    .clock_i(clock_50mhz),
    .reset_i(reset_debounced),

    // Host
    .host_rw_address_i          (rw_address             ),
    .host_read_data_o           (read_data              ),
    .host_read_request_i        (read_request           ),
    .host_read_response_o       (read_response          ),
    .host_write_data_i          (write_data             ),
    .host_write_strobe_i        (write_strobe           ),
    .host_write_request_i       (write_request          ),
    .host_write_response_o      (write_response         ),

    // Devices
    .device_rw_address_o        (device_rw_address      ),
    .device_read_data_i         (device_read_data       ),
    .device_read_request_o      (device_read_request    ),
    .device_read_response_i     (device_read_response   ),
    .device_write_data_o        (device_write_data      ),
    .device_write_strobe_o      (device_write_strobe    ),
    .device_write_request_o     (device_write_request   ),
    .device_write_response_i    (device_write_response  ),

    // Devices address base and mask
    .addr_base                  (addr_base              ),
    .addr_mask                  (addr_mask              )
  );

  ram_memory #(

    .MEMORY_SIZE                    (MEMORY_SIZE                        ),
    .MEMORY_INIT_FILE               (MEMORY_INIT_FILE                   )

  ) ram_instance (

    // Global signals

    .clock                          (clock_50mhz                        ),
    .reset                          (reset_debounced                    ),

    // IO interface

    .rw_address     (device_rw_address      [32*D_RAM +: 32]    ),
    .read_data      (device_read_data       [32*D_RAM +: 32]    ),
    .read_request   (device_read_request    [D_RAM]             ),
    .read_response  (device_read_response   [D_RAM]             ),
    .write_data     (device_write_data      [32*D_RAM +: 32]    ),
    .write_strobe   (device_write_strobe    [4*D_RAM +: 4]      ),
    .write_request  (device_write_request   [D_RAM]             ),
    .write_response (device_write_response  [D_RAM]             )

  );

  uart #(

    .CLOCK_FREQUENCY                (CLOCK_FREQUENCY                    ),
    .UART_BAUD_RATE                 (UART_BAUD_RATE                     )

  ) uart_instance (

    // Global signals

    .clock                          (clock_50mhz                        ),
    .reset                          (reset_debounced                    ),

    // IO interface

    .rw_address     (device_rw_address      [32*D_UART +: 32]    ),
    .read_data      (device_read_data       [32*D_UART +: 32]    ),
    .read_request   (device_read_request    [D_UART]             ),
    .read_response  (device_read_response   [D_UART]             ),
    .write_data     (device_write_data      [32*D_UART +: 8]     ),
    .write_request  (device_write_request   [D_UART]             ),
    .write_response (device_write_response  [D_UART]             ),

    // RX/TX signals

    .uart_tx                        (uart_tx                            ),
    .uart_rx                        (uart_rx                            ),

    // Interrupt signaling

    .uart_irq                       (irq_external                       ),
    .uart_irq_response              (irq_external_response              )

  );

endmodule
