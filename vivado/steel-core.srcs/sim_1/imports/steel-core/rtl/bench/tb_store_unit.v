//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 02.06.2020 16:03:55
// Module Name: tb_store_unit
// Project Name: Steel Core
// Description: Store Unit testbench
// 
// Dependencies: globals.vh
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
`include "../globals.vh"


module tb_store_unit();

    reg [2:0] FUNCT3;
    reg [31:0] IADDER_OUT; 
    reg [31:0] RS2;
    reg MEM_WR_REQ;
    wire [31:0] DATA_OUT;
    wire [31:0] D_ADDR;
    wire [3:0] WR_MASK;
    wire WR_REQ;

    store_unit dut(

        .FUNCT3(FUNCT3[1:0]),
        .IADDER_OUT(IADDER_OUT), 
        .RS2(RS2),
        .MEM_WR_REQ(MEM_WR_REQ),
        .DATA_OUT(DATA_OUT),
        .D_ADDR(D_ADDR),
        .WR_MASK(WR_MASK),
        .WR_REQ(WR_REQ)
    
    );   
    
    integer i;
    
    initial
    begin
    
        FUNCT3 = `FUNCT3_BYTE;        
        RS2 = $random;
        MEM_WR_REQ = 1'b0;
        
        $display("Testing D_ADDR generation...");
        
        for(i = 0; i < 20; i=i+1)
        begin
        
            IADDER_OUT = $random;
        
            #10;                       
            
            if(D_ADDR != {IADDER_OUT[31:2], 2'b00})
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        end
        
        $display("D_ADDR generation OK.");
            
        $display("Testing SB signals generation...");
        
        FUNCT3 = `FUNCT3_BYTE;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b00;
        
        #10;
        
        if(DATA_OUT != {24'b0, RS2[7:0]})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b0001)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT3 = `FUNCT3_BYTE;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b01;
        
        #10;
        
        if(DATA_OUT != {16'b0, RS2[7:0], 8'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b0010)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT3 = `FUNCT3_BYTE;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b10;
        
        #10;
        
        if(DATA_OUT != {8'b0, RS2[7:0], 16'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b0100)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT3 = `FUNCT3_BYTE;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b11;
        
        #10;
        
        if(DATA_OUT != {RS2[7:0], 24'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b1000)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("SB signals generation successfully tested.");
        
        $display("Testing SH signals generation...");
        
        FUNCT3 = `FUNCT3_HALF;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b00;
        
        #10;
        
        if(DATA_OUT != {16'b0, RS2[15:0]})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b0011)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        FUNCT3 = `FUNCT3_HALF;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b10;
        
        #10;
        
        if(DATA_OUT != {RS2[15:0], 16'b0})
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b1100)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("SH signals generation successfully tested.");
        
        $display("Testing SW signals generation...");
        
        FUNCT3 = `FUNCT3_WORD;        
        RS2 = $random;
        MEM_WR_REQ = 1'b1;
        IADDER_OUT[1:0] = 2'b00;
        
        #10;
        
        if(DATA_OUT != RS2)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_REQ != 1'b1)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        if(WR_MASK != 4'b1111)
        begin
            $display("FAIL. Check the results.");
            $finish;
        end
        
        $display("SW signals generation successfully tested.");
        
        $display("Store Unit successfully tested.");
        
    end

endmodule
