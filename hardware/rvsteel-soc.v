/**************************************************************************************************

MIT License

Copyright (c) RISC-V Steel Project

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

Project Name:  RISC-V Steel SoC
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
  wire          irq_external_ack;

  // RISC-V Steel 32-bit Processor <=> Crossbar Manager #0

  wire  [31:0]  m0_mem_address;
  wire  [31:0]  m0_mem_read_data;
  wire          m0_mem_read_request;
  wire          m0_mem_read_request_ack;
  wire  [31:0]  m0_mem_write_data;
  wire  [3:0 ]  m0_mem_write_strobe;
  wire          m0_mem_write_request;
  wire          m0_mem_write_request_ack;
  
  // Programmable Memory <=> Crossbar Subordinate #0

  wire  [31:0]  s0_mem_address;
  wire  [31:0]  s0_mem_read_data;
  wire          s0_mem_read_request;
  wire          s0_mem_read_request_ack;
  wire  [31:0]  s0_mem_write_data;
  wire  [3:0 ]  s0_mem_write_strobe;
  wire          s0_mem_write_request;
  wire          s0_mem_write_request_ack;
  
  // UART <=> Crossbar Subordinate #1

  wire  [31:0]  s1_mem_address;
  wire  [31:0]  s1_mem_read_data;
  wire          s1_mem_read_request;
  wire          s1_mem_read_request_ack;
  wire  [31:0]  s1_mem_write_data;
  wire  [3:0 ]  s1_mem_write_strobe;
  wire          s1_mem_write_request;
  wire          s1_mem_write_request_ack;

  rvsteel_core #(

    .BOOT_ADDRESS                 (BOOT_ADDRESS                       )

  ) rvsteel_core_instance (

    // Global clock and active-high reset

    .clock                        (clock                              ),
    .reset                        (reset                              ),

    // Memory Interface

    .mem_address                  (m0_mem_address                     ),
    .mem_read_data                (m0_mem_read_data                   ),
    .mem_read_request             (m0_mem_read_request                ),
    .mem_read_request_ack         (m0_mem_read_request_ack            ),
    .mem_write_data               (m0_mem_write_data                  ),
    .mem_write_strobe             (m0_mem_write_strobe                ),
    .mem_write_request            (m0_mem_write_request               ),
    .mem_write_request_ack        (m0_mem_write_request_ack           ),

    // Interrupt signals (hardwire inputs to zero if unused)

    .irq_external                 (irq_external                       ),
    .irq_external_ack             (irq_external_ack                   ),
    .irq_timer                    (0), // unused
    .irq_timer_ack                (),  // unused
    .irq_software                 (0), // unused
    .irq_software_ack             (),  // unused

    // Real Time Clock (hardwire to zero if unused)

    .real_time_clock              (0)  // unused

  );
  
  bus_mux
  bus_mux_instance (
  
    .clock                        (clock                              ),
    .reset                        (reset                              ),

    // RISC-V Steel 32-bit Processor <=> Crossbar Manager #0

    .m0_mem_address               (m0_mem_address                     ),
    .m0_mem_read_data             (m0_mem_read_data                   ),
    .m0_mem_read_request          (m0_mem_read_request                ),
    .m0_mem_read_request_ack      (m0_mem_read_request_ack            ),
    .m0_mem_write_data            (m0_mem_write_data                  ),
    .m0_mem_write_strobe          (m0_mem_write_strobe                ),
    .m0_mem_write_request         (m0_mem_write_request               ),
    .m0_mem_write_request_ack     (m0_mem_write_request_ack           ),
    
    // Programmable Memory <=> Crossbar Subordinate #0

    .s0_mem_address               (s0_mem_address                     ),
    .s0_mem_read_data             (s0_mem_read_data                   ),
    .s0_mem_read_request          (s0_mem_read_request                ),
    .s0_mem_read_request_ack      (s0_mem_read_request_ack            ),
    .s0_mem_write_data            (s0_mem_write_data                  ),
    .s0_mem_write_strobe          (s0_mem_write_strobe                ),
    .s0_mem_write_request         (s0_mem_write_request               ),
    .s0_mem_write_request_ack     (s0_mem_write_request_ack           ),
    
    // UART <=> Crossbar Subordinate #1

    .s1_mem_address               (s1_mem_address                     ),
    .s1_mem_read_data             (s1_mem_read_data                   ),
    .s1_mem_read_request          (s1_mem_read_request                ),
    .s1_mem_read_request_ack      (s1_mem_read_request_ack            ),
    .s1_mem_write_data            (s1_mem_write_data                  ),
    .s1_mem_write_strobe          (s1_mem_write_strobe                ),
    .s1_mem_write_request         (s1_mem_write_request               ),
    .s1_mem_write_request_ack     (s1_mem_write_request_ack           )

  );
  
  ram #(
  
    .MEMORY_SIZE                  (MEMORY_SIZE                        ),
    .MEMORY_INIT_FILE             (MEMORY_INIT_FILE                   )
  
  ) ram_instance (
  
    // Global clock and active-high reset
  
    .clock                        (clock                              ),
    .reset                        (reset                              ),
    
    // Memory Interface
  
    .mem_address                  (s0_mem_address                     ),
    .mem_read_data                (s0_mem_read_data                   ),
    .mem_read_request             (s0_mem_read_request                ),
    .mem_read_request_ack         (s0_mem_read_request_ack            ),
    .mem_write_data               (s0_mem_write_data                  ),
    .mem_write_strobe             (s0_mem_write_strobe                ),
    .mem_write_request            (s0_mem_write_request               ),
    .mem_write_request_ack        (s0_mem_write_request_ack           )

  );

  uart #(

    .CLOCK_FREQUENCY              (CLOCK_FREQUENCY                    ),
    .UART_BAUD_RATE               (UART_BAUD_RATE                     )

  ) uart_instance (

    // Global clock and active-high reset

    .clock                        (clock                              ),
    .reset                        (reset                              ),

    // Memory Interface

    .mem_address                  (s1_mem_address                     ),
    .mem_read_data                (s1_mem_read_data                   ),
    .mem_read_request             (s1_mem_read_request                ),
    .mem_read_request_ack         (s1_mem_read_request_ack            ),
    .mem_write_data               (s1_mem_write_data[7:0]             ),
    .mem_write_request            (s1_mem_write_request               ),
    .mem_write_request_ack        (s1_mem_write_request_ack           ),

    // RX/TX signals

    .uart_tx                      (uart_tx                            ),
    .uart_rx                      (uart_rx                            ),

    // Interrupt signaling

    .uart_irq                     (irq_external                       ),
    .uart_irq_ack                 (irq_external_ack                   )

  );

endmodule
