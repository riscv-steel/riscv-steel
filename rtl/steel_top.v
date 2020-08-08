//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 30.04.2020 02:39:50
// Module Name: steel_top
// Project Name: Steel Core 
// Description: Steel Core top module 
// 
// Dependencies: globals.vh
//               machine_control.v
//               alu.v
//               integer_file.v
//               branch_unit.v
//               decoder.v
//               csr_file.v
//               imm_generator.v
//               load_unit.v
//               store_unit.v
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

module steel_top #(

    parameter BOOT_ADDRESS = 32'h00000000
    
    )(
    
    input wire CLK,
    input wire RESET,
    
    // connection with Real Time Counter
    input wire [63:0] REAL_TIME,
    
    // connections with Instruction Memory
    output wire [31:0] I_ADDR,
    input wire [31:0] INSTR,
    
    // connections with Data Memory
    output wire [31:0] D_ADDR,
    output wire [31:0] DATA_OUT,
    output wire WR_REQ,
    output wire [3:0] WR_MASK,
    input wire [31:0] DATA_IN,
    
    //connections with Interrupt Controller
    input wire E_IRQ,
    input wire T_IRQ,
    input wire S_IRQ

    );
    
    // ---------------------------------
    // Internal wires and registers
    // ---------------------------------
    
    wire [4:0] RS1_ADDR;
    wire [4:0] RS2_ADDR;
    wire [4:0] RD_ADDR;
    reg [4:0] RD_ADDR_reg;
    wire [31:0] CSR_DATA;
    wire [11:0] CSR_ADDR;
    reg [11:0] CSR_ADDR_reg;
    wire [31:0] RS1;
    reg [31:0] RS1_reg;
    wire [31:0] RS2;
    reg [31:0] RS2_reg;
    reg [31:0] PC;
    reg [31:0] PC_reg;
    wire [31:0] NEXT_PC;
    wire [31:0] PC_PLUS_4;
    reg [31:0] PC_PLUS_4_reg;
    wire BRANCH_TAKEN;
    wire [31:0] IADDER_OUT;
    reg [31:0] IADDER_OUT_reg;
    wire [31:0] EPC;
    wire [31:0] TRAP_ADDRESS;
    wire [1:0] PC_SRC;
    wire [6:0] OPCODE;
    wire [6:0] FUNCT7;
    wire [2:0] FUNCT3;
    wire [3:0] ALU_OPCODE;
    reg [3:0] ALU_OPCODE_reg;
    wire MEM_WR_REQ;
    wire [3:0] MEM_WR_MASK;
    wire [1:0] LOAD_SIZE;
    reg [1:0] LOAD_SIZE_reg;
    wire LOAD_UNSIGNED;
    reg LOAD_UNSIGNED_reg;
    wire ALU_SRC;
    reg ALU_SRC_reg;
    wire IADDER_SRC;
    wire CSR_WR_EN;
    reg CSR_WR_EN_reg;
    wire RF_WR_EN;
    reg RF_WR_EN_reg;
    wire [2:0] WB_MUX_SEL;
    reg [2:0] WB_MUX_SEL_reg;
    wire [2:0] IMM_TYPE;
    wire [2:0] CSR_OP;
    reg [2:0] CSR_OP_reg;
    wire ILLEGAL_INSTR;
    wire MISALIGNED_LOAD;
    wire MISALIGNED_STORE;
    wire [31:0] IMM;
    reg [31:0] IMM_reg;
    wire I_OR_E;
    wire SET_CAUSE;
    wire [3:0] CAUSE_IN;
    wire SET_EPC;
    wire INSTRET_INC;
    wire MIE_CLEAR;
    wire MIE_SET;
    wire MIE;
    wire MEIE_OUT;
    wire MTIE_OUT;
    wire MSIE_OUT;
    wire MEIP_OUT;
    wire MTIP_OUT;
    wire MSIP_OUT;
    wire FLUSH;
    wire [31:0] LU_OUTPUT;
    wire [31:0] ALU_RESULT;
    reg [31:0] WB_MUX_OUT;
    wire [31:0] SU_DATA_OUT;
    wire [31:0] SU_D_ADDR;
    wire [3:0] SU_WR_MASK;
    wire SU_WR_REQ;
    wire TRAP_TAKEN;
    wire MISALIGNED_EXCEPTION;
    
    // ---------------------------------
    // PIPELINE STAGE 1
    // ---------------------------------
    
    // PC MUX
    
    reg [31:0] PC_MUX_OUT;
    always @*
    begin
        case (PC_SRC)
            `PC_BOOT:      PC_MUX_OUT = BOOT_ADDRESS;
            `PC_EPC:       PC_MUX_OUT = EPC;
            `PC_TRAP:      PC_MUX_OUT = TRAP_ADDRESS;
            `PC_NEXT:      PC_MUX_OUT = NEXT_PC;
        endcase
    end
    
    // PC Adder and Multiplexer
    assign PC_PLUS_4 = PC + 32'h00000004;
    assign NEXT_PC = BRANCH_TAKEN ? {IADDER_OUT[31:1], 1'b0} : PC_PLUS_4;
    
    // Program Counter (PC) register
    always @(posedge CLK)
    begin
        if(RESET) PC <= BOOT_ADDRESS;
        else PC <= PC_MUX_OUT;
    end
    
    // ---------------------------------
    // PIPELINE STAGE 2
    // ---------------------------------       
    
    wire [31:0] INSTR_mux;
    assign INSTR_mux = FLUSH == 1'b1 ? 32'h00000013 : INSTR;
    
    assign OPCODE = INSTR_mux[6:0];
    assign FUNCT3 = INSTR_mux[14:12];
    assign FUNCT7 = INSTR_mux[31:25];
    
    store_unit su(

        .FUNCT3(FUNCT3[1:0]),
        .IADDER_OUT(IADDER_OUT), 
        .RS2(RS2),
        .MEM_WR_REQ(MEM_WR_REQ),
        
        .DATA_OUT(SU_DATA_OUT),
        .D_ADDR(SU_D_ADDR),
        .WR_MASK(SU_WR_MASK),
        .WR_REQ(SU_WR_REQ)
    
    );
    
    decoder dec(
    
        .OPCODE(OPCODE),
        .FUNCT7_5(FUNCT7[5]),
        .FUNCT3(FUNCT3),
        .IADDER_OUT_1_TO_0(IADDER_OUT[1:0]),
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
    
    imm_generator immgen(
    
        .INSTR(INSTR_mux[31:7]),
        .IMM_TYPE(IMM_TYPE),
        .IMM(IMM)
    
    );
    
    // Immediate Adder
    wire [31:0] iadder_mux_out;
    assign iadder_mux_out = IADDER_SRC == 1'b1 ? RS1 : PC;
    assign IADDER_OUT = iadder_mux_out + IMM;
    
    branch_unit bunit(

        .OPCODE_6_TO_2(OPCODE[6:2]),
        .FUNCT3(FUNCT3),
        .RS1(RS1),
        .RS2(RS2),
        .BRANCH_TAKEN(BRANCH_TAKEN)
    
    );
    
    assign RS1_ADDR = INSTR_mux[19:15];
    assign RS2_ADDR = INSTR_mux[24:20];
    assign RD_ADDR = INSTR_mux[11:7];
    
    integer_file irf(
    
        .CLK(CLK),
        
        .RS_1_ADDR(RS1_ADDR),
        .RS_2_ADDR(RS2_ADDR),    
        .RS_1(RS1),
        .RS_2(RS2),
        
        .RD_ADDR(RD_ADDR_reg),
        .WR_EN(FLUSH ? 1'b0 : RF_WR_EN_reg),
        .RD(WB_MUX_OUT)

    );
    
    assign CSR_ADDR = INSTR_mux[31:20]; 
    
    csr_file csrf(

        .CLK(CLK),
        .RESET(RESET),
        
        .WR_EN(FLUSH ? 1'b0 : CSR_WR_EN_reg),
        .CSR_ADDR(CSR_ADDR_reg),
        .CSR_OP(CSR_OP_reg),
        .CSR_UIMM(IMM_reg[4:0]),
        .CSR_DATA_IN(RS1_reg),
        .CSR_DATA_OUT(CSR_DATA),
        
        .PC(PC_reg),
        .IADDER_OUT(IADDER_OUT_reg),
        
        .E_IRQ(E_IRQ),
        .T_IRQ(T_IRQ),
        .S_IRQ(S_IRQ),
        
        .I_OR_E(I_OR_E),
        .SET_CAUSE(SET_CAUSE),
        .CAUSE_IN(CAUSE_IN),
        .SET_EPC(SET_EPC),
        .INSTRET_INC(INSTRET_INC),
        .MIE_CLEAR(MIE_CLEAR),
        .MIE_SET(MIE_SET),
        .MISALIGNED_EXCEPTION(MISALIGNED_EXCEPTION),
        .MIE(MIE),
        .MEIE_OUT(MEIE_OUT),
        .MTIE_OUT(MTIE_OUT),
        .MSIE_OUT(MSIE_OUT),
        .MEIP_OUT(MEIP_OUT),
        .MTIP_OUT(MTIP_OUT),
        .MSIP_OUT(MSIP_OUT),
        
        .REAL_TIME(REAL_TIME),
        
        .EPC_OUT(EPC),
        .TRAP_ADDRESS(TRAP_ADDRESS)

    );
        
    machine_control mc(

        .CLK(CLK),
        .RESET(RESET),
        
        .ILLEGAL_INSTR(ILLEGAL_INSTR),
        .MISALIGNED_INSTR(BRANCH_TAKEN & NEXT_PC[1]),
        .MISALIGNED_LOAD(MISALIGNED_LOAD),
        .MISALIGNED_STORE(MISALIGNED_STORE),
        
        .OPCODE_6_TO_2(OPCODE[6:2]),
        .FUNCT3(FUNCT3),
        .FUNCT7(FUNCT7),
        .RS1_ADDR(RS1_ADDR),
        .RS2_ADDR(RS2_ADDR),
        .RD_ADDR(RD_ADDR),
        
        .E_IRQ(E_IRQ),
        .T_IRQ(T_IRQ),
        .S_IRQ(S_IRQ),
        
        .I_OR_E(I_OR_E),
        .SET_CAUSE(SET_CAUSE),
        .CAUSE(CAUSE_IN),
        .SET_EPC(SET_EPC),
        .INSTRET_INC(INSTRET_INC),
        .MIE_CLEAR(MIE_CLEAR),
        .MIE_SET(MIE_SET),
        .MISALIGNED_EXCEPTION(MISALIGNED_EXCEPTION),
        .MIE(MIE),
        .MEIE(MEIE_OUT),
        .MTIE(MTIE_OUT),
        .MSIE(MSIE_OUT),
        .MEIP(MEIP_OUT),
        .MTIP(MTIP_OUT),
        .MSIP(MSIP_OUT),
        
        .PC_SRC(PC_SRC),
        
        .FLUSH(FLUSH),
        
        .TRAP_TAKEN(TRAP_TAKEN)

    );        
    
    // Stages 1/2 interface registers
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            RD_ADDR_reg <= 5'b00000;
            CSR_ADDR_reg <= 12'b000000000000;
            RS1_reg <= 32'h00000000;
            RS2_reg <= 32'h00000000;
            PC_reg <= BOOT_ADDRESS;
            PC_PLUS_4_reg <= 32'h00000000;
            IADDER_OUT_reg <= 32'h00000000;
            ALU_OPCODE_reg <= 4'b0000;
            LOAD_SIZE_reg <= 2'b00;
            LOAD_UNSIGNED_reg <= 1'b0;
            ALU_SRC_reg <= 1'b0;
            CSR_WR_EN_reg <= 1'b0;
            RF_WR_EN_reg <= 1'b0;
            WB_MUX_SEL_reg <= `WB_ALU;
            CSR_OP_reg <= 3'b000;
            IMM_reg <= 32'h00000000;
        end
        else
        begin
            RD_ADDR_reg <= RD_ADDR;
            CSR_ADDR_reg <= CSR_ADDR;
            RS1_reg <= RS1;
            RS2_reg <= RS2;
            PC_reg <= PC;
            PC_PLUS_4_reg <= PC_PLUS_4;
            IADDER_OUT_reg[31:1] <= IADDER_OUT[31:1];
            IADDER_OUT_reg[0] <= BRANCH_TAKEN ? 1'b0 : IADDER_OUT[0];
            ALU_OPCODE_reg <= ALU_OPCODE;
            LOAD_SIZE_reg <= LOAD_SIZE;
            LOAD_UNSIGNED_reg <= LOAD_UNSIGNED;
            ALU_SRC_reg <= ALU_SRC;
            CSR_WR_EN_reg <= CSR_WR_EN;
            RF_WR_EN_reg <= RF_WR_EN;
            WB_MUX_SEL_reg <= WB_MUX_SEL;
            CSR_OP_reg <= CSR_OP;
            IMM_reg <= IMM;
        end
    end
    
    // ---------------------------------
    // PIPELINE STAGE 3
    // ---------------------------------
    
    load_unit lu(
    
        .LOAD_SIZE(LOAD_SIZE_reg),
        .LOAD_UNSIGNED(LOAD_UNSIGNED_reg),
        .DATA_IN(DATA_IN),
        .IADDER_OUT_1_TO_0(IADDER_OUT_reg[1:0]),
        .OUTPUT(LU_OUTPUT)
    
    );
    
    wire [31:0] alu_2nd_src_mux;
    assign alu_2nd_src_mux = ALU_SRC_reg ? RS2_reg : IMM_reg;
    
    alu alu(
    
        .OP_1(RS1_reg),
        .OP_2(alu_2nd_src_mux),
        .OPCODE(ALU_OPCODE_reg),
        .RESULT(ALU_RESULT)

    );    
    
    always @*
    begin
        case (WB_MUX_SEL_reg)
            `WB_ALU:        WB_MUX_OUT = ALU_RESULT;
            `WB_LU:         WB_MUX_OUT = LU_OUTPUT;
            `WB_IMM:        WB_MUX_OUT = IMM_reg;
            `WB_IADDER_OUT: WB_MUX_OUT = IADDER_OUT_reg;
            `WB_CSR:        WB_MUX_OUT = CSR_DATA;
            `WB_PC_PLUS:    WB_MUX_OUT = PC_PLUS_4_reg;
            default:        WB_MUX_OUT = ALU_RESULT;
        endcase
    end
    
    // ---------------------------------
    // OUTPUT ASSIGNMENTS
    // ---------------------------------
    
    assign I_ADDR = RESET ? BOOT_ADDRESS : PC_MUX_OUT;
    assign WR_REQ = SU_WR_REQ;
    assign WR_MASK = SU_WR_MASK;
    assign D_ADDR = SU_D_ADDR;
    assign DATA_OUT = SU_DATA_OUT;
    
endmodule
