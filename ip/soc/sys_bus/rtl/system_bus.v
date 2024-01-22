/*
Project Name:  RISC-V Steel System-on-Chip - System Bus
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/



module system_bus #
(
  parameter NUM_DEVICE  = 'd3
)
(
  input   wire                      clock                 ,
  input   wire                      reset                 ,

  // Host
  input   wire  [31:0]              host_rw_address       ,
  output  reg   [31:0]              host_read_data        ,
  input   wire                      host_read_request     ,
  output  reg                       host_read_response    ,
  input   wire  [31:0]              host_write_data       ,
  input   wire  [3:0 ]              host_write_strobe     ,
  input   wire                      host_write_request    ,
  output  reg                       host_write_response   ,

  // Devices
  output  wire  [31:0]              device_rw_address     ,
  input   wire  [NUM_DEVICE*32-1:0] device_read_data      ,
  output  reg   [NUM_DEVICE-1:0]    device_read_request   ,
  input   wire  [NUM_DEVICE-1:0]    device_read_response  ,
  output  wire  [31:0]              device_write_data     ,
  output  wire  [3:0 ]              device_write_strobe   ,
  output  reg   [NUM_DEVICE-1:0]    device_write_request  ,
  input   wire  [NUM_DEVICE-1:0]    device_write_response ,

  // Devices address base and mask
  input   wire  [NUM_DEVICE*32-1:0] addr_base             ,
  input   wire  [NUM_DEVICE*32-1:0] addr_mask
);



reg [NUM_DEVICE-1:0]  dev_sel;
reg [NUM_DEVICE-1:0]  dev_sel_save;
reg                   dev_valid_access;

reg                   read_response_nop;
reg                   write_response_nop;



// Side
assign device_rw_address    = host_rw_address;
assign device_write_data    = host_write_data;
assign device_write_strobe  = host_write_strobe;



integer i;

always @(*) begin
  dev_sel = 'h0;
  dev_valid_access = 'h0;
  for (i = 0; i < NUM_DEVICE; i = i + 1) begin
    if ((host_rw_address & addr_mask[i*32 +:32]) == addr_base[i*32 +:32]) begin
      dev_sel[i] = 'h1;
      dev_valid_access = 'h1;
    end
  end
end



always @(*) begin
  host_read_data = 'h0;
  host_read_response  = read_response_nop;
  host_write_response = write_response_nop;

  for (i = 0; i < NUM_DEVICE; i = i + 1) begin
    if (dev_sel_save[i]) begin
      host_read_data      = device_read_data[i*32 +: 32];
      host_read_response  = device_read_response[i];
      host_write_response = device_write_response[i];
    end
  end
end



always @(*) begin
  device_read_request   = dev_sel & {NUM_DEVICE{host_read_request}};
  device_write_request  = dev_sel & {NUM_DEVICE{host_write_request}};
end



always @(posedge clock) begin
  dev_sel_save <= 'h0;

  if ((host_read_request || host_write_request) && dev_valid_access) begin
    dev_sel_save <= dev_sel;
  end

  if (reset) begin
    dev_sel_save <= 'h0;
  end
end



always @(posedge clock) begin
  read_response_nop <= 'h0;
  write_response_nop <= 'h0;

  if (host_read_request && !dev_valid_access) begin
    read_response_nop <= 'h1;
  end

  if (host_write_request && !dev_valid_access) begin
    write_response_nop <= 'h1;
  end

  if (reset) begin
    read_response_nop <= 'h0;
    write_response_nop <= 'h0;
  end
end



endmodule
