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

Project Name:  RISC-V Steel
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    ram
 
**************************************************************************************************/

/**************************************************************************************************

Remarks:

  - This memory is word-addressed - the two least significant bits of the address are ignored
  - Data width is 32 bits
  - Address width is also 32 bits, regardless the memory size
  - Base memory address is 0x0
  - Highest memory address is 0x(MEMORY_SIZE-1)
  - Addresses are not checked if they are within the allowed range - they are assumed
    to be within the allowed range

**************************************************************************************************/
module ram #(

  // Memory size in bytes - must be a multiple of 32
  parameter MEMORY_SIZE      = 8192,
  
  // Value to fill every memory position
  parameter FILL_MEMORY_WITH = 32'hdeadbeef,
  
  // Init .mem file (for use with AMD Vivado)
  parameter MEMORY_INIT_FILE = ""

  ) (
  
  // Global clock and active-low reset

  input   wire          clock,
  input   wire          reset_n,

  // AXI4-Lite Slave Interface

  output  reg           s_axil_arready,
  input   wire          s_axil_arvalid,
  input   wire  [31:0]  s_axil_araddr,
  input   wire  [2:0 ]  s_axil_arprot,
  input   wire          s_axil_rready,
  output  reg           s_axil_rvalid,
  output  reg   [31:0]  s_axil_rdata,
  output  reg   [1:0 ]  s_axil_rresp,
  output  reg           s_axil_awready,
  input   wire          s_axil_awvalid,
  input   wire  [31:0]  s_axil_awaddr,
  input   wire  [2:0 ]  s_axil_awprot,  
  output  reg           s_axil_wready,
  input   wire          s_axil_wvalid,
  input   wire  [31:0]  s_axil_wdata,
  input   wire  [3:0 ]  s_axil_wstrb,
  input   wire          s_axil_bready,
  output  reg           s_axil_bvalid,
  output  reg   [1:0]   s_axil_bresp  

  );

  //-----------------------------------------------------------------------------------------------//
  // Wires and regs                                                                                //
  //-----------------------------------------------------------------------------------------------//

  localparam    ADDR_BUS_WIDTH            = $clog2(MEMORY_SIZE)-1;

  // AXI4 Lite Read Channel state machine
  localparam    AXIL_READ_RESET           = 3'b001;
  localparam    AXIL_READ_WAIT_ARVALID    = 3'b010;
  localparam    AXIL_READ_WAIT_RREADY     = 3'b100;
  reg [2:0]     axil_read_curr_state;
  reg [2:0]     axil_read_next_state;
  
  // AXI4 Lite Write Channel state machine
  localparam    AXIL_WRITE_RESET          = 4'b0001;
  localparam    AXIL_WRITE_WAIT_AWVALID   = 4'b0010;
  localparam    AXIL_WRITE_WAIT_WVALID    = 4'b0100;
  localparam    AXIL_WRITE_WAIT_BREADY    = 4'b1000;
  reg [3:0]     axil_write_curr_state;
  reg [3:0]     axil_write_next_state;
  
  // Reset
  reg           reset_n_reg;
  wire          reset;

  // Registers
  reg [31:0]                ram [0:MEMORY_SIZE/4];
  reg [ADDR_BUS_WIDTH:0]    prev_read_address;  
  reg [ADDR_BUS_WIDTH:0]    saved_write_address;

  // Wires
  wire [ADDR_BUS_WIDTH:0]   read_address;
  wire [ADDR_BUS_WIDTH:0]   write_address;
  wire                      write_enable;
  

  //---------------------------------------------------------------------------------------------//
  // RAM initialization and reset logic                                                          //
  //---------------------------------------------------------------------------------------------//

  integer i;  
  initial begin
    for (i = 0; i < MEMORY_SIZE/4; i = i + 1) ram[i] = FILL_MEMORY_WITH;
    if (MEMORY_INIT_FILE != "")      
      $readmemh(MEMORY_INIT_FILE,ram);
  end

  always @(posedge clock)
    reset_n_reg <= reset_n;

  assign reset = !reset_n | !reset_n_reg;
  
  //---------------------------------------------------------------------------------------------//
  // RAM read address logic                                                                      //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock)
    if (reset)
      prev_read_address <= 32'h00000000;
    else if (s_axil_arready & s_axil_arvalid & (s_axil_arprot == 3'b000 | s_axil_arprot == 3'b100))
      prev_read_address <= read_address;
   
  assign read_address =
    s_axil_arready & s_axil_arvalid ?
    $unsigned(s_axil_araddr[31:0] >> 2) :
    prev_read_address;
  
  //---------------------------------------------------------------------------------------------//
  // RAM output registers                                                                        //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock)
    if (reset)
      s_axil_rdata <= 32'h00000000;
    else
      s_axil_rdata <= ram[read_address];

  //---------------------------------------------------------------------------------------------//
  // AXI4 Lite Read Channel                                                                      //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if (!reset_n)
      axil_read_curr_state <= AXIL_READ_RESET;
    else
      axil_read_curr_state <= axil_read_next_state;
  end
  
  always @* begin
    case (axil_read_curr_state)
      AXIL_READ_RESET: begin
        s_axil_arready        = 1'b0;
        s_axil_rvalid         = 1'b0;
        s_axil_rresp          = 2'b11;
        axil_read_next_state  = AXIL_READ_WAIT_ARVALID;
      end
      AXIL_READ_WAIT_ARVALID: begin
        s_axil_arready        = 1'b1;
        s_axil_rvalid         = 1'b0;
        s_axil_rresp          = 2'b11;
        if (reset)
          axil_read_next_state = AXIL_READ_RESET;
        else if (s_axil_arvalid)
          axil_read_next_state = AXIL_READ_WAIT_RREADY;
        else
          axil_read_next_state = AXIL_READ_WAIT_ARVALID;
      end
      AXIL_READ_WAIT_RREADY: begin
        s_axil_arready       = s_axil_rready;
        s_axil_rvalid        = 1'b1;
        s_axil_rresp         = 2'b00;
        if (reset)
          axil_read_next_state = AXIL_READ_RESET;
        else if (!s_axil_rready)
          axil_read_next_state = AXIL_READ_WAIT_RREADY;
        else if (!s_axil_arvalid)
          axil_read_next_state = AXIL_READ_WAIT_ARVALID;
        else
          axil_read_next_state = AXIL_READ_WAIT_RREADY;
      end
      default: begin
        s_axil_arready        = 1'b0;
        s_axil_rvalid         = 1'b0;
        s_axil_rresp          = 2'b11;
        axil_read_next_state  = AXIL_READ_WAIT_ARVALID;
      end
    endcase
  end

  //---------------------------------------------------------------------------------------------//
  // AXI4 Lite Write Channel                                                                     //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if (reset)
      axil_write_curr_state <= AXIL_WRITE_RESET;
    else
      axil_write_curr_state <= axil_write_next_state;
  end
 
  always @* begin
    case (axil_write_curr_state)
      AXIL_WRITE_RESET: begin
        s_axil_awready       = 1'b0;
        s_axil_wready        = 1'b0;
        s_axil_bvalid        = 1'b0;
        s_axil_bresp         = 2'b11;
        axil_write_next_state    = AXIL_WRITE_WAIT_AWVALID;
      end
      AXIL_WRITE_WAIT_AWVALID: begin
        s_axil_awready       = 1'b1;
        s_axil_wready        = 1'b1;
        s_axil_bvalid        = 1'b0;
        s_axil_bresp         = 2'b11;
        if (reset)
          axil_write_next_state  = AXIL_WRITE_RESET;
        else if (s_axil_awvalid & s_axil_wvalid)
          axil_write_next_state  = AXIL_WRITE_WAIT_BREADY;
        else if (s_axil_awvalid & !s_axil_wvalid)
          axil_write_next_state  = AXIL_WRITE_WAIT_WVALID;
        else
          axil_write_next_state  = AXIL_WRITE_WAIT_AWVALID;
      end
      AXIL_WRITE_WAIT_WVALID: begin
        s_axil_awready       = 1'b0;
        s_axil_wready        = 1'b1;
        s_axil_bvalid        = 1'b0;
        s_axil_bresp         = 2'b11;
        if (reset)
          axil_write_next_state = AXIL_WRITE_RESET;
        else if (s_axil_wvalid)
          axil_write_next_state = AXIL_WRITE_WAIT_BREADY;
        else
          axil_write_next_state = AXIL_WRITE_WAIT_WVALID;
      end
      AXIL_WRITE_WAIT_BREADY: begin
        s_axil_awready       = 1'b1;
        s_axil_wready        = 1'b1;
        s_axil_bvalid        = 1'b1;
        s_axil_bresp         = 2'b00;
        if (reset)
          axil_write_next_state = AXIL_WRITE_RESET;
        else if (!s_axil_bready)
          axil_write_next_state  = AXIL_WRITE_WAIT_BREADY;
        else if (!s_axil_awvalid)
          axil_write_next_state = AXIL_WRITE_WAIT_AWVALID;
        else if (s_axil_awvalid & !s_axil_wvalid)
          axil_write_next_state = AXIL_WRITE_WAIT_WVALID;
        else
          axil_write_next_state = AXIL_WRITE_WAIT_BREADY;
      end
      default: begin
        s_axil_awready       = 1'b0;
        s_axil_wready        = 1'b0;
        s_axil_bvalid        = 1'b0;
        s_axil_bresp         = 2'b11;
        axil_write_next_state    = AXIL_WRITE_WAIT_AWVALID;
      end      
    endcase
  end
  
  always @(posedge clock)
    if (reset)
      saved_write_address <= 32'h00000000;
    else if (s_axil_awready & s_axil_awvalid & (s_axil_awprot == 3'b000 | s_axil_awprot == 3'b100))
      saved_write_address <= s_axil_awaddr;
  
  assign write_enable =
    ((axil_write_curr_state == AXIL_WRITE_WAIT_AWVALID) & s_axil_awvalid & s_axil_wvalid) |
    ((axil_write_curr_state == AXIL_WRITE_WAIT_WVALID ) & s_axil_wvalid) |
    ((axil_write_curr_state == AXIL_WRITE_WAIT_BREADY ) & s_axil_awvalid & s_axil_wvalid & s_axil_bready);
  
  assign write_address = (
    ((axil_write_curr_state == AXIL_WRITE_WAIT_AWVALID) & s_axil_awvalid & s_axil_wvalid) |
    ((axil_write_curr_state == AXIL_WRITE_WAIT_BREADY ) & s_axil_awvalid & s_axil_wvalid & s_axil_bready)) ?
    $unsigned(s_axil_awaddr[31:0] >> 2) :
    saved_write_address;

  always @(posedge clock) begin
    if(write_enable) begin
      if(s_axil_wstrb[0])
        ram[write_address][7:0  ] <= s_axil_wdata[7:0  ];
      if(s_axil_wstrb[1])
        ram[write_address][15:8 ] <= s_axil_wdata[15:8 ];
      if(s_axil_wstrb[2])
        ram[write_address][23:16] <= s_axil_wdata[23:16];
      if(s_axil_wstrb[3])
        ram[write_address][31:24] <= s_axil_wdata[31:24];
    end
  end
  
endmodule