//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 25.04.2020 14:49:16
// Module Name: decoder
// Project Name: Steel Core 
// Description: Decodes the instruction and generates control signals 
// 
// Dependencies: globals.vh
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

/*********************************************************************************

MIT License

Copyright (c) 2020 Rafael de Oliveira Calçada

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

********************************************************************************/

`timescale 1ns / 1ps
`include "globals.vh"

module decoder(

    input wire [6:0] OPCODE,
    input wire FUNCT7_5,
    input wire [2:0] FUNCT3,
    input wire [1:0] IADDER_OUT_1_TO_0,
    input wire TRAP_TAKEN,
    
    output wire [3:0] ALU_OPCODE,
    output wire MEM_WR_REQ,
    output wire [1:0] LOAD_SIZE,
    output wire LOAD_UNSIGNED,
    output wire ALU_SRC,
    output wire IADDER_SRC,
    output wire CSR_WR_EN,
    output wire RF_WR_EN,
    output wire [2:0] WB_MUX_SEL,
    output wire [2:0] IMM_TYPE,
    output wire [2:0] CSR_OP,
    output wire ILLEGAL_INSTR,
    output wire MISALIGNED_LOAD,
    output wire MISALIGNED_STORE

    );
    
    wire is_branch;
    wire is_jal;
    wire is_jalr;
    wire is_auipc;
    wire is_lui;
    wire is_load;
    wire is_store;
    wire is_system;
    wire is_csr;
    wire is_op;
    wire is_op_imm;
    wire is_misc_mem;
    wire is_addi;
    wire is_slti;
    wire is_sltiu;
    wire is_andi;
    wire is_ori;
    wire is_xori;
    wire is_addiw;
    wire is_implemented_instr;
    wire mal_word;
    wire mal_half;
    wire misaligned;
        
    assign LOAD_SIZE[0] = FUNCT3[0];
    assign LOAD_SIZE[1] = FUNCT3[1];
    assign LOAD_UNSIGNED = FUNCT3[2];
    assign ALU_SRC = OPCODE[5];
    assign is_branch = OPCODE[6] & OPCODE[5] & ~OPCODE[4] & ~OPCODE[3] & ~OPCODE[2];
    assign is_jal = OPCODE[6] & OPCODE[5] & ~OPCODE[4] & OPCODE[3] & OPCODE[2];
    assign is_jalr = OPCODE[6] & OPCODE[5] & ~OPCODE[4] & ~OPCODE[3] & OPCODE[2];
    assign is_auipc = ~OPCODE[6] & ~OPCODE[5] & OPCODE[4] & ~OPCODE[3] & OPCODE[2];
    assign is_lui = ~OPCODE[6] & OPCODE[5] & OPCODE[4] & ~OPCODE[3] & OPCODE[2];
    assign is_op = ~OPCODE[6] & OPCODE[5] & OPCODE[4] & ~OPCODE[3] & ~OPCODE[2];
    assign is_op_imm = ~OPCODE[6] & ~OPCODE[5] & OPCODE[4] & ~OPCODE[3] & ~OPCODE[2];
    assign is_addi = is_op_imm & ~FUNCT3[2] & ~FUNCT3[1] & ~FUNCT3[0]; 
    assign is_slti = is_op_imm & ~FUNCT3[2] & FUNCT3[1] & ~FUNCT3[0];
    assign is_sltiu = is_op_imm & ~FUNCT3[2] & FUNCT3[1] & FUNCT3[0];
    assign is_andi = is_op_imm & FUNCT3[2] & FUNCT3[1] & FUNCT3[0];
    assign is_ori = is_op_imm & FUNCT3[2] & FUNCT3[1] & ~FUNCT3[0];
    assign is_xori = is_op_imm & FUNCT3[2] & ~FUNCT3[1] & ~FUNCT3[0];
    assign is_load = ~OPCODE[6] & ~OPCODE[5] & ~OPCODE[4] & ~OPCODE[3] & ~OPCODE[2];
    assign is_store = ~OPCODE[6] & OPCODE[5] & ~OPCODE[4] & ~OPCODE[3] & ~OPCODE[2];
    assign is_system = OPCODE[6] & OPCODE[5] & OPCODE[4] & ~OPCODE[3] & ~OPCODE[2];
    assign is_misc_mem = ~OPCODE[6] & ~OPCODE[5] & ~OPCODE[4] & OPCODE[3] & OPCODE[2];
    assign is_csr = is_system & (FUNCT3[2] | FUNCT3[1] | FUNCT3[0]);    
    assign IADDER_SRC = is_load | is_store | is_jalr;
    assign RF_WR_EN = is_lui | is_auipc | is_jalr | is_jal | is_op | is_load | is_csr | is_op_imm;
    assign CSR_WR_EN = is_csr;
    assign ALU_OPCODE[2:0] = FUNCT3;
    assign ALU_OPCODE[3] = FUNCT7_5 & ~(is_addi | is_slti | is_sltiu | is_andi | is_ori | is_xori);
    assign WB_MUX_SEL[0] = is_load | is_auipc | is_jal | is_jalr;
    assign WB_MUX_SEL[1] = is_lui | is_auipc;
    assign WB_MUX_SEL[2] = is_csr | is_jal | is_jalr;
    assign IMM_TYPE[0] = is_op_imm | is_load | is_jalr | is_branch | is_jal;
    assign IMM_TYPE[1] = is_store | is_branch | is_csr;
    assign IMM_TYPE[2] = is_lui | is_auipc | is_jal | is_csr;
    assign CSR_OP = FUNCT3;
    assign is_implemented_instr = is_op | is_op_imm | is_branch | is_jal | is_jalr | is_auipc | is_lui | is_system | is_misc_mem | is_load | is_store;
    assign ILLEGAL_INSTR = ~OPCODE[1] | ~OPCODE[0] | ~is_implemented_instr;
    assign mal_word = FUNCT3[1] & ~FUNCT3[0] & (IADDER_OUT_1_TO_0[1] | IADDER_OUT_1_TO_0[0]);
    assign mal_half = ~FUNCT3[1] & FUNCT3[0] & IADDER_OUT_1_TO_0[0];
    assign misaligned = mal_word | mal_half;
    assign MISALIGNED_STORE = is_store & misaligned;
    assign MISALIGNED_LOAD = is_load & misaligned;
    assign MEM_WR_REQ = is_store & ~misaligned & ~TRAP_TAKEN;
    
    
endmodule
