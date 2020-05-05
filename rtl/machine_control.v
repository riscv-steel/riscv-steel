//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 26.04.2020 23:18:08
// Module Name: machine_control
// Project Name: Steel Core 
// Description: Controls the M-mode operation 
// 
// Dependencies: -
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "globals.vh"

module machine_control(

    input wire CLK,
    input wire RESET,
    
    // from control unit
    input wire ILLEGAL_INSTR,
    
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
    
    // to PC MUX
    output reg [1:0] PC_SRC,
    
    // to pipeline stage 2 register
    output reg STALL

    );
    
    // state registers
    reg [3:0] curr_state;
    reg [3:0] next_state;
    
    // machine states
    parameter STATE_RESET         = 2'b00; 
    parameter STATE_OPERATING     = 2'b01;
    parameter STATE_TRAP_TAKEN    = 2'b10;    
    parameter STATE_TRAP_RETURN   = 2'b11;
    
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
    wire RS2_ADDR_wfi;
    wire RS2_ADDR_mret;
    wire RS2_ADDR_ebreak;
    wire FUNCT3_zero;
    wire FUNCT7_zero;
    wire FUNCT7_wfi;
    wire FUNCT7_mret;
    wire wfi;
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
    assign wfi = is_system & FUNCT7_wfi & RS2_ADDR_wfi & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    assign mret = is_system & FUNCT7_mret & RS2_ADDR_mret & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    assign ecall = is_system & FUNCT7_zero & RS2_ADDR_zero & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    assign ebreak = is_system & FUNCT7_zero & RS2_ADDR_ebreak & RS1_ADDR_zero & FUNCT3_zero & rd_zero;
    
    assign eip = MEIE & (E_IRQ | MEIP);
    assign tip = MTIE & (T_IRQ | MTIP);
    assign sip = MSIE & (S_IRQ | MSIP);
    assign ip = eip | tip | sip;
    assign exception = ILLEGAL_INSTR | MISALIGNED_INSTR;
    
    always @*
    begin
        case(curr_state)
            STATE_RESET:
                next_state = STATE_OPERATING;
            STATE_OPERATING: 
                if((MIE & ip) | exception | ecall | ebreak) next_state = STATE_TRAP_TAKEN;
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
                    PC_SRC = `BOOT;
                    STALL = 1'b1;
                    INSTRET_INC = 1'b0;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b0;
                end
            STATE_OPERATING:
                begin
                    PC_SRC = `OPERATING;
                    STALL = 1'b0;
                    INSTRET_INC = 1'b1;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b0;
                end
            STATE_TRAP_TAKEN:
                begin
                    PC_SRC = `TRAP;
                    STALL = 1'b1;
                    INSTRET_INC = 1'b0;
                    SET_EPC = 1'b1;
                    SET_CAUSE = 1'b1;
                    MIE_CLEAR = 1'b1;
                    MIE_SET = 1'b0;
                end
            STATE_TRAP_RETURN:
                begin
                    PC_SRC = `EPC;
                    STALL = 1'b1;
                    INSTRET_INC = 1'b0;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b1;
                end
            default:
                begin
                    PC_SRC = `OPERATING;
                    STALL = 1'b0;
                    INSTRET_INC = 1'b1;
                    SET_EPC = 1'b0;
                    SET_CAUSE = 1'b0;
                    MIE_CLEAR = 1'b0;
                    MIE_SET = 1'b0;
                end
        endcase
        
    end
    
    // SEQUENTIAL LOGIC -------------------------------------------
    
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET) curr_state <= STATE_RESET;
        else curr_state <= next_state;
    end    
    
    always @(posedge CLK or posedge RESET)
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
        end        
    end
    
endmodule
