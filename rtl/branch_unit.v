//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 18:29:52
// Module Name: branch_unit
// Project Name: Steel Core 
// Description: RISC-V Steel Core Branch Decision Unit
// 
// Dependencies: -
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "globals.vh"

module branch_unit(

    input wire [6:2] OPCODE_6_TO_2,
    input wire [2:0] FUNCT3,
    input wire [31:0] RS1,
    input wire [31:0] RS2,
    output wire BRANCH_TAKEN
    
    );
    
    wire pc_mux_sel;
    wire pc_mux_sel_en;
    wire is_branch;
    wire is_jal;
    wire is_jalr;
    wire is_jump;
    wire eq;
    wire ne;
    wire lt;
    wire ge;
    wire ltu;
    wire geu;
    reg take;

    assign is_jal = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & ~OPCODE_6_TO_2[4] & OPCODE_6_TO_2[3] & OPCODE_6_TO_2[2];
    assign is_jalr = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & ~OPCODE_6_TO_2[4] & ~OPCODE_6_TO_2[3] & OPCODE_6_TO_2[2];
    assign is_jump = is_jal | is_jalr;
    assign eq = (RS1 == RS2);
    assign ne = !eq;
    assign lt = RS1[31] ^ RS2[31] ? RS1[31] : ltu;
    assign ge = !lt;
    assign ltu = (RS1 < RS2);
    assign geu = !ltu;
    assign is_branch = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & ~OPCODE_6_TO_2[4] & ~OPCODE_6_TO_2[3] & ~OPCODE_6_TO_2[2];
    assign pc_mux_sel_en = is_branch | is_jal | is_jalr;
    assign pc_mux_sel = (is_jump == 1'b1) ? 1'b1 : take;
    assign BRANCH_TAKEN = pc_mux_sel_en & pc_mux_sel;
    
    always @(*)
    begin
        case (FUNCT3)
            3'b000: take = eq;
            3'b001: take = ne;
            3'b100: take = lt;
            3'b101: take = ge;
            3'b110: take = ltu;
            3'b111: take = geu;
            default: take = 1'b0;
        endcase
    end
    
endmodule
