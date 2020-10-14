//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 30.04.2020 21:30:47
// Module Name: tb_csr_file
// Project Name: Steel Core
// Description: CSR File testbench
// 
// Dependencies: globals.vh
//               csr_file.v
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

module tb_csr_file();

    reg CLK;
    reg RESET;
    
    reg WR_EN;
    reg [11:0] CSR_ADDR;
    reg [2:0] CSR_OP;
    reg [4:0] CSR_UIMM;
    reg [31:0] CSR_DATA_IN;
    wire [31:0] CSR_DATA_OUT;
    
    reg [31:0] PC;
    
    reg E_IRQ;
    reg T_IRQ;
    reg S_IRQ;
    
    reg I_OR_E;
    reg SET_CAUSE;
    reg [3:0] CAUSE_IN;
    reg SET_EPC;
    reg INSTRET_INC;
    reg MIE_CLEAR;
    reg MIE_SET;
    wire MIE;
    wire MEIE_OUT;
    wire MTIE_OUT;
    wire MSIE_OUT;
    wire MEIP_OUT;
    wire MTIP_OUT;
    wire MSIP_OUT;
    
    reg [63:0] REAL_TIME;
    
    wire [31:0] EPC_OUT;
    wire [31:0] TRAP_ADDRESS;    
    
    csr_file dut(

        .CLK(CLK),
        .RESET(RESET),
        
        .WR_EN(WR_EN),
        .CSR_ADDR(CSR_ADDR),
        .CSR_OP(CSR_OP),
        .CSR_UIMM(CSR_UIMM),
        .CSR_DATA_IN(CSR_DATA_IN),
        .CSR_DATA_OUT(CSR_DATA_OUT),
        
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
        
        .EPC_OUT(EPC_OUT),
        .TRAP_ADDRESS(TRAP_ADDRESS)

    );
    
    reg [31:0] base_offset;
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    initial
    begin
        
        $display("Testing CSR Register File...");
        
        CLK = 1'b0;
        RESET = 1'b0;    
        
        WR_EN = 1'b0;
        CSR_ADDR = 5'b00000;
        CSR_OP = `CSR_NOP;
        CSR_UIMM = 5'b00000;
        CSR_DATA_IN = 32'h00000000;
        PC = 32'h00000000;
        E_IRQ = 1'b0;
        T_IRQ = 1'b0;
        S_IRQ = 1'b0;
        I_OR_E = 1'b0;
        SET_CAUSE = 1'b0;
        CAUSE_IN = 4'b0000;
        SET_EPC = 1'b0;
        INSTRET_INC = 1'b0;
        MIE_CLEAR = 1'b0;
        MIE_SET = 1'b0;
        REAL_TIME = 64'h0000000000000000;
        
        //----------------------------------------------------------------------
        // RESET VALUES TEST
        //----------------------------------------------------------------------
        
        $display("Testing values after reset...");        
        
        #5;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `CYCLE;
        #5;
        if(CSR_DATA_OUT != `MCYCLE_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("CYCLE reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `CYCLEH;
        #5;
        if(CSR_DATA_OUT != `MCYCLEH_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("CYCLEH reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `TIME;
        #5;
        if(CSR_DATA_OUT != `TIME_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("TIME reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `TIMEH;
        #5;
        if(CSR_DATA_OUT != `TIMEH_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("TIMEH reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `INSTRET;
        #5;
        if(CSR_DATA_OUT != `MINSTRET_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("INSTRET reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `INSTRETH;
        #5;
        if(CSR_DATA_OUT != `MINSTRETH_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("INSTRETH reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MSTATUS;
        #5;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b0, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MSTATUS reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MISA;
        #5;        
        if(CSR_DATA_OUT != 32'b01000000000000000000000100000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MISA reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MIE;
        #5;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MIE reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MTVEC;
        #5;        
        if(CSR_DATA_OUT != {`MTVEC_BASE_RESET, `MTVEC_MODE_RESET})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MTVEC reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MSCRATCH;
        #5;        
        if(CSR_DATA_OUT != `MSCRATCH_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MSCRATCH reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MEPC;
        #5;        
        if(CSR_DATA_OUT != `MEPC_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MEPC reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MTVAL;
        #5;        
        if(CSR_DATA_OUT != 32'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MTVAL reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MIP;
        #5;        
        if(CSR_DATA_OUT != 32'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MIP reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MCYCLE;
        #5;
        if(CSR_DATA_OUT != `MCYCLE_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("CYCLE reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MCYCLEH;
        #5;
        if(CSR_DATA_OUT != `MCYCLEH_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("CYCLEH reset value OK.");        
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MINSTRET;
        #5;
        if(CSR_DATA_OUT != `MINSTRET_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("INSTRET reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MINSTRETH;
        #5;
        if(CSR_DATA_OUT != `MINSTRETH_RESET)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("INSTRETH reset value OK.");
        
        #20;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        CSR_ADDR = `MCOUNTINHIBIT;
        #5;
        if(CSR_DATA_OUT != {29'b0, `MCOUNTINHIBIT_IR_RESET, 1'b0, `MCOUNTINHIBIT_CY_RESET})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("MCOUNTINHIBIT reset value OK.");         
                
        $display("Reset values successfully tested.");
        
        #35;
        
        //----------------------------------------------------------------------
        // WRITE OPERATION TEST
        //----------------------------------------------------------------------
        
        $display("Testing write operation for each CSR...");        
        
        WR_EN = 1'b1;
        CSR_OP = {1'b0, `CSR_RW};
        CSR_UIMM = 5'b11111;
        CSR_DATA_IN = 32'hFFFFFFFF;
        
        CSR_ADDR = `CYCLE;
        #20;
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register CYCLE unsuccessful. Result OK.");
        
        CSR_ADDR = `CYCLEH;        
        #20;        
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register CYCLEH unsuccessful. Result OK.");
        
        CSR_ADDR = `TIME;
        #20;        
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register TIME unsuccessful. Result OK.");
        
        CSR_ADDR = `TIMEH;
        #20;
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register TIMEH unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRET;
        #20;
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register INSTRET unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRETH;
        #20;        
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register INSTRETH unsuccessful. Result OK.");
        
        CSR_ADDR = `MSTATUS;
        #20;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MSTATUS successful. Result OK.");
        
        CSR_ADDR = `MISA;
        #20;        
        if(CSR_DATA_OUT != {2'b01, 4'b0, 26'b00000000000000000100000000})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MISA unsuccessful. Result OK.");
        
        CSR_ADDR = `MIE;
        #20;        
        if(CSR_DATA_OUT != {20'b0, 1'b1, 3'b0, 1'b1, 3'b0, 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MIE successful. Result OK.");
        
        CSR_ADDR = `MTVEC;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MTVEC successful. Result OK.");
        
        CSR_ADDR = `MSCRATCH;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MSCRATCH successful. Result OK.");
        
        CSR_ADDR = `MEPC;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFC)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MEPC successful. Result OK.");
        
        CSR_ADDR = `MCAUSE;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MCAUSE unsuccessful. Result OK.");
        
        CSR_ADDR = `MTVAL;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MTVAL unsuccessful. Result OK.");
        
        CSR_ADDR = `MIP;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MIP unsuccessful. Result OK.");        
        
        CSR_ADDR = `MCYCLE;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MCYCLE successful. Result OK.");
        
        CSR_ADDR = `MCYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MCYCLEH successful. Result OK.");        
        
        CSR_ADDR = `MINSTRET;
        #20;
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MINSTRET successful. Result OK.");
        
        CSR_ADDR = `MINSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MINSTRETH successful. Result OK.");
        
        CSR_ADDR = `MCOUNTINHIBIT;
        #20;        
        if(CSR_DATA_OUT != {29'b0, 1'b1, 1'b0, 1'b1})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MCOUNTINHIBIT successful. Result OK.");
        
        $display("Write operation successfully tested.");
         
        //----------------------------------------------------------------------
        // SET OPERATION TEST
        //----------------------------------------------------------------------
        
        #5;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        
        $display("Testing set operation for each CSR...");        
        
        WR_EN = 1'b1;
        CSR_OP = {1'b0, `CSR_RS};
        CSR_UIMM = 5'b11111;
        CSR_DATA_IN = 32'hFFFFFFFF;
        
        CSR_ADDR = `CYCLE;
        #20;
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register CYCLE unsuccessful. Result OK.");
        
        CSR_ADDR = `CYCLEH;        
        #20;        
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register CYCLEH unsuccessful. Result OK.");
        
        CSR_ADDR = `TIME;
        #20;        
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register TIME unsuccessful. Result OK.");
        
        CSR_ADDR = `TIMEH;
        #20;
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register TIMEH unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRET;
        #20;
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register INSTRET unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRETH;
        #20;        
        if(CSR_DATA_OUT == 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register INSTRETH unsuccessful. Result OK.");
        
        CSR_ADDR = `MSTATUS;
        #20;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MSTATUS successful. Result OK.");
        
        CSR_ADDR = `MISA;
        #20;        
        if(CSR_DATA_OUT != {2'b01, 4'b0, 26'b00000000000000000100000000})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MISA unsuccessful. Result OK.");
        
        CSR_ADDR = `MIE;
        #20;        
        if(CSR_DATA_OUT != {20'b0, 1'b1, 3'b0, 1'b1, 3'b0, 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MIE successful. Result OK.");
        
        CSR_ADDR = `MTVEC;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MTVEC successful. Result OK.");
        
        CSR_ADDR = `MSCRATCH;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MSCRATCH successful. Result OK.");
        
        CSR_ADDR = `MEPC;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFC)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MEPC successful. Result OK.");
        
        CSR_ADDR = `MCAUSE;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MCAUSE unsuccessful. Result OK.");
        
        CSR_ADDR = `MTVAL;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MTVAL unsuccessful. Result OK.");
        
        CSR_ADDR = `MIP;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MIP unsuccessful. Result OK.");        
        
        CSR_ADDR = `MCYCLE;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MCYCLE successful. Result OK.");
        
        CSR_ADDR = `MCYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MCYCLEH successful. Result OK.");        
        
        CSR_ADDR = `MINSTRET;
        #20;
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MINSTRET successful. Result OK.");
        
        CSR_ADDR = `MINSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MINSTRETH successful. Result OK.");
        
        CSR_ADDR = `MCOUNTINHIBIT;
        #20;        
        if(CSR_DATA_OUT != {29'b0, 1'b1, 1'b0, 1'b1})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MCOUNTINHIBIT successful. Result OK.");
        
        $display("Set operation successfully tested.");
        
        //----------------------------------------------------------------------
        // CLEAR OPERATION TEST
        //----------------------------------------------------------------------
                
        $display("Testing clear operation for each CSR...");        
        
        WR_EN = 1'b1;
        CSR_OP = {1'b0, `CSR_RC};
        CSR_UIMM = 5'b11111;
        CSR_DATA_IN = 32'hFFFFFFFF;
        
        CSR_ADDR = `CYCLE;
        #20;
        if(CSR_DATA_OUT == 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register CYCLE unsuccessful. Result OK.");
        
        CSR_ADDR = `CYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register CYCLEH unsuccessful. Result OK.");
        
        CSR_ADDR = `TIME;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register TIME unsuccessful. Result OK.");
        
        CSR_ADDR = `TIMEH;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register TIMEH unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRET;
        #20;
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register INSTRET unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register INSTRETH unsuccessful. Result OK.");
        
        CSR_ADDR = `MSTATUS;
        #20;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b0, 3'b0 , 1'b0, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MSTATUS successful. Result OK.");
        
        CSR_ADDR = `MISA;
        #20;        
        if(CSR_DATA_OUT != {2'b01, 4'b0, 26'b00000000000000000100000000})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MISA unsuccessful. Result OK.");
        
        CSR_ADDR = `MIE;
        #20;        
        if(CSR_DATA_OUT != {20'b0, 1'b0, 3'b0, 1'b0, 3'b0, 1'b0, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MIE successful. Result OK.");
        
        CSR_ADDR = `MTVEC;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MTVEC successful. Result OK.");
        
        CSR_ADDR = `MSCRATCH;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MSCRATCH successful. Result OK.");
        
        CSR_ADDR = `MEPC;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MEPC successful. Result OK.");
        
        CSR_ADDR = `MCAUSE;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MCAUSE unsuccessful. Result OK.");
        
        CSR_ADDR = `MTVAL;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MTVAL unsuccessful. Result OK.");
        
        CSR_ADDR = `MIP;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MIP unsuccessful. Result OK.");        
        
        CSR_ADDR = `MCYCLE;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MCYCLE successful. Result OK.");
        
        CSR_ADDR = `MCYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MCYCLEH successful. Result OK.");        
        
        CSR_ADDR = `MINSTRET;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MINSTRET successful. Result OK.");
        
        CSR_ADDR = `MINSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MINSTRETH successful. Result OK.");
        
        CSR_ADDR = `MCOUNTINHIBIT;
        #20;        
        if(CSR_DATA_OUT != {29'b0, 1'b0, 1'b0, 1'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MCOUNTINHIBIT successful. Result OK.");
        
        $display("Clear operation successfully tested.");
        
        //----------------------------------------------------------------------
        // WRITE IMMEDIATE OPERATION TEST
        //----------------------------------------------------------------------
        
        $display("Testing write immediate operation for each CSR...");        
        
        WR_EN = 1'b1;
        CSR_OP = {1'b1, `CSR_RW};
        CSR_UIMM = 5'b11111;
        CSR_DATA_IN = 32'hFFFFFFFF;
        
        CSR_ADDR = `CYCLE;
        #20;
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register CYCLE unsuccessful. Result OK.");
        
        CSR_ADDR = `CYCLEH;        
        #20;        
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register CYCLEH unsuccessful. Result OK.");
        
        CSR_ADDR = `TIME;
        #20;        
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register TIME unsuccessful. Result OK.");
        
        CSR_ADDR = `TIMEH;
        #20;
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register TIMEH unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRET;
        #20;
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register INSTRET unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRETH;
        #20;        
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register INSTRETH unsuccessful. Result OK.");
        
        CSR_ADDR = `MSTATUS;
        #20;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b0, 3'b0 , 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MSTATUS successful. Result OK.");
        
        CSR_ADDR = `MISA;
        #20;        
        if(CSR_DATA_OUT != {2'b01, 4'b0, 26'b00000000000000000100000000})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MISA unsuccessful. Result OK.");
        
        CSR_ADDR = `MIE;
        #20;        
        if(CSR_DATA_OUT != {20'b0, 1'b0, 3'b0, 1'b0, 3'b0, 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MIE successful. Result OK.");
        
        CSR_ADDR = `MTVEC;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MTVEC successful. Result OK.");
        
        CSR_ADDR = `MSCRATCH;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MSCRATCH successful. Result OK.");
        
        CSR_ADDR = `MEPC;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001C)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MEPC successful. Result OK.");
        
        CSR_ADDR = `MCAUSE;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MCAUSE unsuccessful. Result OK.");
        
        CSR_ADDR = `MTVAL;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MTVAL unsuccessful. Result OK.");
        
        CSR_ADDR = `MIP;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-only register MIP unsuccessful. Result OK.");        
        
        CSR_ADDR = `MCYCLE;
        #20;
        if(CSR_DATA_OUT != 32'h00000020)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MCYCLE successful. Result OK.");
        
        CSR_ADDR = `MCYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MCYCLEH successful. Result OK.");        
        
        CSR_ADDR = `MINSTRET;
        #20;
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MINSTRET successful. Result OK.");
        
        CSR_ADDR = `MINSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MINSTRETH successful. Result OK.");
        
        CSR_ADDR = `MCOUNTINHIBIT;
        #20;        
        if(CSR_DATA_OUT != {29'b0, 1'b1, 1'b0, 1'b1})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to write the read-write register MCOUNTINHIBIT successful. Result OK.");
        
        $display("Write operation successfully tested.");
         
        //----------------------------------------------------------------------
        // SET IMMEDIATE OPERATION TEST
        //----------------------------------------------------------------------
        
        #5;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        
        $display("Testing set immediate operation for each CSR...");        
        
        WR_EN = 1'b1;
        CSR_OP = {1'b1, `CSR_RS};
        CSR_UIMM = 5'b11111;
        CSR_DATA_IN = 32'hFFFFFFFF;
        
        CSR_ADDR = `CYCLE;
        #20;
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register CYCLE unsuccessful. Result OK.");
        
        CSR_ADDR = `CYCLEH;        
        #20;        
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register CYCLEH unsuccessful. Result OK.");
        
        CSR_ADDR = `TIME;
        #20;        
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register TIME unsuccessful. Result OK.");
        
        CSR_ADDR = `TIMEH;
        #20;
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register TIMEH unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRET;
        #20;
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register INSTRET unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRETH;
        #20;        
        if(CSR_DATA_OUT == 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register INSTRETH unsuccessful. Result OK.");
        
        CSR_ADDR = `MSTATUS;
        #20;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MSTATUS successful. Result OK.");
        
        CSR_ADDR = `MISA;
        #20;        
        if(CSR_DATA_OUT != {2'b01, 4'b0, 26'b00000000000000000100000000})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MISA unsuccessful. Result OK.");
        
        CSR_ADDR = `MIE;
        #20;        
        if(CSR_DATA_OUT != {20'b0, 1'b0, 3'b0, 1'b0, 3'b0, 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MIE successful. Result OK.");
        
        CSR_ADDR = `MTVEC;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MTVEC successful. Result OK.");
        
        CSR_ADDR = `MSCRATCH;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MSCRATCH successful. Result OK.");
        
        CSR_ADDR = `MEPC;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001C)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MEPC successful. Result OK.");
        
        CSR_ADDR = `MCAUSE;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MCAUSE unsuccessful. Result OK.");
        
        CSR_ADDR = `MTVAL;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MTVAL unsuccessful. Result OK.");
        
        CSR_ADDR = `MIP;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-only register MIP unsuccessful. Result OK.");        
        
        CSR_ADDR = `MCYCLE;
        #20;
        if(CSR_DATA_OUT != 32'h00000020)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MCYCLE successful. Result OK.");
        
        CSR_ADDR = `MCYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MCYCLEH successful. Result OK.");        
        
        CSR_ADDR = `MINSTRET;
        #20;
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MINSTRET successful. Result OK.");
        
        CSR_ADDR = `MINSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MINSTRETH successful. Result OK.");
        
        CSR_ADDR = `MCOUNTINHIBIT;
        #20;        
        if(CSR_DATA_OUT != {29'b0, 1'b1, 1'b0, 1'b1})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to set the read-write register MCOUNTINHIBIT successful. Result OK.");
        
        $display("Set operation successfully tested.");
        
        //----------------------------------------------------------------------
        // CLEAR IMMEDIATE OPERATION TEST
        //----------------------------------------------------------------------
                
        $display("Testing clear immediate operation for each CSR...");        
        
        WR_EN = 1'b1;
        CSR_OP = {1'b1, `CSR_RC};
        CSR_UIMM = 5'b11111;
        CSR_DATA_IN = 32'hFFFFFFFF;
        
        CSR_ADDR = `CYCLE;
        #20;
        if(CSR_DATA_OUT == 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register CYCLE unsuccessful. Result OK.");
        
        CSR_ADDR = `CYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register CYCLEH unsuccessful. Result OK.");
        
        CSR_ADDR = `TIME;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register TIME unsuccessful. Result OK.");
        
        CSR_ADDR = `TIMEH;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register TIMEH unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRET;
        #20;
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register INSTRET unsuccessful. Result OK.");
        
        CSR_ADDR = `INSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'h0000001F)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register INSTRETH unsuccessful. Result OK.");
        
        CSR_ADDR = `MSTATUS;
        #20;        
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b0, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MSTATUS successful. Result OK.");
        
        CSR_ADDR = `MISA;
        #20;        
        if(CSR_DATA_OUT != {2'b01, 4'b0, 26'b00000000000000000100000000})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MISA unsuccessful. Result OK.");
        
        CSR_ADDR = `MIE;
        #20;        
        if(CSR_DATA_OUT != {20'b0, 1'b0, 3'b0, 1'b0, 3'b0, 1'b0, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MIE successful. Result OK.");
        
        CSR_ADDR = `MTVEC;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MTVEC successful. Result OK.");
        
        CSR_ADDR = `MSCRATCH;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MSCRATCH successful. Result OK.");
        
        CSR_ADDR = `MEPC;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MEPC successful. Result OK.");
        
        CSR_ADDR = `MCAUSE;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MCAUSE unsuccessful. Result OK.");
        
        CSR_ADDR = `MTVAL;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MTVAL unsuccessful. Result OK.");
        
        CSR_ADDR = `MIP;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-only register MIP unsuccessful. Result OK.");        
        
        CSR_ADDR = `MCYCLE;
        #20;
        if(CSR_DATA_OUT != 32'h00000020)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MCYCLE successful. Result OK.");
        
        CSR_ADDR = `MCYCLEH;        
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MCYCLEH successful. Result OK.");        
        
        CSR_ADDR = `MINSTRET;
        #20;
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MINSTRET successful. Result OK.");
        
        CSR_ADDR = `MINSTRETH;
        #20;        
        if(CSR_DATA_OUT != 32'h00000000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MINSTRETH successful. Result OK.");
        
        CSR_ADDR = `MCOUNTINHIBIT;
        #20;        
        if(CSR_DATA_OUT != {29'b0, 1'b0, 1'b0, 1'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        $display("Attempt to clear the read-write register MCOUNTINHIBIT successful. Result OK.");
        
        $display("Clear operation successfully tested.");
        
        //----------------------------------------------------------------------
        // INTERRUPT PENDING BITS TEST
        //----------------------------------------------------------------------
        
        #5;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        
        $display("Testing interrupt pending bits setup...");
        
        E_IRQ = 1'b1;
        T_IRQ = 1'b1;
        S_IRQ = 1'b1;        
        #20;
        
        if(MEIP_OUT != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MTIP_OUT != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MSIP_OUT != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Interrupt pending bits successfully tested.");
        
        //----------------------------------------------------------------------
        // INTERRUPT ENABLE BITS TEST
        //----------------------------------------------------------------------
                
        $display("Testing interrupt enable bits setup...");
        
        WR_EN = 1'b1;
        CSR_ADDR = `MSTATUS;
        CSR_DATA_IN = 32'hFFFFFFFF;
        CSR_OP = {1'b0, `CSR_RW};               
        #20;
        WR_EN = 1'b1;
        CSR_ADDR = `MIE;
        CSR_DATA_IN = 32'hFFFFFFFF;
        CSR_OP = {1'b0, `CSR_RW};               
        #20;
        
        if(MIE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MEIE_OUT != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MTIE_OUT != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(MSIE_OUT != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Interrupt enable bits successfully tested.");
        
        //----------------------------------------------------------------------
        // EPC SET TEST
        //----------------------------------------------------------------------
                
        $display("Testing EPC setup...");
        
        SET_EPC = 1'b1;
        PC = $random;
        CSR_ADDR = `MEPC;             
        #20;        
        SET_EPC = 1'b0;
        
        if(CSR_DATA_OUT != PC)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(EPC_OUT != PC)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("EPC setup successfully tested.");

        //----------------------------------------------------------------------
        // MCAUSE SET TEST
        //----------------------------------------------------------------------
                
        $display("Testing MCAUSE setup...");
        
        SET_CAUSE = 1'b1;
        CAUSE_IN = $random;
        I_OR_E = 1'b1;
        CSR_ADDR = `MCAUSE;             
        #20;        
        
        if(CSR_DATA_OUT != {I_OR_E, 27'b0, CAUSE_IN})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("MCAUSE setup successfully tested.");
        
        //----------------------------------------------------------------------
        // TRAP ADDRESS GENERATION TEST
        //----------------------------------------------------------------------
                
        $display("Testing TRAP ADDRESS generation...");
        
        $display("Testing exceptions in Direct Mode...");
        WR_EN =1'b1;
        CSR_ADDR = `MTVEC;
        CSR_OP = {1'b0, `CSR_RW};
        CSR_DATA_IN = $random;
        CSR_DATA_IN[1:0] = 2'b00;
        SET_CAUSE = 1'b1;
        CAUSE_IN = $random;
        I_OR_E = 1'b0;             
        #20;        
        
        if(CSR_DATA_OUT != {CSR_DATA_IN[31:2], 2'b00})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(TRAP_ADDRESS != {CSR_DATA_IN[31:2], 2'b00})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Exceptions in Direct Mode OK.");
        
        $display("Testing interrupts in Direct Mode...");
        WR_EN =1'b1;
        CSR_ADDR = `MTVEC;
        CSR_OP = {1'b0, `CSR_RW};
        CSR_DATA_IN = $random;
        CSR_DATA_IN[1:0] = 2'b00;
        SET_CAUSE = 1'b1;
        CAUSE_IN = $random;
        I_OR_E = 1'b1;             
        #20;        
        
        if(CSR_DATA_OUT != {CSR_DATA_IN[31:2], 2'b00})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(TRAP_ADDRESS != {CSR_DATA_IN[31:2], 2'b00})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Interrupts in Direct Mode OK.");
        
        $display("Testing exceptions in Vectored Mode...");
        WR_EN =1'b1;
        CSR_ADDR = `MTVEC;
        CSR_OP = {1'b0, `CSR_RW};
        CSR_DATA_IN = $random;
        CSR_DATA_IN[1:0] = 2'b01;
        SET_CAUSE = 1'b1;
        CAUSE_IN = $random;
        I_OR_E = 1'b0;             
        #20;        
        
        if(CSR_DATA_OUT != {CSR_DATA_IN[31:2], 2'b01})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(TRAP_ADDRESS != {CSR_DATA_IN[31:2], 2'b00})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Exceptions in Vectored Mode OK.");
        
        $display("Testing interrupts in Vectored Mode...");
        WR_EN =1'b1;
        CSR_ADDR = `MTVEC;
        CSR_OP = {1'b0, `CSR_RW};
        CSR_DATA_IN = $random;
        CSR_DATA_IN[1:0] = 2'b01;
        SET_CAUSE = 1'b1;
        CAUSE_IN = $random;
        I_OR_E = 1'b1;             
        #20;        
        
        if(CSR_DATA_OUT != {CSR_DATA_IN[31:2], 2'b01})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        base_offset = CAUSE_IN << 2;
        if(TRAP_ADDRESS != ({CSR_DATA_IN[31:2],2'b00} + base_offset))
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("Interrupts in Vectored Mode OK.");
        
        $display("TRAP ADDRESS generation successfully tested.");
        
        //----------------------------------------------------------------------
        // MIE CLEAR & SET TEST
        //----------------------------------------------------------------------
        
        WR_EN =1'b0;
               
        $display("Testing MIE clear operation...");
        
        MIE_CLEAR = 1'b1;
        CSR_ADDR = `MSTATUS;             
        #20;        
        MIE_CLEAR = 1'b0;
        
        if(MIE != 1'b0)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b0, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        MIE_SET = 1'b1;
        CSR_ADDR = `MSTATUS;             
        #20;        
        MIE_SET = 1'b0;
        
        if(MIE != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(CSR_DATA_OUT != {19'b0, 2'b11, 3'b0, 1'b1, 3'b0 , 1'b1, 3'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("MIE CLEAR & SET operation successfully tested.");
        
        //----------------------------------------------------------------------
        // CYCLE & INSTRET COUNTING TEST
        //----------------------------------------------------------------------
        
        WR_EN =1'b0; 
        #5;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
               
        $display("Testing CYCLE and INSTRET counting...");
        
        INSTRET_INC = 1'b1;
        CSR_ADDR = `CYCLE;             
        #15;        
        
        if(CSR_DATA_OUT != `MCYCLE_RESET + 1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        CSR_ADDR = `INSTRET;
        #5;
        if(CSR_DATA_OUT != `MINSTRET_RESET + 1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        INSTRET_INC = 1'b0;
        CSR_ADDR = `CYCLE;             
        #15;        
        
        if(CSR_DATA_OUT != `MCYCLE_RESET + 2)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        CSR_ADDR = `INSTRET;
        #5;
        if(CSR_DATA_OUT != `MINSTRET_RESET + 1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        WR_EN = 1'b1;
        INSTRET_INC = 1'b1;
        CSR_OP = {1'b0, CSR_OP};
        CSR_ADDR = `MCOUNTINHIBIT;
        CSR_DATA_IN = {29'b0, 3'b101};
        #20;
        
        WR_EN = 1'b0;
        CSR_ADDR = `CYCLE;             
        #15;        
        
        if(CSR_DATA_OUT != `MCYCLE_RESET + 3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        CSR_ADDR = `INSTRET;
        #5;
        if(CSR_DATA_OUT != `MINSTRET_RESET + 2)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        WR_EN = 1'b1;
        CSR_OP = {1'b0, CSR_OP};
        CSR_ADDR = `MCOUNTINHIBIT;
        CSR_DATA_IN = {29'b0, 3'b000};
        #20;
        
        WR_EN = 1'b0;
        CSR_ADDR = `CYCLE;             
        #15;        
        
        if(CSR_DATA_OUT != `MCYCLE_RESET + 4)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        CSR_ADDR = `INSTRET;
        #5;
        if(CSR_DATA_OUT != `MINSTRET_RESET + 3)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("CYCLE & INSTRET counting successfully tested.");
        
        $display("CSR Register File successfully tested.");
        
    end

endmodule

