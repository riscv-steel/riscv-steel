//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 02.05.2020 15:45:27
// Module Name: tb_machine_mode
// Project Name: Steel Core
// Description: M-mode operation testbench
// 
// Dependencies: globals.vh
//               machine_control.v
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
`include "../globals.vh"

module tb_machine_mode();

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

