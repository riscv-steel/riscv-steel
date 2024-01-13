/*
Project Name:  RISC-V Steel System-on-Chip - System Bus
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/



module sys_bus #
(
    parameter NUM_DEVICE  = 'd3
)
(
    input                       clock_i                 ,
    input                       reset_i                 ,

    // Host
    input   [31:0]              host_rw_address_i       ,
    output  [31:0]              host_read_data_o        ,
    input                       host_read_request_i     ,
    output                      host_read_response_o    ,
    input   [31:0]              host_write_data_i       ,
    input   [3:0 ]              host_write_strobe_i     ,
    input                       host_write_request_i    ,
    output                      host_write_response_o   ,

    // Devices
    output  [NUM_DEVICE*32-1:0] device_rw_address_o     ,
    input   [NUM_DEVICE*32-1:0] device_read_data_i      ,
    output  [NUM_DEVICE-1:0]    device_read_request_o   ,
    input   [NUM_DEVICE-1:0]    device_read_response_i  ,
    output  [NUM_DEVICE*32-1:0] device_write_data_o     ,
    output  [NUM_DEVICE*4-1:0 ] device_write_strobe_o   ,
    output  [NUM_DEVICE-1:0]    device_write_request_o  ,
    input   [NUM_DEVICE-1:0]    device_write_response_i ,

    // Devices address base and mask
    input   [NUM_DEVICE*32-1:0] addr_base               ,
    input   [NUM_DEVICE*32-1:0] addr_mask
);



reg [NUM_DEVICE-1:0]    dev_sel;
reg [NUM_DEVICE-1:0]    dev_sel_save;
reg                     dev_valid_access;

reg [NUM_DEVICE-1:0]    host_read_request;
reg [NUM_DEVICE-1:0]    host_write_request;

reg [31:0]              device_read_data;
reg                     device_read_response;
reg                     device_write_response;

reg                     read_response_nop;
reg                     write_response_nop;



// Side
assign host_read_data_o         = device_read_data;
assign host_read_response_o     = device_read_response;
assign host_write_response_o    = device_write_response;



genvar device_i;

generate
    for (device_i = 0; device_i < NUM_DEVICE; device_i = device_i + 1)
    begin:gen_device_assign
        assign device_rw_address_o[device_i*32 +: 32]   = host_rw_address_i;
        assign device_read_request_o                    = host_read_request;
        assign device_write_data_o[device_i*32 +: 32]   = host_write_data_i;
        assign device_write_strobe_o[device_i*4 +: 4]   = host_write_strobe_i;
        assign device_write_request_o                   = host_write_request;
    end
endgenerate



integer i;

always @(*) begin
    dev_sel = 'h0;
    dev_valid_access = 'h0;
    for (i = 0; i < NUM_DEVICE; i = i + 1) begin
        if ((host_rw_address_i & addr_mask[i*32 +:32]) == addr_base[i*32 +:32]) begin
            dev_sel[i] = 'h1;
            dev_valid_access = 'h1;
        end
    end
end



always @(*) begin
    device_read_data = 'h0;
    device_read_response  = read_response_nop;
    device_write_response = write_response_nop;

    for (i = 0; i < NUM_DEVICE; i = i + 1) begin
        if (dev_sel_save[i]) begin
            device_read_data        = device_read_data_i[i*32 +: 32];
            device_read_response    = device_read_response_i[i];
            device_write_response   = device_write_response_i[i];
        end
    end
end



always @(*) begin
    host_read_request    = dev_sel & {NUM_DEVICE{host_read_request_i}};
    host_write_request   = dev_sel & {NUM_DEVICE{host_write_request_i}};
end



always @(posedge clock_i) begin
    dev_sel_save <= 'h0;

    if ((host_read_request_i || host_write_request_i) && dev_valid_access) begin
        dev_sel_save <= dev_sel;
    end

    if (reset_i) begin
        dev_sel_save <= 'h0;
    end
end



always @(posedge clock_i) begin
    read_response_nop <= 'h0;
    write_response_nop <= 'h0;

    if (host_read_request_i && !dev_valid_access) begin
        read_response_nop <= 'h1;
    end

    if (host_write_request_i && !dev_valid_access) begin
        write_response_nop <= 'h1;
    end

    if (reset_i) begin
        read_response_nop <= 'h0;
        write_response_nop <= 'h0;
    end
end



endmodule
