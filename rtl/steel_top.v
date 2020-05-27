//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 30.04.2020 02:39:50
// Module Name: steel_top
// Project Name: Steel Core 
// Description: RISC-V Steel Core top module 
// 
// Dependencies: globals.vh
//               machine_control.v
//               alu.v
//               integer_file.v
//               branch_unit.v
//               control_unit.v
//               csr_file.v
//               imm_generator.v
//               load_unit.v
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "globals.vh"

module steel_top(

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
    wire [31:0] PC_PLUS;
    reg [31:0] PC_PLUS_reg;
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
    wire RESET_OR_FLUSH;
    
    // ---------------------------------
    // PIPELINE STAGE 1
    // ---------------------------------
    
    // PC MUX
    
    reg [31:0] PC_MUX_OUT;
    always @*
    begin
        case (PC_SRC)
            `BOOT:      PC_MUX_OUT = `BOOT_ADDRESS;
            `EPC:       PC_MUX_OUT = EPC;
            `TRAP:      PC_MUX_OUT = TRAP_ADDRESS;
            `OPERATING: PC_MUX_OUT = PC_PLUS;
        endcase
    end
    
    // PC Adder and Multiplexer
    wire [31:0] pc_adder;
    assign pc_adder = PC + 32'h00000004;
    assign PC_PLUS = BRANCH_TAKEN ? IADDER_OUT : pc_adder;
    
    // Program Counter (PC) register
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET) PC <= `BOOT_ADDRESS;
        else PC <= PC_MUX_OUT;
    end
    
    // ---------------------------------
    // PIPELINE STAGE 2
    // ---------------------------------
    
    assign OPCODE = INSTR[6:0];
    assign FUNCT3 = INSTR[14:12];
    assign FUNCT7 = INSTR[31:25];
    
    control_unit ctrlunit(
    
        .OPCODE(OPCODE),
        .FUNCT7_5(FUNCT7[5]),
        .FUNCT3(FUNCT3),
        
        .ALU_OPCODE(ALU_OPCODE),
        .MEM_WR_REQ(MEM_WR_REQ),
        .MEM_WR_MASK(MEM_WR_MASK),
        .LOAD_SIZE(LOAD_SIZE),
        .LOAD_UNSIGNED(LOAD_UNSIGNED),
        .ALU_SRC(ALU_SRC),
        .IADDER_SRC(IADDER_SRC),
        .CSR_WR_EN(CSR_WR_EN),
        .RF_WR_EN(RF_WR_EN),
        .WB_MUX_SEL(WB_MUX_SEL),
        .IMM_TYPE(IMM_TYPE),
        .CSR_OP(CSR_OP),
        .ILLEGAL_INSTR(ILLEGAL_INSTR)
        
    );
    
    imm_generator immgen(
    
        .INSTR(INSTR[31:7]),
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
    
    assign RS1_ADDR = INSTR[19:15];
    assign RS2_ADDR = INSTR[24:20];
    assign RD_ADDR = INSTR[11:7];
    
    integer_file irf(
    
        .CLK(CLK),
        .RESET(RESET),
        
        .RS_1_ADDR(RS1_ADDR),
        .RS_2_ADDR(RS2_ADDR),    
        .RS_1(RS1),
        .RS_2(RS2),
        
        .RD_ADDR(RD_ADDR_reg),
        .WR_EN(RF_WR_EN_reg),
        .RD(WB_MUX_OUT)

    );
    
    assign CSR_ADDR = INSTR[31:20]; 
    
    csr_file csrf(

        .CLK(CLK),
        .RESET(RESET),
        
        .WR_EN(CSR_WR_EN_reg),
        .CSR_ADDR(CSR_ADDR_reg),
        .CSR_OP(CSR_OP_reg),
        .CSR_UIMM(IMM_reg[4:0]),
        .CSR_DATA_IN(RS1_reg),
        .CSR_DATA_OUT(CSR_DATA),
        
        .PC(PC),
        
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
        .MISALIGNED_INSTR(PC_MUX_OUT[1] | PC_MUX_OUT[0]),
        
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
        .MIE(MIE),
        .MEIE(MEIE_OUT),
        .MTIE(MTIE_OUT),
        .MSIE(MSIE_OUT),
        .MEIP(MEIP_OUT),
        .MTIP(MTIP_OUT),
        .MSIP(MSIP_OUT),
        
        .PC_SRC(PC_SRC),
        
        .FLUSH(FLUSH)

    );
    
    assign RESET_OR_FLUSH = RESET | FLUSH;    
    
    // Stages 1/2 interface registers
    always @(posedge CLK or posedge RESET_OR_FLUSH)
    begin
        if(RESET_OR_FLUSH)
        begin
            RD_ADDR_reg <= 5'b00000;
            CSR_ADDR_reg <= 12'b000000000000;
            RS1_reg <= 32'h00000000;
            RS2_reg <= 32'h00000000;
            PC_PLUS_reg <= 32'h00000000;
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
            PC_PLUS_reg <= PC_PLUS;
            IADDER_OUT_reg <= IADDER_OUT;
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
            `WB_PC_PLUS:    WB_MUX_OUT = PC_PLUS_reg;
            default:        WB_MUX_OUT = ALU_RESULT;
        endcase
    end
    
    // ---------------------------------
    // OUTPUT ASSIGNMENTS
    // ---------------------------------
    
    assign I_ADDR = PC_MUX_OUT;
    assign WR_REQ = MEM_WR_REQ;
    assign WR_MASK = MEM_WR_MASK;
    assign D_ADDR = IADDER_OUT;
    assign DATA_OUT = RS2;
    
endmodule
