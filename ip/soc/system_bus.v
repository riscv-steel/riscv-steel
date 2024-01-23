/**************************************************************************************************

MIT License

Copyright (c) 2024 Alexander Markov

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
Author:        Alexander Markov - github.com/AlexxMarkov

Top Module:    system_bus

**************************************************************************************************/

module system_bus #(

  parameter NUM_DEVICES               = 1

  )(

  // Global signals

  input   wire                        clock                 ,
  input   wire                        reset                 ,

  // Interface with the manager device (Processor Core IP)

  input   wire  [31:0]                manager_rw_address    ,
  output  reg   [31:0]                manager_read_data     ,
  input   wire                        manager_read_request  ,
  output  reg                         manager_read_response ,
  input   wire  [31:0]                manager_write_data    ,
  input   wire  [3:0 ]                manager_write_strobe  ,
  input   wire                        manager_write_request ,
  output  reg                         manager_write_response,

  // Interface with the managed devices

  output  wire  [31:0]                device_rw_address     ,
  input   wire  [NUM_DEVICES*32-1:0]  device_read_data      ,
  output  wire  [NUM_DEVICES-1:0]     device_read_request   ,
  input   wire  [NUM_DEVICES-1:0]     device_read_response  ,
  output  wire  [31:0]                device_write_data     ,
  output  wire  [3:0 ]                device_write_strobe   ,
  output  wire  [NUM_DEVICES-1:0]     device_write_request  ,
  input   wire  [NUM_DEVICES-1:0]     device_write_response ,

  // Base addresses and masks of the managed devices

  input   wire  [NUM_DEVICES*32-1:0]  device_start_address  ,
  input   wire  [NUM_DEVICES*32-1:0]  device_region_size

  );

  integer i;

  reg [NUM_DEVICES*32-1:0]      device_mask_address;
  reg [NUM_DEVICES-1:0]         device_sel;
  reg [NUM_DEVICES-1:0]         device_sel_save;
  reg                           device_valid_access;

  // Manager request

  assign device_rw_address      = manager_rw_address;
  assign device_read_request    = device_sel & {NUM_DEVICES{manager_read_request}};
  assign device_write_data      = manager_write_data;
  assign device_write_strobe    = manager_write_strobe;
  assign device_write_request   = device_sel & {NUM_DEVICES{manager_write_request}};

  // Device response selection

  always @(*) begin
    for (i = 0; i < NUM_DEVICES; i = i + 1) begin
      device_mask_address[i*32 +:32] = ~(device_region_size[i*32 +:32] - 1);
      if ((manager_rw_address & device_mask_address[i*32 +:32]) == device_start_address[i*32 +:32])
        device_sel[i] = 1'b1;
      else
        device_sel[i] = 1'b0;
    end
  end

  always @(posedge clock) begin
    if (reset)
      device_sel_save <= {NUM_DEVICES{1'b0}};
    else if ((manager_read_request || manager_write_request) && (|device_sel))
      device_sel_save <= device_sel;
    else
      device_sel_save <= {NUM_DEVICES{1'b0}};    
  end

  always @(*) begin
    manager_read_data           = 32'b0;
    manager_read_response       = 1'b1;
    manager_write_response      = 1'b1;
    for (i = 0; i < NUM_DEVICES; i = i + 1) begin
      if (device_sel_save[i]) begin
        manager_read_data       = device_read_data[i*32 +: 32];
        manager_read_response   = device_read_response[i];
        manager_write_response  = device_write_response[i];
      end
    end
  end

endmodule
