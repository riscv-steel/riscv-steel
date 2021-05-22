//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 03.04.2020 18:35:35
// Module Name: tb_decoder
// Project Name: Steel Core
// Description: Decoder testbench
// 
// Dependencies: steel_core.v
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

`define NOP_INSTR           32'b000000000000_00000_000_00000_0010011
`define OPCODE_OP           5'b01100
`define OPCODE_OP_IMM       5'b00100
`define OPCODE_LOAD         5'b00000
`define OPCODE_STORE        5'b01000
`define OPCODE_BRANCH       5'b11000
`define OPCODE_JAL          5'b11011
`define OPCODE_JALR         5'b11001
`define OPCODE_LUI          5'b01101
`define OPCODE_AUIPC        5'b00101
`define OPCODE_MISC_MEM     5'b00011
`define OPCODE_SYSTEM       5'b11100

// funct7 and funct3 for logic and arithmetic instructions

`define FUNCT7_SUB          7'b0100000
`define FUNCT7_SRA          7'b0100000
`define FUNCT7_ADD          7'b0000000
`define FUNCT7_SLT          7'b0000000
`define FUNCT7_SLTU         7'b0000000
`define FUNCT7_AND          7'b0000000
`define FUNCT7_OR           7'b0000000
`define FUNCT7_XOR          7'b0000000
`define FUNCT7_SLL          7'b0000000
`define FUNCT7_SRL          7'b0000000
`define FUNCT7_SRAI         7'b0100000
`define FUNCT7_ADDI         7'bxxxxxxx
`define FUNCT7_SLTI         7'bxxxxxxx
`define FUNCT7_SLTIU        7'bxxxxxxx
`define FUNCT7_ANDI         7'bxxxxxxx
`define FUNCT7_ORI          7'bxxxxxxx
`define FUNCT7_XORI         7'bxxxxxxx
`define FUNCT7_SLLI         7'b0000000
`define FUNCT7_SRLI         7'b0000000

`define FUNCT3_ADD          3'b000
`define FUNCT3_SUB          3'b000
`define FUNCT3_SLT          3'b010
`define FUNCT3_SLTU         3'b011
`define FUNCT3_AND          3'b111
`define FUNCT3_OR           3'b110
`define FUNCT3_XOR          3'b100
`define FUNCT3_SLL          3'b001
`define FUNCT3_SRL          3'b101
`define FUNCT3_SRA          3'b101

// ALU operations encoding

`define ALU_ADD          4'b0000
`define ALU_SUB          4'b1000
`define ALU_SLT          4'b0010
`define ALU_SLTU         4'b0011
`define ALU_AND          4'b0111
`define ALU_OR           4'b0110
`define ALU_XOR          4'b0100
`define ALU_SLL          4'b0001
`define ALU_SRL          4'b0101
`define ALU_SRA          4'b1101

// funct7 and funct3 for other instructions

`define FUNCT7_ECALL        7'b0000000
`define FUNCT7_EBREAK       7'b0000000
`define FUNCT7_MRET         7'B0011000

`define FUNCT3_CSRRW        3'b001
`define FUNCT3_CSRRS        3'b010
`define FUNCT3_CSRRC        3'b011
`define FUNCT3_CSRRWI       3'b101
`define FUNCT3_CSRRSI       3'b110
`define FUNCT3_CSRRCI       3'b111

`define FUNCT3_BEQ          3'b000
`define FUNCT3_BNE          3'b001
`define FUNCT3_BLT          3'b100
`define FUNCT3_BGE          3'b101
`define FUNCT3_BLTU         3'b110
`define FUNCT3_BGEU         3'b111

`define FUNCT3_ECALL        3'b000
`define FUNCT3_EBREAK       3'b000
`define FUNCT3_MRET         3'b000
`define FUNCT3_WFI          3'b000

