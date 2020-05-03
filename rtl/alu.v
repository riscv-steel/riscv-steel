//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada 
// 
// Create Date: 30.03.2020 17:28:42
// Module Name: alu
// Project Name: Steel Core 
// Description: 32-bit Arithmetic and Logic Unit
// 
// Dependencies: -
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "globals.vh" 

module alu(

    input wire [31:0] OP_1,
    input wire [31:0] OP_2,
    input wire [3:0] OPCODE,
    output reg [31:0] RESULT

    );
    
    wire signed [31:0] signed_op1;
    wire signed [31:0] adder_op2;
    wire [31:0] minus_op2;
    wire [31:0] sra_result;
    wire [31:0] srl_result;
    wire [31:0] shr_result;
    wire slt_result;
    wire sltu_result;
    
    reg [31:0] pre_result;    
    
    assign signed_op1 = OP_1;
    assign minus_op2 = -OP_2;
    assign adder_op2 = OPCODE[3] == 1'b1 ? minus_op2 : OP_2;
    assign sra_result = signed_op1 >>> OP_2[4:0];
    assign srl_result = OP_1 >> OP_2[4:0];
    assign shr_result = OPCODE[3] == 1'b1 ? sra_result : srl_result;
    assign sltu_result = OP_1 < OP_2;
    assign slt_result = OP_1[31] ^ OP_2[31] ? OP_1[31] : sltu_result;

    always @*
    begin
    
        case(OPCODE[2:0])
        
            `FUNCT3_ADD: RESULT = OP_1 + adder_op2;
            `FUNCT3_SRL: RESULT = shr_result;
            `FUNCT3_OR: RESULT = OP_1 | OP_2;
            `FUNCT3_AND: RESULT = OP_1 & OP_2;            
            `FUNCT3_XOR: RESULT = OP_1 ^ OP_2;
            `FUNCT3_SLT: RESULT = {31'b0, slt_result};
            `FUNCT3_SLTU: RESULT = {31'b0, sltu_result};
            `FUNCT3_SLL: RESULT = OP_1 << OP_2[4:0];
            
        endcase
    
    end
    
endmodule
