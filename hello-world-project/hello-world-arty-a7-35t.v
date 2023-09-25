/**************************************************************************************************

MIT License

Copyright (c) RISC-V Steel

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

Project Name:  RISC-V Steel Core / Hello World example
Project Repo:  github.com/riscv-steel/riscv-steel-core
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    hello_world_arty_a7_35t
 
**************************************************************************************************/

/**************************************************************************************************

Remarks:

  - 'clock' is connected to Arty's 100MHz board clock. Internally this clock is divided by 2.
  - 'reset' is connected to BTN0 on the board
  - UART signals are connect to Arty's UART-USB bridge

**************************************************************************************************/
module hello_world_arty_a7_35t (

  input   wire clock,
  input   wire reset,
  input   wire uart_rx,
  output  wire uart_tx

  );
  
  reg         internal_clock;
  wire        irq_external;
  wire        irq_external_ack;

  // RISC-V Steel <=> AXI4 Lite Crossbar

  wire          m_axil_awready;
  wire          m_axil_awvalid;
  wire  [31:0]  m_axil_awaddr;
  wire  [2:0 ]  m_axil_awprot;
  wire          m_axil_arready;
  wire          m_axil_arvalid;
  wire  [31:0]  m_axil_araddr;
  wire  [2:0 ]  m_axil_arprot;
  wire          m_axil_wready;
  wire          m_axil_wvalid;
  wire  [31:0]  m_axil_wdata;
  wire  [3:0 ]  m_axil_wstrb;
  wire          m_axil_bready;
  wire          m_axil_bvalid;
  wire  [1:0]   m_axil_bresp;
  wire          m_axil_rready;
  wire          m_axil_rvalid;
  wire  [31:0]  m_axil_rdata;
  wire  [1:0 ]  m_axil_rresp;
  
  // RAM Memory <=> AXI4 Lite Crossbar

  wire          s0_axil_awready;
  wire          s0_axil_awvalid;
  wire  [31:0]  s0_axil_awaddr;
  wire  [2:0 ]  s0_axil_awprot;
  wire          s0_axil_arready;
  wire          s0_axil_arvalid;
  wire  [31:0]  s0_axil_araddr;
  wire  [2:0 ]  s0_axil_arprot;
  wire          s0_axil_wready;
  wire          s0_axil_wvalid;
  wire  [31:0]  s0_axil_wdata;
  wire  [3:0 ]  s0_axil_wstrb;
  wire          s0_axil_bready;
  wire          s0_axil_bvalid;
  wire  [1:0]   s0_axil_bresp;
  wire          s0_axil_rready;
  wire          s0_axil_rvalid;
  wire  [31:0]  s0_axil_rdata;
  wire  [1:0 ]  s0_axil_rresp;
  
  // UART <=> AXI4 Lite Crossbar

  wire          s1_axil_awready;
  wire          s1_axil_awvalid;
  wire  [31:0]  s1_axil_awaddr;
  wire  [2:0 ]  s1_axil_awprot;
  wire          s1_axil_arready;
  wire          s1_axil_arvalid;
  wire  [31:0]  s1_axil_araddr;
  wire  [2:0 ]  s1_axil_arprot;
  wire          s1_axil_wready;
  wire          s1_axil_wvalid;
  wire  [31:0]  s1_axil_wdata;
  wire  [3:0 ]  s1_axil_wstrb;
  wire          s1_axil_bready;
  wire          s1_axil_bvalid;
  wire  [1:0]   s1_axil_bresp;
  wire          s1_axil_rready;
  wire          s1_axil_rvalid;
  wire  [31:0]  s1_axil_rdata;
  wire  [1:0 ]  s1_axil_rresp;

  // Generate a 50MHz clock signal from Arty's onboard 100MHz clock
  initial internal_clock = 1'b0;
  always @(posedge clock)
    internal_clock <= !internal_clock;

  riscv_steel_core
  riscv_steel_core_instance (

    // Global clock and active-low reset

    .clock                        (internal_clock                     ),
    .reset_n                      (!reset                             ),

    // AXI4 Lite Master Interface

    .m_axil_arready               (m_axil_arready                     ),
    .m_axil_arvalid               (m_axil_arvalid                     ),
    .m_axil_araddr                (m_axil_araddr                      ),
    .m_axil_arprot                (m_axil_arprot                      ),
    .m_axil_rready                (m_axil_rready                      ),
    .m_axil_rvalid                (m_axil_rvalid                      ),
    .m_axil_rdata                 (m_axil_rdata                       ),
    .m_axil_rresp                 (m_axil_rresp                       ),
    .m_axil_awready               (m_axil_awready                     ),
    .m_axil_awvalid               (m_axil_awvalid                     ),
    .m_axil_awaddr                (m_axil_awaddr                      ),
    .m_axil_awprot                (m_axil_awprot                      ),
    .m_axil_wready                (m_axil_wready                      ),
    .m_axil_wvalid                (m_axil_wvalid                      ),
    .m_axil_wdata                 (m_axil_wdata                       ),
    .m_axil_wstrb                 (m_axil_wstrb                       ),
    .m_axil_bready                (m_axil_bready                      ),
    .m_axil_bvalid                (m_axil_bvalid                      ),
    .m_axil_bresp                 (m_axil_bresp                       ),

    // Interrupt signals (hardwire inputs to zero if unused)

    .irq_external                 (irq_external                       ),
    .irq_external_ack             (irq_external_ack                   ),
    .irq_timer                    (0), // unused
    .irq_timer_ack                (),  // unused
    .irq_software                 (0), // unused
    .irq_software_ack             (),  // unused

    // Real Time Counter (hardwire to zero if unused)

    .real_time_counter            (0)  // unused

  );
  
  crossbar_axi4_lite
  crossbar_axi4_lite_instance (
  
    .clock                        (internal_clock                     ),
    .reset_n                      (!reset                             ),

    // RISC-V Steel <=> AXI4 Lite Crossbar

    .m_axil_arready               (m_axil_arready                     ),
    .m_axil_arvalid               (m_axil_arvalid                     ),
    .m_axil_araddr                (m_axil_araddr                      ),
    .m_axil_arprot                (m_axil_arprot                      ),
    .m_axil_rready                (m_axil_rready                      ),
    .m_axil_rvalid                (m_axil_rvalid                      ),
    .m_axil_rdata                 (m_axil_rdata                       ),
    .m_axil_rresp                 (m_axil_rresp                       ),
    .m_axil_awready               (m_axil_awready                     ),
    .m_axil_awvalid               (m_axil_awvalid                     ),
    .m_axil_awaddr                (m_axil_awaddr                      ),
    .m_axil_awprot                (m_axil_awprot                      ),
    .m_axil_wready                (m_axil_wready                      ),
    .m_axil_wvalid                (m_axil_wvalid                      ),
    .m_axil_wdata                 (m_axil_wdata                       ),
    .m_axil_wstrb                 (m_axil_wstrb                       ),
    .m_axil_bready                (m_axil_bready                      ),
    .m_axil_bvalid                (m_axil_bvalid                      ),
    .m_axil_bresp                 (m_axil_bresp                       ),
    
    // RAM Memory <=> AXI4 Lite Crossbar

    .s0_axil_arready               (s0_axil_arready                    ),
    .s0_axil_arvalid               (s0_axil_arvalid                    ),
    .s0_axil_araddr                (s0_axil_araddr                     ),
    .s0_axil_arprot                (s0_axil_arprot                     ),
    .s0_axil_awready               (s0_axil_awready                    ),
    .s0_axil_rvalid                (s0_axil_rvalid                     ),
    .s0_axil_rdata                 (s0_axil_rdata                      ),
    .s0_axil_rresp                 (s0_axil_rresp                      ),
    .s0_axil_awvalid               (s0_axil_awvalid                    ),
    .s0_axil_awaddr                (s0_axil_awaddr                     ),
    .s0_axil_awprot                (s0_axil_awprot                     ),
    .s0_axil_wready                (s0_axil_wready                     ),
    .s0_axil_wvalid                (s0_axil_wvalid                     ),
    .s0_axil_wdata                 (s0_axil_wdata                      ),
    .s0_axil_wstrb                 (s0_axil_wstrb                      ),
    .s0_axil_bready                (s0_axil_bready                     ),
    .s0_axil_bvalid                (s0_axil_bvalid                     ),
    .s0_axil_bresp                 (s0_axil_bresp                      ),
    .s0_axil_rready                (s0_axil_rready                     ),
    
    // UART <=> AXI4 Lite Crossbar

    .s1_axil_arready               (s1_axil_arready                    ),
    .s1_axil_arvalid               (s1_axil_arvalid                    ),
    .s1_axil_araddr                (s1_axil_araddr                     ),
    .s1_axil_arprot                (s1_axil_arprot                     ),
    .s1_axil_awready               (s1_axil_awready                    ),
    .s1_axil_rvalid                (s1_axil_rvalid                     ),
    .s1_axil_rdata                 (s1_axil_rdata                      ),
    .s1_axil_rresp                 (s1_axil_rresp                      ),
    .s1_axil_awvalid               (s1_axil_awvalid                    ),
    .s1_axil_awaddr                (s1_axil_awaddr                     ),
    .s1_axil_awprot                (s1_axil_awprot                     ),
    .s1_axil_wready                (s1_axil_wready                     ),
    .s1_axil_wvalid                (s1_axil_wvalid                     ),
    .s1_axil_wdata                 (s1_axil_wdata                      ),
    .s1_axil_wstrb                 (s1_axil_wstrb                      ),
    .s1_axil_bready                (s1_axil_bready                     ),
    .s1_axil_bvalid                (s1_axil_bvalid                     ),
    .s1_axil_bresp                 (s1_axil_bresp                      ),
    .s1_axil_rready                (s1_axil_rready                     )

  );
  
  ram_memory_axi4_lite #(
  
    .MEMORY_SIZE(8192),
    .MEMORY_INIT_FILE("hello-world.mem")
  
  ) ram_memory_axi4_lite_instance (
  
    // Global clock and active-low reset
  
    .clock                        (internal_clock                     ),
    .reset_n                      (!reset                             ),
    
    // AXI4-Lite Slave Interface
  
    .s_axil_arready               (s0_axil_arready                    ),
    .s_axil_arvalid               (s0_axil_arvalid                    ),
    .s_axil_araddr                (s0_axil_araddr                     ),
    .s_axil_arprot                (s0_axil_arprot                     ),
    .s_axil_awready               (s0_axil_awready                    ),
    .s_axil_rvalid                (s0_axil_rvalid                     ),
    .s_axil_rdata                 (s0_axil_rdata                      ),
    .s_axil_rresp                 (s0_axil_rresp                      ),
    .s_axil_awvalid               (s0_axil_awvalid                    ),
    .s_axil_awaddr                (s0_axil_awaddr                     ),
    .s_axil_awprot                (s0_axil_awprot                     ),
    .s_axil_wready                (s0_axil_wready                     ),
    .s_axil_wvalid                (s0_axil_wvalid                     ),
    .s_axil_wdata                 (s0_axil_wdata                      ),
    .s_axil_wstrb                 (s0_axil_wstrb                      ),
    .s_axil_bready                (s0_axil_bready                     ),
    .s_axil_bvalid                (s0_axil_bvalid                     ),
    .s_axil_bresp                 (s0_axil_bresp                      ),
    .s_axil_rready                (s0_axil_rready                     )

  );

  uart_axi4_lite
  uart_axi4_lite_instance (

    // Global clock and active-low reset

    .clock                        (internal_clock                     ),
    .reset_n                      (!reset                             ),

    // AXI4-Lite Slave Interface

    .s_axil_arready               (s1_axil_arready                    ),
    .s_axil_arvalid               (s1_axil_arvalid                    ),
    .s_axil_araddr                (s1_axil_araddr                     ),
    .s_axil_awready               (s1_axil_awready                    ),
    .s_axil_rvalid                (s1_axil_rvalid                     ),
    .s_axil_rdata                 (s1_axil_rdata                      ),
    .s_axil_rresp                 (s1_axil_rresp                      ),
    .s_axil_wready                (s1_axil_wready                     ),
    .s_axil_wvalid                (s1_axil_wvalid                     ),
    .s_axil_wdata                 (s1_axil_wdata[7:0]                 ),
    .s_axil_bvalid                (s1_axil_bvalid                     ),
    .s_axil_bresp                 (s1_axil_bresp                      ),

    // RX/TX signals

    .uart_tx                      (uart_tx                            ),
    .uart_rx                      (uart_rx                            ),

    // Interrupt signaling

    .uart_irq                     (irq_external                       ),
    .uart_irq_ack                 (irq_external_ack                   )

  );

endmodule
