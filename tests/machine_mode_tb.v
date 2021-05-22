//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 02.05.2020 15:45:27
// Module Name: tb_machine_mode
// Project Name: Steel Core
// Description: M-mode operation testbench
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

// CSR registers reset values

`define MCYCLE_RESET        32'h00000000
`define TIME_RESET          32'h00000000
`define MINSTRET_RESET      32'h00000000
`define MCYCLEH_RESET       32'h00000000
`define TIMEH_RESET         32'h00000000
`define MINSTRETH_RESET     32'h00000000
`define MTVEC_BASE_RESET    30'b00000000_00000000_00000000_000000
`define MTVEC_MODE_RESET    2'b00
`define MSCRATCH_RESET      32'h00000000
`define MEPC_RESET          32'h00000000
`define MCOUNTINHIBIT_CY_RESET  1'b0 
`define MCOUNTINHIBIT_IR_RESET  1'b0

// Implemented instructions opcodes

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

// CSR File operation encoding

`define CSR_NOP            2'b00
`define CSR_RW             2'b01
`define CSR_RS             2'b10
`define CSR_RC             2'b11

// CSR ADDRESSES ----------------------------

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

module machine_mode_tb();

    reg CLK;
    reg RESET;
    
    reg ILLEGAL_INSTR;
    reg MISALIGNED_INSTR;
    reg MISALIGNED_LOAD;
    reg MISALIGNED_STORE;
    
    reg [6:2] OPCODE_6_TO_2;
    reg [2:0] FUNCT3;
    reg [6:0] FUNCT7;
    reg [4:0] RS1_ADDR;
    reg [4:0] RS2_ADDR;
    reg [4:0] RD_ADDR;
    
    reg E_IRQ;
    reg T_IRQ;
    reg S_IRQ;

    reg MIE;
    reg MEIE;
    reg MTIE;
    reg MSIE;
    reg MEIP;
    reg MTIP;
    reg MSIP;         
    
    wire I_OR_E;
    wire SET_EPC;
    wire SET_CAUSE;
    wire [3:0] CAUSE;
    wire INSTRET_INC;
    wire MIE_CLEAR;
    wire MIE_SET;
    
    wire [1:0] PC_SRC;
    
    wire FLUSH;
    
    wire TRAP_TAKEN;
    
    machine_control dut(

        .CLK(CLK),
        .RESET(RESET),
        
        .ILLEGAL_INSTR(ILLEGAL_INSTR),
        .MISALIGNED_INSTR(MISALIGNED_INSTR),
        .MISALIGNED_LOAD(MISALIGNED_LOAD),
        .MISALIGNED_STORE(MISALIGNED_STORE),
        
        .OPCODE_6_TO_2(OPCODE_6_TO_2),
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
        .CAUSE(CAUSE),
        .SET_EPC(SET_EPC),
        .INSTRET_INC(INSTRET_INC),
        .MIE_CLEAR(MIE_CLEAR),
        .MIE_SET(MIE_SET),
        .MIE(MIE),
        .MEIE(MEIE),
        .MTIE(MTIE),
        .MSIE(MSIE),
        .MEIP(MEIP),
        .MTIP(MTIP),
        .MSIP(MSIP),
        
        .PC_SRC(PC_SRC),
        
        .FLUSH(FLUSH),
        
        .TRAP_TAKEN(TRAP_TAKEN)

    );
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    initial
    begin
    
        $display("Testing Machine Mode Control module...");
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        ILLEGAL_INSTR = 1'b0;
        MISALIGNED_INSTR = 1'b0;
        MISALIGNED_LOAD = 1'b0;
        MISALIGNED_STORE = 1'b0;
                
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        
        E_IRQ = 1'b0;
        T_IRQ = 1'b0;
        S_IRQ = 1'b0;
    
        MIE = 1'b0;
        MEIE = 1'b0;
        MTIE = 1'b0;
        MSIE = 1'b0;
        MEIP = 1'b0;
        MTIP = 1'b0;
        MSIP = 1'b0;
        
        $display("Testing RESET state...");
        
        #5;
        RESET = 1'b1;
        #15;
        RESET = 1'b0;
        
        if(PC_SRC != `PC_BOOT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_SET != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("RESET state values OK.");
        
        #20;
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing OPERATING state...");
        
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_SET != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("OPERATING state values OK.");
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine keeps in operating state when MIE=0 for all kinds of interrupt...");
        
        E_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        E_IRQ = 1'b0;
        
        T_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        T_IRQ = 1'b0;
        
        S_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        S_IRQ = 1'b0;
        
        $display("Test OK.");
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine changes it state when MIE=0 for all kinds of exceptions.");
        
        MIE = 1'b0;
        ILLEGAL_INSTR = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0010)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        ILLEGAL_INSTR = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MISALIGNED_INSTR = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MISALIGNED_INSTR = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end           
           
        MISALIGNED_LOAD = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0100)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MISALIGNED_LOAD = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
           
        MISALIGNED_STORE = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0110)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MISALIGNED_STORE = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
               
        OPCODE_6_TO_2 = `OPCODE_SYSTEM;
        FUNCT3 = `FUNCT3_ECALL;
        FUNCT7 = `FUNCT7_ECALL;
        RS1_ADDR = `RS1_ECALL;
        RS2_ADDR = `RS2_ECALL;
        RD_ADDR = `RD_ECALL;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b1011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE_6_TO_2 = `OPCODE_SYSTEM;
        FUNCT3 = `FUNCT3_EBREAK;
        FUNCT7 = `FUNCT7_EBREAK;
        RS1_ADDR = `RS1_EBREAK;
        RS2_ADDR = `RS2_EBREAK;
        RD_ADDR = `RD_EBREAK;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        
        $display("Test OK.");  
        
        /************************************************************
        *************************************************************
        ************************************************************/      
        
        $display("Testing if the machine keeps in operating state when MIE=1 for all types of interrupt when MTIE=0, MSIE=0 and MEIE=0...");
        
        MIE = 1'b1;
        E_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        E_IRQ = 1'b0;
        
        T_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        T_IRQ = 1'b0;
        
        S_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        S_IRQ = 1'b0;        
        
        $display("Test OK.");
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine change its state only for external interrupts in operating state when MIE=1 and MTIE=0, MSIE=0 and MEIE=1...");
        
        MIE = 1'b1;
        MEIE = 1'b1;
        E_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b1011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        E_IRQ = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        T_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        T_IRQ = 1'b0;
        
        S_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        S_IRQ = 1'b0;        
        
        MEIE = 1'b0;
        
        $display("Test OK.");
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine change its state only for timer interrupts in operating state when MIE=1 and MTIE=1, MSIE=0 and MEIE=0...");
        
        MIE = 1'b1;
        MTIE = 1'b1;
        T_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0111)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        T_IRQ = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        E_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        E_IRQ = 1'b0;
        
        S_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        S_IRQ = 1'b0;        
        
        MTIE = 1'b0;
        
        $display("Test OK.");        
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine change its state only for software interrupts in operating state when MIE=1 and MTIE=0, MSIE=1 and MEIE=0...");
        
        MIE = 1'b1;
        MSIE = 1'b1;
        S_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        S_IRQ = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        T_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        T_IRQ = 1'b0;
        
        E_IRQ = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        E_IRQ = 1'b0;        
        
        MSIE = 1'b0;
        
        $display("Test OK.");

        /************************************************************
        *************************************************************
        ************************************************************/        
        
        $display("Testing if the machine change its state only for MEIP in operating state when MIE=1 and MTIE=0, MSIE=0 and MEIE=1...");
        
        MIE = 1'b1;
        MEIE = 1'b1;
        MEIP = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b1011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MEIP = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MTIP = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MTIP = 1'b0;
        
        MSIP = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MSIP = 1'b0;        
        
        MEIE = 1'b0;
        
        $display("Test OK.");
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine change its state only for MTIP in operating state when MIE=1 and MTIE=1, MSIE=0 and MEIE=0...");
        
        MIE = 1'b1;
        MTIE = 1'b1;
        MTIP = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0111)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MTIP = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MEIP = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MEIP = 1'b0;
        
        MSIP = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MSIP = 1'b0;        
        
        MTIE = 1'b0;
        
        $display("Test OK.");        
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing if the machine change its state only for MSIP in operating state when MIE=1 and MTIE=0, MSIE=1 and MEIE=0...");
        
        MIE = 1'b1;
        MSIE = 1'b1;
        MSIP = 1'b1;
        #20;
        if(PC_SRC != `PC_TRAP)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CAUSE != 4'b0011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(I_OR_E != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MSIP = 1'b0;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MTIP = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MTIP = 1'b0;
        
        MEIP = 1'b1;
        #20;
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MEIP = 1'b0;        
        
        MSIE = 1'b0;
        
        $display("Test OK.");

        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing transition from OPERATING to TRAP RETURN...");
        
        OPCODE_6_TO_2 = `OPCODE_SYSTEM;
        FUNCT7 = `FUNCT7_MRET;       
        FUNCT3 = `FUNCT3_MRET;
        RS1_ADDR = `RS1_MRET;
        RS2_ADDR = `RS2_MRET;
        RD_ADDR = `RD_MRET;
        #20;
        
        if(PC_SRC != `PC_EPC)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_SET != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end        
        
        $display("Test OK.");
        
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        #20;
        
        /************************************************************
        *************************************************************
        ************************************************************/
        
        $display("Testing transition from TRAP RETURN to OPERATING...");
        
        if(PC_SRC != `PC_NEXT)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_CAUSE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(SET_EPC != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_CLEAR != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MIE_SET != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(FLUSH != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(INSTRET_INC != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Test OK.");
        
        $display("Testing TRAP_TAKEN signal...");
        
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE_6_TO_2 = `OPCODE_SYSTEM;
        FUNCT3 = `FUNCT3_EBREAK;
        FUNCT7 = `FUNCT7_EBREAK;
        RS1_ADDR = `RS1_EBREAK;
        RS2_ADDR = `RS2_EBREAK;
        RD_ADDR = `RD_EBREAK;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE_6_TO_2 = `OPCODE_SYSTEM;
        FUNCT3 = `FUNCT3_ECALL;
        FUNCT7 = `FUNCT7_ECALL;
        RS1_ADDR = `RS1_ECALL;
        RS2_ADDR = `RS2_ECALL;
        RD_ADDR = `RD_ECALL;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        OPCODE_6_TO_2 = `OPCODE_OP;
        FUNCT3 = `FUNCT3_ADD;
        FUNCT7 = `FUNCT7_ADD;
        RS1_ADDR = 5'b00000;
        RS2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        ILLEGAL_INSTR = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        ILLEGAL_INSTR = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MISALIGNED_INSTR = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MISALIGNED_INSTR = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MISALIGNED_LOAD = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MISALIGNED_LOAD = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MISALIGNED_STORE = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MISALIGNED_STORE = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MIE = 1'b1;
        MEIE = 1'b1;
        MTIE = 1'b1;
        MSIE = 1'b1;
        
        E_IRQ = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        E_IRQ = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        T_IRQ = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        T_IRQ = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        S_IRQ = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        S_IRQ = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MEIP = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MEIP = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MTIP = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MTIP = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MSIP = 1'b1;
        #20;
        
        if(TRAP_TAKEN != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        MSIP = 1'b0;
        #20;
        
        if(TRAP_TAKEN != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Machine Mode Control module successfully tested.");
    
    end    

endmodule

