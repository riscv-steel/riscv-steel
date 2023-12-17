/**************************************************************************************************

MIT License

Copyright (c) 2020-present Rafael Calcada

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**************************************************************************************************/

/**************************************************************************************************

Project Name:  RISC-V Steel System-on-Chip
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    rvsteel_soc
 
**************************************************************************************************/

module rvsteel_soc #(

  // Frequency of 'clock' signal
  parameter CLOCK_FREQUENCY = 50000000,

  // Desired baud rate for UART unit
  parameter UART_BAUD_RATE = 9600,

  // Memory size in bytes - must be a multiple of 32
  parameter MEMORY_SIZE = 8192,  

  // Text file with program and data (one hex value per line)
  parameter MEMORY_INIT_FILE = "",

  // Address of the first instruction to fetch from memory
  parameter BOOT_ADDRESS = 32'h00000000

  )(

  input   wire  clock,
  input   wire  reset,
  input   wire  uart_rx,
  output  wire  uart_tx

  );
  
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
  
  // RAM Memory (Device #0) <=> System Bus

  wire  [31:0]  device0_rw_address;
  wire  [31:0]  device0_read_data;
  wire          device0_read_request;
  wire          device0_read_response;
  wire  [31:0]  device0_write_data;
  wire  [3:0 ]  device0_write_strobe;
  wire          device0_write_request;
  wire          device0_write_response;
  
  // UART (Device #1) <=> System Bus

  wire  [31:0]  device1_rw_address;
  wire  [31:0]  device1_read_data;
  wire          device1_read_request;
  wire          device1_read_response;
  wire  [31:0]  device1_write_data;
  wire  [3:0 ]  device1_write_strobe;
  wire          device1_write_request;
  wire          device1_write_response;

  /* Uncomment to add new devices

  // Device #2 <=> System Bus

  wire  [31:0]  device2_rw_address;
  wire  [31:0]  device2_read_data;
  wire          device2_read_request;
  wire          device2_read_response;
  wire  [31:0]  device2_write_data;
  wire  [3:0 ]  device2_write_strobe;
  wire          device2_write_request;
  wire          device2_write_response;

  // Device #3 <=> System Bus

  wire  [31:0]  device3_rw_address;
  wire  [31:0]  device3_read_data;
  wire          device3_read_request;
  wire          device3_read_response;
  wire  [31:0]  device3_write_data;
  wire  [3:0 ]  device3_write_strobe;
  wire          device3_write_request;
  wire          device3_write_response;

  */

  rvsteel_core #(

    .BOOT_ADDRESS                   (BOOT_ADDRESS                       )

  ) rvsteel_core_instance (

    // Global clock and active-high reset

    .clock                          (clock                              ),
    .reset                          (reset                              ),

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
  
  system_bus #(

    .DEVICE0_START_ADDRESS          (32'h00000000                       ),
    .DEVICE0_FINAL_ADDRESS          (MEMORY_SIZE-1                      ),
    .DEVICE1_START_ADDRESS          (32'h80000000                       ),
    .DEVICE1_FINAL_ADDRESS          (32'h80000004                       )

    /* Uncomment to add new devices

    .DEVICE2_START_ADDRESS          (32'hdeadbeef                       ),
    .DEVICE2_FINAL_ADDRESS          (32'hdeadbeef                       ),
    .DEVICE3_START_ADDRESS          (32'hdeadbeef                       ),
    .DEVICE3_FINAL_ADDRESS          (32'hdeadbeef                       )

    */

  ) system_bus_instance (
  
    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // RISC-V Steel 32-bit Processor (Manager Device) <=> System Bus

    .rw_address                     (rw_address                         ),
    .read_data                      (read_data                          ),
    .read_request                   (read_request                       ),
    .read_response                  (read_response                      ),
    .write_data                     (write_data                         ),
    .write_strobe                   (write_strobe                       ),
    .write_request                  (write_request                      ),
    .write_response                 (write_response                     ),
    
    // RAM Memory (Device #0) <=> System Bus

    .device0_rw_address             (device0_rw_address                 ),
    .device0_read_data              (device0_read_data                  ),
    .device0_read_request           (device0_read_request               ),
    .device0_read_response          (device0_read_response              ),
    .device0_write_data             (device0_write_data                 ),
    .device0_write_strobe           (device0_write_strobe               ),
    .device0_write_request          (device0_write_request              ),
    .device0_write_response         (device0_write_response             ),
    
    // UART (Device #1) <=> System Bus

    .device1_rw_address             (device1_rw_address                 ),
    .device1_read_data              (device1_read_data                  ),
    .device1_read_request           (device1_read_request               ),
    .device1_read_response          (device1_read_response              ),
    .device1_write_data             (device1_write_data                 ),
    .device1_write_strobe           (device1_write_strobe               ),
    .device1_write_request          (device1_write_request              ),
    .device1_write_response         (device1_write_response             )

    /* Uncomment to add new devices

    // Device #2 <=> System Bus

    .device2_rw_address             (device2_rw_address                 ),
    .device2_read_data              (device2_read_data                  ),
    .device2_read_request           (device2_read_request               ),
    .device2_read_response          (device2_read_response              ),
    .device2_write_data             (device2_write_data                 ),
    .device2_write_strobe           (device2_write_strobe               ),
    .device2_write_request          (device2_write_request              ),
    .device2_write_response         (device2_write_response             )

    // Device #3 <=> System Bus

    .device3_rw_address             (device3_rw_address                 ),
    .device3_read_data              (device3_read_data                  ),
    .device3_read_request           (device3_read_request               ),
    .device3_read_response          (device3_read_response              ),
    .device3_write_data             (device3_write_data                 ),
    .device3_write_strobe           (device3_write_strobe               ),
    .device3_write_request          (device3_write_request              ),
    .device3_write_response         (device3_write_response             )

    */

  );
  
  ram_memory #(
  
    .MEMORY_SIZE                    (MEMORY_SIZE                        ),
    .MEMORY_INIT_FILE               (MEMORY_INIT_FILE                   )
  
  ) ram_instance (
  
    // Global clock and active-high reset
  
    .clock                          (clock                              ),
    .reset                          (reset                              ),
    
    // IO interface
  
    .rw_address                     (device0_rw_address                 ),
    .read_data                      (device0_read_data                  ),
    .read_request                   (device0_read_request               ),
    .read_response                  (device0_read_response              ),
    .write_data                     (device0_write_data                 ),
    .write_strobe                   (device0_write_strobe               ),
    .write_request                  (device0_write_request              ),
    .write_response                 (device0_write_response             )

  );

  uart #(

    .CLOCK_FREQUENCY                (CLOCK_FREQUENCY                    ),
    .UART_BAUD_RATE                 (UART_BAUD_RATE                     )

  ) uart_instance (

    // Global clock and active-high reset

    .clock                          (clock                              ),
    .reset                          (reset                              ),

    // IO interface

    .rw_address                     (device1_rw_address                 ),
    .read_data                      (device1_read_data                  ),
    .read_request                   (device1_read_request               ),
    .read_response                  (device1_read_response              ),
    .write_data                     (device1_write_data[7:0]            ),
    .write_request                  (device1_write_request              ),
    .write_response                 (device1_write_response             ),

    // RX/TX signals

    .uart_tx                        (uart_tx                            ),
    .uart_rx                        (uart_rx                            ),

    // Interrupt signaling

    .uart_irq                       (irq_external                       ),
    .uart_irq_response              (irq_external_response              )

  );

  /* Uncomment to add new devices

  mydevice2
  mydevice2_instance (

    ... device 2 signals ...

    .mydevice2_rw_address           (device2_rw_address                 ),
    .mydevice2_read_data            (device2_read_data                  ),
    .mydevice2_read_request         (device2_read_request               ),
    .mydevice2_read_response        (device2_read_response              ),
    .mydevice2_write_data           (device2_write_data                 ),
    .mydevice2_write_request        (device2_write_request              ),
    .mydevice2_write_response       (device2_write_response             )

  );

  mydevice3
  mydevice3_instance (

    ... device 3 signals ...

    .mydevice3_rw_address           (device3_rw_address                 ),
    .mydevice3_read_data            (device3_read_data                  ),
    .mydevice3_read_request         (device3_read_request               ),
    .mydevice3_read_response        (device3_read_response              ),
    .mydevice3_write_data           (device3_write_data                 ),
    .mydevice3_write_request        (device3_write_request              ),
    .mydevice3_write_response       (device3_write_response             )

  );

  */

endmodule