`define FUNCT3_BYTE         3'b000
`define FUNCT3_HALF         3'b001
`define FUNCT3_WORD         3'b010
`define FUNCT3_BYTE_U       3'b100
`define FUNCT3_HALF_U       3'b101

// rd, rs1 and rs2 values for SYSTEM instructions

`define RS1_ECALL           5'b00000
`define RS1_EBREAK          5'b00000
`define RS1_MRET            5'b00000
`define RS1_WFI             5'b00000

`define RS2_ECALL           5'b00000
`define RS2_EBREAK          5'b00001
`define RS2_MRET            5'b00010
`define RS2_WFI             5'b00101

`define RD_ECALL            5'b00000
`define RD_EBREAK           5'b00000
`define RD_MRET             5'b00000
`define RD_WFI              5'b00000

// writeback selection
`define WB_ALU                 3'b000
`define WB_LU                  3'b001
`define WB_IMM                 3'b010
`define WB_IADDER_OUT          3'b011
`define WB_CSR                 3'b100
`define WB_PC_PLUS             3'b101

// immediate format selection

`define R_TYPE              3'b000
`define I_TYPE              3'b001
`define S_TYPE              3'b010
`define B_TYPE              3'b011
`define U_TYPE              3'b100
`define J_TYPE              3'b101
`define CSR_TYPE            3'b110

// PC MUX selection

`define PC_BOOT             2'b00
`define PC_EPC              2'b01
`define PC_TRAP             2'b10
`define PC_NEXT             2'b11

// mask for byte-writes

`define WR_MASK_BYTE          4'b0001
`define WR_MASK_HALF          4'b0011
`define WR_MASK_WORD          4'b1111

// load unit control encoding

`define LOAD_BYTE          2'b00
`define LOAD_HALF          2'b01
`define LOAD_WORD          2'b10

