//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 18:45:28
// Module Name: tb_branch_unit
// Project Name: Steel Core
// Description: Branch decision unit testbench
// 
// Dependencies: globals.vh
//               branch_unit.v
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

module tb_branch_unit();
    
    reg [6:2] OPCODE_6_TO_2;
    reg [31:0] RS1;
    reg [31:0] RS2;
    reg [2:0] FUNCT3;
	wire BRANCH_TAKEN;
	
	integer i = 0;
	reg signed [31:0] rs1s;
	reg signed [31:0] rs2s;    
    
    branch_unit dut(
        .OPCODE_6_TO_2(OPCODE_6_TO_2),
        .RS1(RS1),
        .RS2(RS2),
        .FUNCT3(FUNCT3),
        .BRANCH_TAKEN(BRANCH_TAKEN)
    );
    
    initial
    begin
        
        $display("Testing Branch Unit...");
        
        $display("Testing branch comparator unit for BEQ."); 
        
        FUNCT3 = 3'b000;
        OPCODE_6_TO_2 = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            RS1 = $random;
            RS2 = $random;
            
            #10;
            
            if(RS1 == RS2 && BRANCH_TAKEN != 1'b1)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 1.");
                $finish;
            end
            if(RS1 != RS2 && BRANCH_TAKEN != 1'b0)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 0.");
                $finish;
            end
        end
        
        RS1 = $random;
        RS2 = RS1;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        $display("Branch comparator works fine for BEQ.");
        
        $display("Testing branch comparator unit for BNE."); 
        
        FUNCT3 = 3'b001;
        OPCODE_6_TO_2 = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            RS1 = $random;
            RS2 = $random;
            
            #10;
            
            if(RS1 != RS2 && BRANCH_TAKEN != 1'b1)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 1.");
                $finish;
            end
            if(RS1 == RS2 && BRANCH_TAKEN != 1'b0)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 0.");
                $finish;
            end
        end
        
        RS1 = $random;
        RS2 = RS1;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        $display("Branch comparator works fine for BNE.");
        
        $display("Testing branch comparator unit for BLT."); 
        
        FUNCT3 = 3'b100;
        OPCODE_6_TO_2 = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            RS1 = $random;
            RS2 = $random;
            rs1s = RS1;
            rs2s = RS2;
            #10;
            
            if(rs1s < rs2s && BRANCH_TAKEN != 1'b1)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 1.");
                $finish;
            end
            if(rs1s >= rs2s && BRANCH_TAKEN != 1'b0)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 0.");
                $finish;
            end
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b11111111_11111111_11111111_11111100;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b00000000_00000000_00000000_00001000;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        $display("Branch comparator works fine for BLT.");
        
        $display("Testing branch comparator unit for BGE."); 
        
        FUNCT3 = 3'b101;
        OPCODE_6_TO_2 = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            RS1 = $random;
            RS2 = $random;
            rs1s = RS1;
            rs2s = RS2;
            #10;
            
            if(rs1s >= rs2s && BRANCH_TAKEN != 1'b1)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 1.");
                $finish;
            end
            if(rs1s < rs2s && BRANCH_TAKEN != 1'b0)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 0.");
                $finish;
            end
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b11111111_11111111_11111111_11111100;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b00000000_00000000_00000000_00001000;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        $display("Branch comparator works fine for BGE.");
        
        $display("Testing branch comparator unit for BLTU."); 
        
        FUNCT3 = 3'b110;
        OPCODE_6_TO_2 = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            RS1 = $random;
            RS2 = $random;
            
            #10;
            
            if(RS1 < RS2 && BRANCH_TAKEN != 1'b1)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 1.");
                $finish;
            end
            if(RS1 >= RS2 && BRANCH_TAKEN != 1'b0)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 0.");
                $finish;
            end
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b11111111_11111111_11111111_11111100;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b00000000_00000000_00000000_00001000;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        $display("Branch comparator works fine for BLTU.");
        
        $display("Testing branch comparator unit for BGEU."); 
        
        FUNCT3 = 3'b111;
        OPCODE_6_TO_2 = `OPCODE_BRANCH;
        
        for(i = 0; i < 10000; i=i+1)
        begin
            RS1 = $random;
            RS2 = $random;
            
            #10;
            
            if(RS1 >= RS2 && BRANCH_TAKEN != 1'b1)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 1.");
                $finish;
            end
            if(RS1 < RS2 && BRANCH_TAKEN != 1'b0)
            begin
                $display("FAIL. Expected BRANCH_TAKEN = 0.");
                $finish;
            end
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b11111111_11111111_11111111_11111100;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b00000000_00000000_00000000_00001000;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b11111111_11111111_11111111_11111000;
        RS2 = 32'b00000000_00000000_00000000_00001100;
        #10;
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        RS1 = 32'b00000000_00000000_00000000_00001100;
        RS2 = 32'b11111111_11111111_11111111_11111000;
        #10;
        if(BRANCH_TAKEN != 1'b0)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 0.");
            $finish;
        end
        
        $display("Branch comparator works fine for BGEU.");
        
        $display("Testing branch comparator unit for JAL."); 
        
        FUNCT3 = 3'bxxx;
        OPCODE_6_TO_2 = `OPCODE_JAL;
        
        #10;
            
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        $display("Branch comparator works fine for JAL.");
        
        $display("Testing branch comparator unit for JALR."); 
        
        FUNCT3 = 3'bxxx;
        OPCODE_6_TO_2 = `OPCODE_JALR;
        
        #10;
            
        if(BRANCH_TAKEN != 1'b1)
        begin
            $display("FAIL. Expected BRANCH_TAKEN = 1.");
            $finish;
        end
        
        $display("Branch comparator works fine for JALR.");
        
        $display("Branch Unit successfully tested.");
        
    end
    
endmodule
