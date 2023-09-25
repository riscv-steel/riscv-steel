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

Project Name:  RISC-V Steel Core
Project Repo:  github.com/riscv-steel/riscv-steel-core
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    crossbar_axi4_lite
 
**************************************************************************************************/

/**************************************************************************************************

Remarks:

  - This is a 1 manager x 2 subordinates AXI4 Lite Crossbar for the Hello World project
  - Subordinate 0 is assigned the address ranges 0x00000000 - 0x0000ffff, 0x00020000 - 0xffffffff
  - Subordinate 1 is assigned the address range  0x00010000 - 0x0001ffff

**************************************************************************************************/
module crossbar_axi4_lite (

  input   wire       clock,
  input   wire       reset_n,

  // Connected to Master => RISC-V Steel Core

  output  wire          m_axil_arready,
  input   wire          m_axil_arvalid,
  input   wire  [31:0]  m_axil_araddr,
  input   wire  [2:0 ]  m_axil_arprot,
  input   wire          m_axil_rready,
  output  reg           m_axil_rvalid,
  output  reg   [31:0]  m_axil_rdata,
  output  reg   [1:0 ]  m_axil_rresp,
  output  wire          m_axil_awready,
  input   wire          m_axil_awvalid,
  input   wire  [31:0]  m_axil_awaddr,
  input   wire  [2:0 ]  m_axil_awprot,  
  output  wire          m_axil_wready,
  input   wire          m_axil_wvalid,
  input   wire  [31:0]  m_axil_wdata,
  input   wire  [3:0 ]  m_axil_wstrb,
  input   wire          m_axil_bready,
  output  reg           m_axil_bvalid,
  output  reg   [1:0]   m_axil_bresp,  
  
  // Connected to Slave 0 => RAM Memory

  input   wire          s0_axil_arready,
  output  wire          s0_axil_arvalid,
  output  wire  [31:0]  s0_axil_araddr,
  output  wire  [2:0 ]  s0_axil_arprot,
  output  wire          s0_axil_rready,
  input   wire          s0_axil_rvalid,
  input   wire  [31:0]  s0_axil_rdata,
  input   wire  [1:0 ]  s0_axil_rresp,
  input   wire          s0_axil_awready,
  output  wire          s0_axil_awvalid,
  output  wire  [31:0]  s0_axil_awaddr,
  output  wire  [2:0 ]  s0_axil_awprot,  
  input   wire          s0_axil_wready,
  output  wire          s0_axil_wvalid,
  output  wire  [31:0]  s0_axil_wdata,
  output  wire  [3:0 ]  s0_axil_wstrb,
  output  wire          s0_axil_bready,
  input   wire          s0_axil_bvalid,
  input   wire  [1:0]   s0_axil_bresp,  
  
  // Connected to Slave 1 => UART

  input   wire          s1_axil_arready,
  output  wire          s1_axil_arvalid,
  output  wire  [31:0]  s1_axil_araddr,
  output  wire  [2:0 ]  s1_axil_arprot,
  output  wire          s1_axil_rready,
  input   wire          s1_axil_rvalid,
  input   wire  [31:0]  s1_axil_rdata,
  input   wire  [1:0 ]  s1_axil_rresp,
  input   wire          s1_axil_awready,
  output  wire          s1_axil_awvalid,
  output  wire  [31:0]  s1_axil_awaddr,
  output  wire  [2:0 ]  s1_axil_awprot,  
  input   wire          s1_axil_wready,
  output  wire          s1_axil_wvalid,
  output  wire  [31:0]  s1_axil_wdata,
  output  wire  [3:0 ]  s1_axil_wstrb,
  output  wire          s1_axil_bready,
  input   wire          s1_axil_bvalid,
  input   wire  [1:0]   s1_axil_bresp

  );

  localparam    SEL_RESET   = 3'b001;
  localparam    SEL_SLAVE0  = 3'b010;
  localparam    SEL_SLAVE1  = 3'b100;  
  reg [2:0]     read_response_sel;
  reg [2:0]     write_response_sel;
  reg           reset_n_reg;
  wire          reset;

  always @(posedge clock)
    reset_n_reg <= reset_n;

  assign reset = !reset_n | !reset_n_reg;
  
  assign s0_axil_araddr = m_axil_araddr;
  assign s1_axil_araddr = m_axil_araddr;
  
  assign s0_axil_arprot = m_axil_arprot;
  assign s1_axil_arprot = m_axil_arprot;

  assign s0_axil_awaddr = m_axil_awaddr;
  assign s1_axil_awaddr = m_axil_awaddr;

  assign s0_axil_awprot = m_axil_awprot;
  assign s1_axil_awprot = m_axil_awprot;

  assign s0_axil_wdata  = m_axil_wdata;
  assign s1_axil_wdata  = m_axil_wdata;

  assign s0_axil_wstrb  = m_axil_wstrb;
  assign s1_axil_wstrb  = m_axil_wstrb;

  assign s0_axil_rready = m_axil_rready;
  assign s1_axil_rready = m_axil_rready;

  assign s0_axil_bready = m_axil_bready;
  assign s1_axil_bready = m_axil_bready;

  assign s0_axil_arvalid = m_axil_araddr[31] != 1'b1 ? m_axil_arvalid : 1'b0;
  assign s0_axil_awvalid = m_axil_araddr[31] != 1'b1 ? m_axil_awvalid : 1'b0;
  assign s0_axil_wvalid  = m_axil_araddr[31] != 1'b1 ? m_axil_wvalid  : 1'b0;

  assign s1_axil_arvalid = m_axil_araddr[31] == 1'b1 ? m_axil_arvalid : 1'b0;
  assign s1_axil_awvalid = m_axil_araddr[31] == 1'b1 ? m_axil_awvalid : 1'b0;
  assign s1_axil_wvalid  = m_axil_araddr[31] == 1'b1 ? m_axil_wvalid  : 1'b0;

  // Slave Response selection
  
  assign m_axil_arready = m_axil_araddr[31] != 1'b1 ? s0_axil_arready : s1_axil_arready;
  assign m_axil_awready = m_axil_araddr[31] != 1'b1 ? s0_axil_awready : s1_axil_awready;
  assign m_axil_wready  = m_axil_araddr[31] != 1'b1 ? s0_axil_wready  : s1_axil_wready ;

  always @(posedge clock) begin
    if (reset)
      read_response_sel   <= SEL_RESET;
    else if (m_axil_arvalid == 1'b1 && m_axil_arready == 1'b1) begin
      if (m_axil_araddr[31] != 1'b1)
        read_response_sel   <= SEL_SLAVE0;
      else
        read_response_sel   <= SEL_SLAVE1;
    end
    if (reset)
      write_response_sel  <= SEL_RESET;
    else if (m_axil_awvalid == 1'b1 && m_axil_awready == 1'b1) begin
      if (m_axil_araddr[31] != 1'b1)
        write_response_sel  <= SEL_SLAVE0;
      else
        write_response_sel  <= SEL_SLAVE1;
    end
  end

  // Read Channel Response

  always @* begin
    case (read_response_sel)
      SEL_RESET: begin
        m_axil_rvalid   <= 1'b0;
        m_axil_rdata    <= 32'h00000000;
        m_axil_rresp    <= 2'b11;
      end
      SEL_SLAVE0: begin
        m_axil_rvalid   <= s0_axil_rvalid;
        m_axil_rdata    <= s0_axil_rdata;
        m_axil_rresp    <= s0_axil_rresp;
      end
      SEL_SLAVE1: begin
        m_axil_rvalid   <= s1_axil_rvalid;
        m_axil_rdata    <= s1_axil_rdata;
        m_axil_rresp    <= s1_axil_rresp;
      end
      default: begin
        m_axil_rvalid   <= 1'b0;
        m_axil_rdata    <= 32'h00000000;
        m_axil_rresp    <= 2'b11;
      end
    endcase
  end

  // Write Channel Response

  always @* begin
    case (write_response_sel)
      SEL_RESET: begin
        m_axil_bvalid   <= 1'b0;
        m_axil_bresp    <= 2'b11;
      end
      SEL_SLAVE0: begin
        m_axil_bvalid   <= s0_axil_bvalid;
        m_axil_bresp    <= s0_axil_bresp;
      end
      SEL_SLAVE1: begin
        m_axil_bvalid   <= s1_axil_bvalid;
        m_axil_bresp    <= s1_axil_bresp;
      end
      default: begin
        m_axil_bvalid   <= 1'b0;
        m_axil_bresp    <= 2'b11;
      end
    endcase
  end

endmodule