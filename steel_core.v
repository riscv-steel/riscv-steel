//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 30.04.2020 02:39:50
// Module Name: steel_core_top
// Project Name: Steel Core 
// Description: Steel Core top module 
// 
// Dependencies: None
// 
// Version 2.00
// 
//////////////////////////////////////////////////////////////////////////////////

/*********************************************************************************

MIT License

Copyright (c) 2020 Rafael de Oliveira Calcada

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

// CSR registers reset values

`define MCYCLE_RESET        32'h00000000
`define TIME_RESET          32'h00000000
`define MINSTRET_RESET      32'h00000000
`define MCYCLEH_RESET       32'h00000000
`define TIMEH_RESET         32'h00000000
`define MINSTRETH_RESET     32'h00000000
`define MTVEC_RESET         32'h00000000
`define MSCRATCH_RESET      32'h00000000
`define MEPC_RESET          32'h00000000
`define MCOUNTINHIBIT_CY_RESET  1'b0 
`define MCOUNTINHIBIT_IR_RESET  1'b0

// Implemented instructions opcodes

`define NOP_INSTR           32'h00000013
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

// CSR File operation encoding

`define CSR_NOP            2'b00
`define CSR_RW             2'b01
`define CSR_RS             2'b10
`define CSR_RC             2'b11

// CSR ADDRESSES ----------------------------

// Machine Information Registers
`define MARCHID         12'hF12
`define MIMPID          12'hF13

// Performance Counters
`define CYCLE           12'hC00
`define TIME            12'hC01
`define INSTRET         12'hC02
`define CYCLEH          12'hC80
`define TIMEH           12'hC81
`define INSTRETH        12'hC82

// Machine Trap Setup
`define MSTATUS         12'h300
`define MISA            12'h301
`define MIE             12'h304
`define MTVEC           12'h305

// Machine Trap Handling
`define MSCRATCH        12'h340
`define MEPC            12'h341
`define MCAUSE          12'h342
`define MTVAL           12'h343
`define MIP             12'h344

// Machine Counter / Timers
`define MCYCLE          12'hB00
`define MINSTRET        12'hB02
`define MCYCLEH         12'hB80
`define MINSTRETH       12'hB82

// Machine Counter Setup
`define MCOUNTINHIBIT   12'h320

module steel_core_top #(

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
    
    // Stages 2/3 interface registers
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

module imm_generator(
    
    input wire [31:7] INSTR,
    input wire [2:0] IMM_TYPE,
    output reg [31:0] IMM
    
    );
    
    wire [31:0] i_type;
    wire [31:0] s_type;
    wire [31:0] b_type;
    wire [31:0] u_type;
    wire [31:0] j_type;
    wire [31:0] csr_type;
    
    assign i_type = { {20{INSTR[31]}}, INSTR[31:20] };
    assign s_type = { {20{INSTR[31]}}, INSTR[31:25], INSTR[11:7] };
    assign b_type = { {19{INSTR[31]}}, INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8], 1'b0 };
    assign u_type = { INSTR[31:12], 12'h000 };
    assign j_type = { {11{INSTR[31]}}, INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21], 1'b0 };
    assign csr_type = { 27'b0, INSTR[19:15] };
    
    always @(*)
    begin
       case (IMM_TYPE)
           3'b000: IMM = i_type; 
           `I_TYPE: IMM = i_type;
           `S_TYPE: IMM = s_type;
           `B_TYPE: IMM = b_type;
           `U_TYPE: IMM = u_type;
           `J_TYPE: IMM = j_type;
           `CSR_TYPE: IMM = csr_type;
           3'b111: IMM = i_type;
       endcase
    end
    
endmodule

module store_unit(

    input wire [1:0] FUNCT3,
    input wire [31:0] IADDER_OUT, 
    input wire [31:0] RS2,
    input wire MEM_WR_REQ,
    output reg [31:0] DATA_OUT,
    output wire [31:0] D_ADDR,
    output reg [3:0] WR_MASK,
    output wire WR_REQ
    
    );   
    
    reg [3:0] half_wr_mask;
    reg [3:0] byte_wr_mask;
    reg [31:0] half_dout;
    reg [31:0] byte_dout;
    
    assign D_ADDR = {IADDER_OUT[31:2], 2'b0};
    assign WR_REQ = MEM_WR_REQ;
    
    always @*
    begin
    
        case(FUNCT3[1:0])
        
            2'b00: WR_MASK = byte_wr_mask;
            2'b01: WR_MASK = half_wr_mask;
            2'b10: WR_MASK = {4{MEM_WR_REQ}};
            2'b11: WR_MASK = {4{MEM_WR_REQ}};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(FUNCT3[1:0])
        
            2'b00: DATA_OUT = byte_dout;
            2'b01: DATA_OUT = half_dout;
            2'b10: DATA_OUT = RS2;
            2'b11: DATA_OUT = RS2;
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1:0])
        
            2'b00: byte_dout = {24'b0, RS2[7:0]};
            2'b01: byte_dout = {16'b0, RS2[7:0], 8'b0};
            2'b10: byte_dout = {8'b0, RS2[7:0], 16'b0};
            2'b11: byte_dout = {RS2[7:0], 24'b0};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1:0])
        
            2'b00: byte_wr_mask = {3'b0, MEM_WR_REQ};
            2'b01: byte_wr_mask = {2'b0, MEM_WR_REQ, 1'b0};
            2'b10: byte_wr_mask = {1'b0, MEM_WR_REQ, 2'b0};
            2'b11: byte_wr_mask = {MEM_WR_REQ, 3'b0};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1])
        
            1'b0: half_dout = {16'b0, RS2[15:0]};
            1'b1: half_dout = {RS2[15:0], 16'b0};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1])
        
            1'b0: half_wr_mask = {2'b0, {2{MEM_WR_REQ}}};
            1'b1: half_wr_mask = {{2{MEM_WR_REQ}}, 2'b0};
            
        endcase
    
    end
                                                                
endmodule

module csr_file(

    input wire CLK,
    input wire RESET,
    
    input wire WR_EN,
    input wire [11:0] CSR_ADDR,
    input wire [2:0] CSR_OP,
    input wire [4:0] CSR_UIMM,
    input wire [31:0] CSR_DATA_IN,
    output reg [31:0] CSR_DATA_OUT,
    
    // from pipeline stage 1
    input wire [31:0] PC,
    
    // from pipeline stage 3
    input wire [31:0] IADDER_OUT,
    
    // interface with CLIC
    input wire E_IRQ,
    input wire T_IRQ,
    input wire S_IRQ,
    
    // interface with Machine Control Module
    input wire I_OR_E,
    input wire SET_CAUSE,
    input wire [3:0] CAUSE_IN,
    input wire SET_EPC,
    input wire INSTRET_INC,
    input wire MIE_CLEAR,
    input wire MIE_SET,
    input wire MISALIGNED_EXCEPTION,
    output reg MIE,
    output wire MEIE_OUT,
    output wire MTIE_OUT,
    output wire MSIE_OUT,
    output wire MEIP_OUT,
    output wire MTIP_OUT,
    output wire MSIP_OUT,
    
    // platform real time CLK value
    input wire [63:0] REAL_TIME,
    
    // these two outputs are connected to the PC MUX
    output wire [31:0] EPC_OUT,
    output wire [31:0] TRAP_ADDRESS

    );

    // Machine trap setup
    wire [31:0] mstatus; // machine status register
    wire [31:0] misa; // machine ISA register
    wire [31:0] mie_reg; // machine interrupt enable register
    wire [31:0] mtvec;
    wire [1:0] mxl; // machine XLEN
    wire [25:0] mextensions; // ISA extensions
    reg [1:0] mtvec_mode; // machine trap mode
    reg [29:0] mtvec_base; // machine trap base address
    reg mpie; // mach. prior interrupt enable
    reg meie; // mach. external interrupt enable
    reg mtie; // mach. timer interrupt enable
    reg msie; // mach. software interrupt enable

    // Machine trap handling
    reg [31:0] mscratch; // machine scratch register
    reg [31:0] mepc; // machine exception program counter
    reg [31:0] mtval; // machine trap value register
    wire [31:0] mcause; // machine trap cause register
    wire [31:0] mip_reg; // machine interrupt pending register
    reg int_or_exc; // interrupt or exception signal
    reg [3:0] cause; // interrupt cause
    reg [26:0] cause_rem; // remaining bits of mcause register 
    reg meip; // mach. external interrupt pending
    reg mtip; // mach. timer interrupt pending
    reg msip; // mach. software interrupt pending

    // Machine counters
    reg [63:0] mcycle;
    reg [63:0] mtime;
    reg [63:0] minstret;

    // Machine counters setup
    wire [31:0] mcountinhibit;
    reg mcountinhibit_cy;
    reg mcountinhibit_ir;

    // CSR operation control
    // ----------------------------------------------------------------------------

    reg [31:0] data_wr;
    wire [31:0] pre_data;

    assign pre_data = CSR_OP[2] == 1'b1 ? {27'b0, CSR_UIMM} : CSR_DATA_IN;

    always @*
    begin
        case(CSR_OP[1:0])
            `CSR_RW: data_wr <= pre_data;
            `CSR_RS: data_wr <= CSR_DATA_OUT | pre_data;
            `CSR_RC: data_wr <= CSR_DATA_OUT & ~pre_data;
            `CSR_NOP: data_wr <= CSR_DATA_OUT;
        endcase
    end

    always @*
    begin
        case(CSR_ADDR)
            `MARCHID:       CSR_DATA_OUT = 32'h00000018; // Decimal value: 24
            `MIMPID:        CSR_DATA_OUT = 32'h00000001; // First version
            `CYCLE:         CSR_DATA_OUT = mcycle[31:0];
            `CYCLEH:        CSR_DATA_OUT = mcycle[63:32];
            `TIME:          CSR_DATA_OUT = mtime[31:0];
            `TIMEH:         CSR_DATA_OUT = mtime[63:32];
            `INSTRET:       CSR_DATA_OUT = minstret[31:0];
            `INSTRETH:      CSR_DATA_OUT = minstret[63:32];
            `MSTATUS:       CSR_DATA_OUT = mstatus;
            `MISA:          CSR_DATA_OUT = misa;
            `MIE:           CSR_DATA_OUT = mie_reg;
            `MTVEC:         CSR_DATA_OUT = mtvec;
            `MSCRATCH:      CSR_DATA_OUT = mscratch;
            `MEPC:          CSR_DATA_OUT = mepc;
            `MCAUSE:        CSR_DATA_OUT = mcause;
            `MTVAL:         CSR_DATA_OUT = mtval;
            `MIP:           CSR_DATA_OUT = mip_reg;
            `MCYCLE:        CSR_DATA_OUT = mcycle[31:0];
            `MCYCLEH:       CSR_DATA_OUT = mcycle[63:32];
            `MINSTRET:      CSR_DATA_OUT = minstret[31:0];
            `MINSTRETH:     CSR_DATA_OUT = minstret[63:32];
            `MCOUNTINHIBIT: CSR_DATA_OUT = mcountinhibit;
            default:        CSR_DATA_OUT = 32'b0;
        endcase
    end

    // MSTATUS register
    //                       MPP           
    assign mstatus = {19'b0, 2'b11, 3'b0, mpie, 3'b0 , MIE, 3'b0};
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            MIE <= 1'b0;
            mpie <= 1'b1;
        end
        else if(CSR_ADDR == `MSTATUS && WR_EN)
        begin
            MIE <= data_wr[3];
            mpie <= data_wr[7];
        end
        else if(MIE_CLEAR == 1'b1)
        begin
            mpie <= MIE;
            MIE <= 1'b0;
        end
        else if(MIE_SET == 1'b1)
        begin
            MIE <= mpie;
            mpie <= 1'b1;
        end
    end

    // MISA register
    assign mxl = 2'b01;
    assign mextensions = 26'b00000000000000000100000000;
    assign misa = {mxl, 4'b0, mextensions};

    // MIE register
    assign mie_reg = {20'b0, meie, 3'b0, mtie, 3'b0, msie, 3'b0};
    assign MEIE_OUT = meie;
    assign MTIE_OUT = mtie;
    assign MSIE_OUT = msie;
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            meie <= 1'b0;
            mtie <= 1'b0;
            msie <= 1'b0;
        end
        else if(CSR_ADDR == `MIE && WR_EN)
        begin            
            meie <= data_wr[11];
            mtie <= data_wr[7];
            msie <= data_wr[3];
        end
    end
    
    // MTVEC register
    assign mtvec = {mtvec_base, mtvec_mode};
    wire [31:0] trap_mux_out;
    wire [31:0] vec_mux_out;
    wire [31:0] base_offset;
    wire [31:0] mtvec_reset_value = `MTVEC_RESET;
    assign base_offset = CAUSE_IN << 2;
    assign trap_mux_out = I_OR_E ? vec_mux_out : {mtvec_base, 2'b00};
    assign vec_mux_out = mtvec[0] ? {mtvec_base, 2'b00} + base_offset : {mtvec_base, 2'b00};
    assign TRAP_ADDRESS = trap_mux_out;
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            mtvec_mode <= mtvec_reset_value[1:0];
            mtvec_base <= mtvec_reset_value[31:2];
        end
        else if(CSR_ADDR == `MTVEC && WR_EN)
        begin            
            mtvec_mode <= data_wr[1:0];
            mtvec_base <= data_wr[31:2];
        end
    end
    
    // MSCRATCH register
    always @(posedge CLK)
    begin
        if(RESET) mscratch <= `MSCRATCH_RESET;
        else if(CSR_ADDR == `MSCRATCH && WR_EN) mscratch <= data_wr;
    end
    
    // MEPC register
    assign EPC_OUT = mepc;
    always @(posedge CLK)
    begin
        if(RESET) mepc <= `MEPC_RESET;
        else if(SET_EPC) mepc <= PC;
        else if(CSR_ADDR == `MEPC && WR_EN) mepc <= {data_wr[31:2], 2'b00};
    end

    // MCAUSE register
    assign mcause = {int_or_exc, cause_rem, cause};
    always @(posedge CLK)
    begin
        if(RESET) 
        begin
            cause <= 4'b0000;
            cause_rem <= 27'b0;
            int_or_exc <= 1'b0;
        end
        else if(SET_CAUSE)
        begin
            cause <= CAUSE_IN;
            cause_rem <= 27'b0;
            int_or_exc <= I_OR_E;
        end
        else if(CSR_ADDR == `MCAUSE && WR_EN)
        begin
            cause <= data_wr[3:0];
            cause_rem <= data_wr[30:4];
            int_or_exc <= data_wr[31];
            
        end
    end
    
    // MIP register
    assign mip_reg = {20'b0, meip, 3'b0, mtip, 3'b0, msip, 3'b0};
    assign MEIP_OUT = meip;
    assign MTIP_OUT = mtip;
    assign MSIP_OUT = msip;
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            meip <= 1'b0;
            mtip <= 1'b0;
            msip <= 1'b0;
        end
        else
        begin
            meip <= E_IRQ;
            mtip <= T_IRQ;
            msip <= S_IRQ;
        end
    end    
    
    // MTVAL register
    always @(posedge CLK)
    begin
        if(RESET) mtval <= 32'b0;
        else if(SET_CAUSE)
        begin
            if(MISALIGNED_EXCEPTION) mtval <= IADDER_OUT;
            else mtval <= 32'b0;
        end
        else if(CSR_ADDR == `MTVAL && WR_EN) mtval <= data_wr;
    end
    
    // MCOUNTINHIBIT register
    assign mcountinhibit = {29'b0, mcountinhibit_ir, 1'b0, mcountinhibit_cy};
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            mcountinhibit_cy <= `MCOUNTINHIBIT_CY_RESET;
            mcountinhibit_ir <= `MCOUNTINHIBIT_IR_RESET;
        end
        else if(CSR_ADDR == `MCOUNTINHIBIT && WR_EN)
        begin
            mcountinhibit_cy <= data_wr[2];
            mcountinhibit_ir <= data_wr[0]; 
        end
    end
    
    // Counters
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            mcycle <= {`MCYCLEH_RESET, `MCYCLE_RESET};
            minstret <= {`MINSTRETH_RESET, `MINSTRET_RESET};
            mtime <= {`TIMEH_RESET, `TIME_RESET};
        end
        else
        begin
            mtime <= REAL_TIME;
            
            if(CSR_ADDR == `MCYCLE && WR_EN)
            begin
                if(mcountinhibit_cy == 1'b0) mcycle <= {mcycle[63:32], data_wr} + 1;
                else mcycle <= {mcycle[63:32], data_wr};
            end
            else if(CSR_ADDR == `MCYCLEH && WR_EN)
            begin
                if(mcountinhibit_cy == 1'b0) mcycle <= {data_wr, mcycle[31:0]} + 1;
                else mcycle <= {data_wr, mcycle[31:0]};
            end
            else
            begin
                if(mcountinhibit_cy == 1'b0) mcycle <= mcycle + 1;
                else mcycle <= mcycle;
            end
            
            if(CSR_ADDR == `MINSTRET && WR_EN)
            begin
                if(mcountinhibit_ir == 1'b0) minstret <= {minstret[63:32], data_wr} + INSTRET_INC;
                else minstret <= {minstret[63:32], data_wr};
            end
            else if(CSR_ADDR == `MINSTRETH && WR_EN)
            begin
                if(mcountinhibit_ir == 1'b0) minstret <= {data_wr, minstret[31:0]} + INSTRET_INC;
                else minstret <= {data_wr, minstret[31:0]};
            end
            else
            begin
                if(mcountinhibit_ir == 1'b0) minstret <= minstret + INSTRET_INC;
                else minstret <= minstret;
            end
            
        end
    end 
    
endmodule

module integer_file(
    
    input wire CLK,
    
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
    
    wire [31:0] rs1_wire;
    wire [31:0] rs2_wire;  
    wire [31:1] enable;
    wire fwd_op1_enable;
    wire fwd_op2_enable;
    wire op1_zero;
    wire op2_zero;
    wire [31:0] reg_en;
    reg [31:0] rs1_reg;
    reg [31:0] rs2_reg;
    wire rs1_addr_is_x0;
    wire rs2_addr_is_x0;
    reg [31:0] Q [31:1];
    
    integer i;
    
    initial
    begin
        for(i = 1; i < 32; i = i+1) Q[i] <= 32'b0;
    end     
    
    always @(posedge CLK)
        if(WR_EN) Q[RD_ADDR] <= RD;
    
    assign rs1_addr_is_x0 = RS_1_ADDR == 5'b00000;
    assign rs2_addr_is_x0 = RS_2_ADDR == 5'b00000;
    assign fwd_op1_enable = (RS_1_ADDR == RD_ADDR && WR_EN == 1'b1) ? 1'b1 : 1'b0;
    assign fwd_op2_enable = (RS_2_ADDR == RD_ADDR && WR_EN == 1'b1) ? 1'b1 : 1'b0;
    assign op1_zero = rs1_addr_is_x0 == 1'b1 ? 1'b1 : 1'b0;
    assign op2_zero = rs2_addr_is_x0 == 1'b1 ? 1'b1 : 1'b0;
    assign rs1_wire = fwd_op1_enable == 1'b1 ? RD : Q[RS_1_ADDR];
    assign rs2_wire = fwd_op2_enable == 1'b1 ? RD : Q[RS_2_ADDR];
    assign RS_1 = op1_zero == 1'b1 ? 32'h00000000 : rs1_wire;
    assign RS_2 = op2_zero == 1'b1 ? 32'h00000000 : rs2_wire;
    
endmodule

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

module load_unit(

    input wire [1:0] LOAD_SIZE,
    input wire LOAD_UNSIGNED,
    input wire [31:0] DATA_IN,
    input wire [1:0] IADDER_OUT_1_TO_0,
    output reg [31:0] OUTPUT
    
    );    
    
    reg [7:0] byte;
    reg [15:0] half;    
    wire [23:0] byte_ext;
    wire [15:0] half_ext;
    
    always @*
    begin
    
        case(LOAD_SIZE)
        
            2'b00: OUTPUT = {byte_ext, byte};
            2'b01: OUTPUT = {half_ext, half};
            2'b10: OUTPUT = DATA_IN;
            2'b11: OUTPUT = DATA_IN;
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT_1_TO_0)
        
            2'b00: byte = DATA_IN[7:0];
            2'b01: byte = DATA_IN[15:8];
            2'b10: byte = DATA_IN[23:16];
            2'b11: byte = DATA_IN[31:24];
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT_1_TO_0[1])
        
            1'b0: half = DATA_IN[15:0];
            1'b1: half = DATA_IN[31:16];
            
        endcase
    
    end
    
    assign byte_ext = LOAD_UNSIGNED == 1'b1 ? 24'b0 : {24{byte[7]}};
    assign half_ext = LOAD_UNSIGNED == 1'b1 ? 16'b0 : {16{half[15]}};
                                                                
endmodule

module machine_control(

    input wire CLK,
    input wire RESET,
    
    // from control unit
    input wire ILLEGAL_INSTR,
    input wire MISALIGNED_LOAD,
    input wire MISALIGNED_STORE,
    
    // from pipeline stage 1
    input wire MISALIGNED_INSTR,
    
    // from instruction
    input wire [6:2] OPCODE_6_TO_2,
    input wire [2:0] FUNCT3,
    input wire [6:0] FUNCT7,
    input wire [4:0] RS1_ADDR,
    input wire [4:0] RS2_ADDR,
    input wire [4:0] RD_ADDR,
    
    // from interrupt controller
    input wire E_IRQ,
    input wire T_IRQ,
    input wire S_IRQ,

    // from CSR file
    input wire MIE,
    input wire MEIE,
    input wire MTIE,
    input wire MSIE,
    input wire MEIP,
    input wire MTIP,
    input wire MSIP,         
    
    // to CSR file
    output reg I_OR_E,
    output reg SET_EPC,
    output reg SET_CAUSE,
    output reg [3:0] CAUSE,
    output reg INSTRET_INC,
    output reg MIE_CLEAR,
    output reg MIE_SET,
    output reg MISALIGNED_EXCEPTION,
    
    // to PC MUX
    output reg [1:0] PC_SRC,
    
    // to pipeline stage 2 register
    output reg FLUSH,
    
    // to Control Unit
    output wire TRAP_TAKEN

    );
    
    // state registers
    reg [3:0] curr_state;
    reg [3:0] next_state;
    
    // machine states
    parameter STATE_RESET         = 4'b0001; 
    parameter STATE_OPERATING     = 4'b0010;
    parameter STATE_TRAP_TAKEN    = 4'b0100;    
    parameter STATE_TRAP_RETURN   = 4'b1000;
    
    // internal control signals
    wire exception;
    wire ip;
    wire eip;
    wire tip;
    wire sip;
    wire is_system;
    wire RS1_ADDR_zero;
    wire RS2_ADDR_zero;
    wire rd_zero;
    wire RS2_ADDR_mret;
    wire RS2_ADDR_ebreak;
    wire FUNCT3_zero;
    wire FUNCT7_zero;
    wire FUNCT7_mret;
    wire csr;
    wire mret;
    wire ecall;
    wire ebreak;
    reg pre_instret_inc;
    
    // COMBINATIONAL LOGIC -------------------------------------------
    
    assign is_system = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & OPCODE_6_TO_2[4] & ~OPCODE_6_TO_2[3] & ~OPCODE_6_TO_2[2];
    assign FUNCT3_zero = ~(FUNCT3[2] | FUNCT3[1] | FUNCT3[0]);
    assign FUNCT7_zero = ~(FUNCT7[6] | FUNCT7[5] | FUNCT7[4] | FUNCT7[3] | FUNCT7[2] | FUNCT7[1] | FUNCT7[0]);
    assign FUNCT7_wfi = ~FUNCT7[6] & ~FUNCT7[5] & ~FUNCT7[4] & FUNCT7[3] & ~FUNCT7[2] & ~FUNCT7[1] & ~FUNCT7[0];
    assign FUNCT7_mret = ~FUNCT7[6] & ~FUNCT7[5] & FUNCT7[4] & FUNCT7[3] & ~FUNCT7[2] & ~FUNCT7[1] & ~FUNCT7[0];
    assign RS1_ADDR_zero = ~(RS1_ADDR[4] | RS1_ADDR[3] | RS1_ADDR[2] | RS1_ADDR[1] | RS1_ADDR[0]);
    assign RS2_ADDR_zero = ~(RS2_ADDR[4] | RS2_ADDR[3] | RS2_ADDR[2] | RS2_ADDR[1] | RS2_ADDR[0]);
    assign rd_zero = ~(RD_ADDR[4] | RD_ADDR[3] | RD_ADDR[2] | RD_ADDR[1] | RD_ADDR[0]);
    assign RS2_ADDR_wfi = ~RS2_ADDR[4] & ~RS2_ADDR[3] & RS2_ADDR[2] & ~RS2_ADDR[1] & RS2_ADDR[0];
    assign RS2_ADDR_mret = ~RS2_ADDR[4] & ~RS2_ADDR[3] & ~RS2_ADDR[2] & RS2_ADDR[1] & ~RS2_ADDR[0];
    assign RS2_ADDR_ebreak = ~RS2_ADDR[4] & ~RS2_ADDR[3] & ~RS2_ADDR[2] & ~RS2_ADDR[1] & RS2_ADDR[0];
    assign mret = is_system & FUNCT7_mret & RS2_ADDR_mret & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    assign ecall = is_system & FUNCT7_zero & RS2_ADDR_zero & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    assign ebreak = is_system & FUNCT7_zero & RS2_ADDR_ebreak & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    
    assign eip = MEIE & (E_IRQ | MEIP);
    assign tip = MTIE & (T_IRQ | MTIP);
    assign sip = MSIE & (S_IRQ | MSIP);
    assign ip = eip | tip | sip;
    assign exception = ILLEGAL_INSTR | MISALIGNED_INSTR | MISALIGNED_LOAD | MISALIGNED_STORE;
    assign TRAP_TAKEN = (MIE & ip) | exception | ecall | ebreak;
    
    always @*
    begin
        case(curr_state)
            STATE_RESET:
                next_state = STATE_OPERATING;
            STATE_OPERATING: 
                if(TRAP_TAKEN) next_state = STATE_TRAP_TAKEN;
                else if(mret) next_state = STATE_TRAP_RETURN;
                else next_state = STATE_OPERATING;
            STATE_TRAP_TAKEN:
                next_state = STATE_OPERATING;
            STATE_TRAP_RETURN:
                next_state = STATE_OPERATING;
            default:
                next_state = STATE_OPERATING;
        endcase
    end
    
    // output generation
    always @*
    begin
        case(curr_state)
            STATE_RESET:
                begin
                    PC_SRC = `PC_BOOT;
                    FLUSH = 1'b1;
                    INSTRET_INC = 1'b0;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b0;
                end
            STATE_OPERATING:
                begin
                    PC_SRC = `PC_NEXT;
                    FLUSH = 1'b0;
                    INSTRET_INC = 1'b1;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b0;
                end
            STATE_TRAP_TAKEN:
                begin
                    PC_SRC = `PC_TRAP;
                    FLUSH = 1'b1;
                    INSTRET_INC = 1'b0;
                    SET_EPC = 1'b1;
                    SET_CAUSE = 1'b1;
                    MIE_CLEAR = 1'b1;
                    MIE_SET = 1'b0;
                end
            STATE_TRAP_RETURN:
                begin
                    PC_SRC = `PC_EPC;
                    FLUSH = 1'b1;
                    INSTRET_INC = 1'b0;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b1;
                end
            default:
                begin
                    PC_SRC = `PC_NEXT;
                    FLUSH = 1'b0;
                    INSTRET_INC = 1'b1;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b0;
                end
        endcase
        
    end
    
    // SEQUENTIAL LOGIC -------------------------------------------
    
    always @(posedge CLK)
    begin
        if(RESET) curr_state <= STATE_RESET;
        else curr_state <= next_state;
    end    
    
    always @(posedge CLK)
    begin
        if(RESET) MISALIGNED_EXCEPTION <= 1'b0;
        else MISALIGNED_EXCEPTION <= MISALIGNED_INSTR | MISALIGNED_LOAD | MISALIGNED_STORE;
    end
    
    always @(posedge CLK)
    begin
        if(RESET)
        begin
            CAUSE <= 4'b0;
            I_OR_E <= 1'b0;
        end
        else if(curr_state == STATE_OPERATING)
        begin 
            if(MIE & eip)
            begin
                CAUSE <= 4'b1011; // M-mode external interrupt
                I_OR_E <= 1'b1;
            end            
            else if(MIE & sip)
            begin
                CAUSE <= 4'b0011; // M-mode software interrupt
                I_OR_E <= 1'b1;
            end
            else if(MIE & tip)
            begin
                CAUSE <= 4'b0111; // M-mode timer interrupt
                I_OR_E <= 1'b1;
            end
            else if(ILLEGAL_INSTR)
            begin
                CAUSE <= 4'b0010; // Illegal instruction
                I_OR_E <= 1'b0;
            end
            else if(MISALIGNED_INSTR)
            begin
                CAUSE <= 4'b0000; // Instruction address misaligned
                I_OR_E <= 1'b0;
            end
            else if(ecall)
            begin
                CAUSE <= 4'b1011; // Environment call from M-mode
                I_OR_E <= 1'b0;
            end
            else if(ebreak)
            begin
                CAUSE <= 4'b0011; // Breakpoint
                I_OR_E <= 1'b0;
            end
            else if(MISALIGNED_STORE)
            begin
                CAUSE <= 4'b0110; // Store address misaligned
                I_OR_E <= 1'b0;
            end
            else if(MISALIGNED_LOAD)
            begin
                CAUSE <= 4'b0100; // Load address misaligned
                I_OR_E <= 1'b0;
            end
        end        
    end
    
endmodule
