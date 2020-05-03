//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada
// 
// Create Date: 02.04.2020 23:23:16
// Module Name: register_file
// Project Name: Steel Core 
// Description: RISC-V Steel Core 32-bit Integer Register File
// 
// Dependencies: -
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "globals.vh"

module integer_file(
    
    input wire CLK,
    input wire RESET,
    
    // connections with pipeline stage 2
    input wire [4:0] RS_1_ADDR,
    input wire [4:0] RS_2_ADDR,    
    output wire [31:0] RS_1,
    output wire [31:0] RS_2,
    
    // connections with pipeline stage 3
    input wire [4:0] RD_ADDR,
    input wire WR_EN,
    input wire [31:0] RD

    );
    
    wire [31:0] data_out [31:0];
    wire [31:0] rs1_wire;
    wire [31:0] rs2_wire;  
    wire [31:1] enable;
    wire fwd_op1_enable;
    wire fwd_op2_enable;
    wire fwd_op1_zero;
    wire fwd_op2_zero;
    wire [31:0] reg_en;
    reg [31:0] rs1_reg;
    reg [31:0] rs2_reg;
    wire rs1_addr_is_x0;
    wire rs2_addr_is_x0;
    reg [31:0] Q [31:1];
    
    genvar i;
    generate
        for(i = 1; i < 32; i=i+1)
        begin:regn
            and and_en(enable[i], reg_en[i], WR_EN);
            always @(posedge CLK or posedge RESET)
            begin
                if(RESET) Q[i] <= 32'h00000000;
                else if(enable[i]) Q[i] <= RD;
            end
            assign data_out[i] = Q[i];
        end
    endgenerate
    
    assign data_out[0] = 32'h00000000;
        
    always @(*)
    begin
        rs1_reg = data_out[RS_1_ADDR];
        rs2_reg = data_out[RS_2_ADDR];
    end
    
    assign reg_en = 32'h00000001 << RD_ADDR;
    
    assign rs1_addr_is_x0 = RS_1_ADDR == 5'b00000;
    assign rs2_addr_is_x0 = RS_2_ADDR == 5'b00000;
    assign fwd_op1_enable = RS_1_ADDR == RD_ADDR ? 1'b1 : 1'b0;
    assign fwd_op2_enable = RS_2_ADDR == RD_ADDR ? 1'b1 : 1'b0;
    assign fwd_op1_zero = rs1_addr_is_x0 == 1'b1 ? 1'b1 : 1'b0;
    assign fwd_op2_zero = rs2_addr_is_x0 == 1'b1 ? 1'b1 : 1'b0;
    assign rs1_wire = fwd_op1_enable == 1'b1 ? RD : rs1_reg;
    assign rs2_wire = fwd_op2_enable == 1'b1 ? RD : rs2_reg;
    assign RS_1 = fwd_op1_zero == 1'b1 ? 32'h00000000 : rs1_wire;
    assign RS_2 = fwd_op2_zero == 1'b1 ? 32'h00000000 : rs2_wire;
    
endmodule
