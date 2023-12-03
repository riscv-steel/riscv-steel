/**************************************************************************************************

MIT License

Copyright (c) 2020 - present Rafael Calcada

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

Project Name:  RISC-V Steel SoC - Random Access Memory
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    ram_memory
 
**************************************************************************************************/

module ram_memory #(

  // Memory size in bytes
  parameter MEMORY_SIZE      = 8192,
  
  // File with program and data
  parameter MEMORY_INIT_FILE = ""

  ) (
  
  // Global clock and active-high reset

  input   wire          clock,
  input   wire          reset,

  // Memory Interface

  input  wire   [31:0]  mem_address,
  output reg    [31:0]  mem_read_data,
  input  wire           mem_read_request,
  output reg            mem_read_request_ack,
  input  wire   [31:0]  mem_write_data,
  input  wire   [3:0 ]  mem_write_strobe,
  input  wire           mem_write_request,
  output reg            mem_write_request_ack

  );

  //-----------------------------------------------------------------------------------------------//
  // Wires, regs and parameters                                                                    //
  //-----------------------------------------------------------------------------------------------//

  localparam ADDR_BUS_WIDTH = $clog2(MEMORY_SIZE)-1;

  wire                        reset_internal;
  wire [ADDR_BUS_WIDTH:0]     effective_address;
  wire                        invalid_address;
  
  reg                         reset_reg;
  reg [31:0]                  ram [0:(MEMORY_SIZE/4)-1];
  
  //---------------------------------------------------------------------------------------------//
  // Reset logic                                                                                 //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;

  //-----------------------------------------------------------------------------------------------//
  // Invalid address detection                                                                     //
  //-----------------------------------------------------------------------------------------------//

  assign invalid_address = $unsigned(mem_address) >= $unsigned(MEMORY_SIZE);

  //---------------------------------------------------------------------------------------------//
  // Memory initialization                                                                       //
  //---------------------------------------------------------------------------------------------//

  integer i;  
  initial begin
    for (i = 0; i < MEMORY_SIZE/4; i = i + 1) ram[i] = 32'h00000000;
    if (MEMORY_INIT_FILE != "")      
      $readmemh(MEMORY_INIT_FILE,ram);
  end

  //---------------------------------------------------------------------------------------------//
  // Address logic                                                                               //
  //---------------------------------------------------------------------------------------------//

  assign effective_address =
    $unsigned(mem_address[31:0] >> 2);

  //---------------------------------------------------------------------------------------------//
  // Memory read                                                                                 //
  //---------------------------------------------------------------------------------------------//
  
  always @(posedge clock) begin
    if (reset_internal | invalid_address)
      mem_read_data <= 32'h00000000;
    else
      mem_read_data <= ram[effective_address];
  end

  //---------------------------------------------------------------------------------------------//
  // Memory write                                                                                //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if(mem_write_request) begin
      if(mem_write_strobe[0])
        ram[effective_address][7:0  ] <= mem_write_data[7:0  ];
      if(mem_write_strobe[1])
        ram[effective_address][15:8 ] <= mem_write_data[15:8 ];
      if(mem_write_strobe[2])
        ram[effective_address][23:16] <= mem_write_data[23:16];
      if(mem_write_strobe[3])
        ram[effective_address][31:24] <= mem_write_data[31:24];
    end
  end

  //---------------------------------------------------------------------------------------------//
  // Acknowledgement                                                                             //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if (reset_internal) begin
      mem_read_request_ack  <= 1'b0;
      mem_write_request_ack <= 1'b0;
    end
    else begin
      mem_read_request_ack  <= mem_read_request;
      mem_write_request_ack <= mem_write_request;
    end
  end
  
endmodule