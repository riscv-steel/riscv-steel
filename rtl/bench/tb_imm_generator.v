`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 22:58:58
// Module Name: tb_imm_generator
// Project Name: Steel Core
// Description: Immediate Generator testbench
// 
// Dependencies: globals.vh
//               imm_generator.v
//               decoder.v
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

module tb_imm_generator();

    reg [31:0] INSTR;
    reg [2:0] FUNCT3;
    wire [2:0] IMM_TYPE;
    wire [31:0] IMM;
    
    imm_generator dut(
        
        .INSTR(INSTR[31:7]),
        .IMM_TYPE(IMM_TYPE),
        .IMM(IMM)
        
        );
    
    decoder dec(
        
        .OPCODE(INSTR[6:0]),
        .FUNCT7_5(1'b0),
        .FUNCT3(FUNCT3),
        .IMM_TYPE(IMM_TYPE)
        
    );

    integer i;
    
    initial
    begin
        
        $display("Testing Immediate Generator...");
        
        INSTR = {30'b0, 2'b11};
        FUNCT3 = 3'b0;
        
        $display("Testing immediate generator for OP-IMM opcode");
        
        INSTR[6:2] = `OPCODE_OP_IMM;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { {20{INSTR[31]}}, INSTR[31:20] })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("OP-IMM opcode successfully tested.");        
        
        $display("Testing immediate generator for LOAD opcode");
        
        INSTR[6:2] = `OPCODE_LOAD;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { {20{INSTR[31]}}, INSTR[31:20] })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("LOAD opcode successfully tested.");
        
        $display("Testing immediate generator for STORE opcode");
        
        INSTR[6:2] = `OPCODE_STORE;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { {20{INSTR[31]}}, INSTR[31:25], INSTR[11:7] })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("STORE opcode successfully tested.");
        
        $display("Testing immediate generator for BRANCH opcode");
        
        INSTR[6:2] = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { {19{INSTR[31]}}, INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8], 1'b0 })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("BRANCH opcode successfully tested.");
        
        $display("Testing immediate generator for JALR opcode");
        
        INSTR[6:2] = `OPCODE_JALR;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { {20{INSTR[31]}}, INSTR[31:20] })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("JALR opcode successfully tested.");
        
        $display("Testing immediate generator for JAL opcode");
        
        INSTR[6:2] = `OPCODE_JAL;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { {11{INSTR[31]}}, INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21], 1'b0 })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("JAL opcode successfully tested.");
        
        $display("Testing immediate generator for LUI opcode");
        
        INSTR[6:2] = `OPCODE_LUI;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { INSTR[31:12], 12'h000 })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("LUI opcode successfully tested.");
        
        $display("Testing immediate generator for AUIPC opcode");
        
        INSTR[6:2] = `OPCODE_AUIPC;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            
            #10;
            
            if(IMM != { INSTR[31:12], 12'h000 })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("AUIPC opcode successfully tested.");
        
        $display("Testing immediate generator for SYSTEM opcode");
        
        INSTR[6:2] = `OPCODE_SYSTEM;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            
            INSTR[31:7] = $random;
            FUNCT3 = $random;
            
            #10;
            
            if(FUNCT3 != 3'b000 && IMM != { 27'b0, INSTR[19:15] })
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("SYSTEM opcode successfully tested.");
        
        $display("Immediate Generator successfully tested.");
        
    end

endmodule
