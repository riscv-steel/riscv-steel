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

Project Name:  RISC-V Steel System-on-Chip - Random Access Memory
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

  // Global signals

  input   wire          clock,
  input   wire          reset,

  // IO interface

  input  wire   [31:0]  rw_address,
  output reg    [31:0]  read_data,
  input  wire           read_request,
  output reg            read_response,
  input  wire   [31:0]  write_data,
  input  wire   [3:0 ]  write_strobe,
  input  wire           write_request,
  output reg            write_response

  );

  wire                        reset_internal;
  wire [31:0]                 effective_address;
  wire                        invalid_address;

  reg                         reset_reg;
  reg [31:0]                  ram [0:(MEMORY_SIZE/4)-1];

  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;
  assign invalid_address = $unsigned(rw_address) >= $unsigned(MEMORY_SIZE);

  integer i;
  initial begin
    for (i = 0; i < MEMORY_SIZE/4; i = i + 1) ram[i] = 32'h00000000;
    if (MEMORY_INIT_FILE != "")
      $readmemh(MEMORY_INIT_FILE,ram);
  end

  assign effective_address =
    $unsigned(rw_address[31:0] >> 2);

  always @(posedge clock) begin
    if (reset_internal | invalid_address)
      read_data <= 32'h00000000;
    else
      read_data <= ram[effective_address];
  end

  always @(posedge clock) begin
    if(write_request) begin
      if(write_strobe[0])
        ram[effective_address][7:0  ] <= write_data[7:0  ];
      if(write_strobe[1])
        ram[effective_address][15:8 ] <= write_data[15:8 ];
      if(write_strobe[2])
        ram[effective_address][23:16] <= write_data[23:16];
      if(write_strobe[3])
        ram[effective_address][31:24] <= write_data[31:24];
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end

endmodule