module decoder_tb();

    reg [6:0] OPCODE;
    reg FUNCT7_5;
    reg [2:0] FUNCT3;
    reg [1:0] IADDER_OUT_1_TO_0;
    reg TRAP_TAKEN;
    
    wire [3:0] ALU_OPCODE;
    wire MEM_WR_REQ;
    wire [1:0] LOAD_SIZE;
    wire LOAD_UNSIGNED;
    wire ALU_SRC;
    wire IADDER_SRC;
    wire CSR_WR_EN;
    wire RF_WR_EN;
    wire [2:0] WB_MUX_SEL;
    wire [2:0] IMM_TYPE;
    wire [2:0] CSR_OP;
    wire ILLEGAL_INSTR;
    wire MISALIGNED_LOAD;
    wire MISALIGNED_STORE;
    
    decoder dut(
        
        .OPCODE(OPCODE),
        .FUNCT7_5(FUNCT7_5),
        .FUNCT3(FUNCT3),
        .IADDER_OUT_1_TO_0(IADDER_OUT_1_TO_0),
        .TRAP_TAKEN(TRAP_TAKEN),        
        .ALU_OPCODE(ALU_OPCODE),
        .MEM_WR_REQ(MEM_WR_REQ),
        .LOAD_SIZE(LOAD_SIZE),
        .LOAD_UNSIGNED(LOAD_UNSIGNED),
        .ALU_SRC(ALU_SRC),
        .IADDER_SRC(IADDER_SRC),
        .CSR_WR_EN(CSR_WR_EN),
        .RF_WR_EN(RF_WR_EN),
        .WB_MUX_SEL(WB_MUX_SEL),
        .IMM_TYPE(IMM_TYPE),
        .CSR_OP(CSR_OP),
        .ILLEGAL_INSTR(ILLEGAL_INSTR),
        .MISALIGNED_LOAD(MISALIGNED_LOAD),
        .MISALIGNED_STORE(MISALIGNED_STORE)
        
    );
        
    reg [4:0] opcode_6_to_2;
    reg [6:0] funct7;
    
    initial
    begin
    
        $display("Testing Decoder...");
        
        $display("Testing OP opcode control signals...");

        $display("Testing signals common to all instructions...");
        
        opcode_6_to_2 = `OPCODE_OP;
        OPCODE = {opcode_6_to_2, 2'b11};
        IADDER_OUT_1_TO_0 = 2'b00;
        TRAP_TAKEN = 1'b0;
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(ALU_SRC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WB_MUX_SEL != `WB_ALU)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end       
        
        $display("OP control signals common to all instructions successfully tested.");
        
        $display("Testing ALU_OPCODE signal generation for OP opcode...");
        
        funct7 = `FUNCT7_ADD;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_ADD;
        #10;
        if(ALU_OPCODE != `ALU_ADD)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for ADD... OK.");
        
        funct7 = `FUNCT7_SUB;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SUB;
        #10;
        if(ALU_OPCODE != `ALU_SUB)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SUB... OK.");
        
        funct7 = `FUNCT7_SLT;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SLT;
        #10;
        if(ALU_OPCODE != `ALU_SLT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SLT... OK.");
        
        funct7 = `FUNCT7_SLTU;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SLTU;
        #10;
        if(ALU_OPCODE != `ALU_SLTU)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SLTU... OK.");
        
        funct7 = `FUNCT7_AND;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_AND;
        #10;
        if(ALU_OPCODE != `ALU_AND)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for AND... OK.");
        
        funct7 = `FUNCT7_OR;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_OR;
        #10;
        if(ALU_OPCODE != `ALU_OR)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for OR... OK.");
        
        funct7 = `FUNCT7_XOR;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_XOR;
        #10;
        if(ALU_OPCODE != `ALU_XOR)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for XOR... OK.");
        
        funct7 = `FUNCT7_SLL;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SLL;
        #10;
        if(ALU_OPCODE != `ALU_SLL)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SLL... OK.");
        
        funct7 = `FUNCT7_SRL;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SRL;
        #10;
        if(ALU_OPCODE != `ALU_SRL)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SRL... OK.");
        
        funct7 = `FUNCT7_SRA;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SRA;
        #10;
        if(ALU_OPCODE != `ALU_SRA)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SRA... OK.");
        
        $display("ALU_OPCODE signal generation for OP opcode successfully tested.");
        
        $display("OP control signals successfully tested."); 
        
        $display("Testing OP-IMM opcode control signals...");
        
        $display("Testing signals common to all instructions...");
        
        opcode_6_to_2 = `OPCODE_OP_IMM;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(ALU_SRC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WB_MUX_SEL != `WB_ALU)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `I_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("OP-IMM control signals common to all instructions successfully tested.");
        
        $display("Testing ALU_OPCODE signal generation for OP-IMM opcode...");
                
        FUNCT7_5 = 1'b0;
        FUNCT3 = `FUNCT3_ADD;
        #10;
        if(ALU_OPCODE != `ALU_ADD)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT7_5 = 1'b1;
        FUNCT3 = `FUNCT3_ADD;
        #10;
        if(ALU_OPCODE != `ALU_ADD)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for ADDI... OK.");
        
        FUNCT7_5 = 1'b0;
        FUNCT3 = `FUNCT3_SLT;
        #10;
        if(ALU_OPCODE != `ALU_SLT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT7_5 = 1'b1;
        FUNCT3 = `FUNCT3_SLT;
        #10;
        if(ALU_OPCODE != `ALU_SLT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SLTI... OK.");
        
        FUNCT7_5 = 1'b0;
        FUNCT3 = `FUNCT3_SLTU;
        #10;
        if(ALU_OPCODE != `ALU_SLTU)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT7_5 = 1'b1;
        FUNCT3 = `FUNCT3_SLTU;
        #10;
        if(ALU_OPCODE != `ALU_SLTU)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SLTIU... OK.");
        
        FUNCT7_5 = 1'b0;
        FUNCT3 = `FUNCT3_AND;
        #10;
        if(ALU_OPCODE != `ALU_AND)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT7_5 = 1'b1;
        FUNCT3 = `FUNCT3_AND;
        #10;
        if(ALU_OPCODE != `ALU_AND)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for ANDI... OK.");
        
        FUNCT7_5 = 1'b0;
        FUNCT3 = `FUNCT3_OR;
        #10;
        if(ALU_OPCODE != `ALU_OR)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT7_5 = 1'b1;
        FUNCT3 = `FUNCT3_OR;
        #10;
        if(ALU_OPCODE != `ALU_OR)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for ORI... OK.");
        
        FUNCT7_5 = 1'b0;
        FUNCT3 = `FUNCT3_XOR;
        #10;
        if(ALU_OPCODE != `ALU_XOR)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT7_5 = 1'b1;
        FUNCT3 = `FUNCT3_XOR;
        #10;
        if(ALU_OPCODE != `ALU_XOR)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for XORI... OK.");
        
        funct7 = `FUNCT7_SLL;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SLL;
        #10;
        if(ALU_OPCODE != `ALU_SLL)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SLLI... OK.");
        
        funct7 = `FUNCT7_SRL;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SRL;
        #10;
        if(ALU_OPCODE != `ALU_SRL)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SRLI... OK.");
        
        funct7 = `FUNCT7_SRA;
        FUNCT7_5 = funct7[5];
        FUNCT3 = `FUNCT3_SRA;
        #10;
        if(ALU_OPCODE != `ALU_SRA)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ALU_OPCODE for SRAI... OK.");
        
        $display("ALU_OPCODE signal generation for OP-IMM opcode successfully tested.");
        
        $display("OP-IMM control signals successfully tested.");         
        
        $display("Testing LOAD opcode control signals...");
        
        $display("Testing signals common to all instructions...");
        
        opcode_6_to_2 = `OPCODE_LOAD;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WB_MUX_SEL != `WB_LU)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end       
        if(IADDER_SRC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `I_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("LOAD control signals common to all instructions successfully tested.");
        
        $display("Testing load unit control signals generation...");
        
        FUNCT3 = `FUNCT3_BYTE;
        #10;
        if(LOAD_SIZE != `LOAD_BYTE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(LOAD_UNSIGNED != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Load unit signals for LB... OK.");
        
        $display("Testing signal MISALIGNED_LOAD for LB...");
        
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_LOAD generation for LB OK.");
        
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(LOAD_SIZE != `LOAD_HALF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(LOAD_UNSIGNED != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Load unit signals for LH... OK.");
        
        $display("Testing signal MISALIGNED_LOAD for LH...");
        
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_LOAD generation for LH OK.");
        
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(LOAD_SIZE != `LOAD_WORD)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(LOAD_UNSIGNED != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Load unit signals for LW... OK.");
        
        $display("Testing signal MISALIGNED_LOAD for LW...");
        
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_LOAD generation for LW OK.");
        
        FUNCT3 = `FUNCT3_BYTE_U;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(LOAD_SIZE != `LOAD_BYTE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(LOAD_UNSIGNED != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Load unit signals for LBU... OK.");
        
        $display("Testing signal MISALIGNED_LOAD for LBU...");
        
        FUNCT3 = `FUNCT3_BYTE_U;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_BYTE_U;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_BYTE_U;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_LOAD generation for LBU OK.");
        
        FUNCT3 = `FUNCT3_HALF_U;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(LOAD_SIZE != `LOAD_HALF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(LOAD_UNSIGNED != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Load unit signals for LHU... OK.");
        
        $display("Testing signal MISALIGNED_LOAD for LHU...");
        
        FUNCT3 = `FUNCT3_HALF_U;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_HALF_U;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_HALF_U;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_LOAD != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_LOAD generation for LHU OK.");
        
        $display("Signals for load unit successfuly tested.");
        
        $display("LOAD opcode successfully tested.");
        
        $display("Testing STORE opcode operation...");
        
        $display("Testing signals common to all instructions...");
        
        opcode_6_to_2 = `OPCODE_STORE;
        OPCODE = {opcode_6_to_2, 2'b11};
        IADDER_OUT_1_TO_0 = 2'b00;
        
        #10;
        if(MEM_WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MISALIGNED_LOAD != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end              
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end       
        if(IADDER_SRC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `S_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        TRAP_TAKEN = 1'b1;
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        TRAP_TAKEN = 1'b0;
        
        $display("STORE control signals common to all instructions successfully tested.");
        
        $display("Testing signal MISALIGNED_STORE for SB...");
        
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_BYTE;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_STORE generation for SB OK.");                       
        
        $display("Testing signal MISALIGNED_STORE for SH...");
        
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_STORE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_HALF;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_STORE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_STORE generation for SH OK.");
        
        $display("Testing signal MISALIGNED_STORE for SW...");
        
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b00;
        #10;
        if(MISALIGNED_STORE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b01;
        #10;
        if(MISALIGNED_STORE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b10;
        #10;
        if(MISALIGNED_STORE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        FUNCT3 = `FUNCT3_WORD;
        IADDER_OUT_1_TO_0 = 2'b11;
        #10;
        if(MISALIGNED_STORE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end    
        
        $display("MISALIGNED_STORE generation for SW OK.");
                      
        $display("STORE operation successfully tested.");
        
        $display("Testing BRANCH opcode signals generation...");
        
        opcode_6_to_2 = `OPCODE_BRANCH;
        OPCODE = {opcode_6_to_2, 2'b11};
        IADDER_OUT_1_TO_0 = 2'b00;
               
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IADDER_SRC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `B_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("BRANCH control signals successfully tested.");
        
        $display("Testing JAL control signals generation...");
        
        opcode_6_to_2 = `OPCODE_JAL;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IADDER_SRC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WB_MUX_SEL != `WB_PC_PLUS)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end      
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `J_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("JAL control signals successfully tested.");
        
        $display("Testing JALR control signals generation...");
        
        opcode_6_to_2 = `OPCODE_JALR;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        if(WB_MUX_SEL != `WB_PC_PLUS)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IADDER_SRC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `I_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("JALR control signals successfully tested.");
        
        $display("Testing LUI opcode operation...");
        
        opcode_6_to_2 = `OPCODE_LUI;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        if(WB_MUX_SEL != `WB_IMM)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end  
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `U_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("LUI control signals successfully tested.");
        
        $display("Testing AUIPC control signals generation...");
        
        opcode_6_to_2 = `OPCODE_AUIPC;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WB_MUX_SEL != `WB_IADDER_OUT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IADDER_SRC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end   
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        if(IMM_TYPE != `U_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("AUIPC control signals successfully tested.");
        
        $display("Testing MISC-MEM control signals generation...");
        
        opcode_6_to_2 = `OPCODE_MISC_MEM;
        OPCODE = {opcode_6_to_2, 2'b11};
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("MISM-MEM control signals successfully tested.");
        
        $display("Testing SYSteel Core control signals operation...");
        
        $display("Testing ECALL, EBREAK, MRET and WFI instructions...");
        
        opcode_6_to_2 = `OPCODE_SYSTEM;
        OPCODE = {opcode_6_to_2, 2'b11};
        FUNCT3 = 3'b000;
        
        #10;
        if(MEM_WR_REQ != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("ECALL, EBREAK, MRET and WFI successfully tested.");
        
        $display("Testing CSRRW...");
        
        FUNCT3 = 3'b001;
        #10;
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IMM_TYPE != `CSR_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_OP != FUNCT3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("CSRRW successfully tested.");
        
        $display("Testing CSRRS...");
        
        FUNCT3 = 3'b010;
        #10;
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IMM_TYPE != `CSR_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_OP != FUNCT3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("CSRRS successfully tested.");
        
        $display("Testing CSRRC...");
        
        FUNCT3 = 3'b011;
        #10;
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IMM_TYPE != `CSR_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_OP != FUNCT3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("CSRRC successfully tested.");
        
        $display("Testing CSRRWI...");
        
        FUNCT3 = 3'b101;
        #10;
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IMM_TYPE != `CSR_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_OP != FUNCT3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("CSRRWI successfully tested.");
        
        $display("Testing CSRRSI...");
        
        FUNCT3 = 3'b110;
        #10;
        if(ILLEGAL_INSTR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(RF_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_WR_EN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(IMM_TYPE != `CSR_TYPE)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_OP != FUNCT3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("CSRRSI successfully tested.");
        
        $display("Steel Core control signals successfully tested.");
        
        $display("Testing illegal instructions...");
        
        OPCODE = {`OPCODE_OP,2'b10};
        #10;
        if(ILLEGAL_INSTR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE = {`OPCODE_OP,2'b01};
        #10;
        if(ILLEGAL_INSTR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE = {5'b11111,2'b11};
        #10;
        if(ILLEGAL_INSTR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Illegal instructions successfully tested.");
        
        $display("Decoder successfully tested.");
    
    end

endmodule
