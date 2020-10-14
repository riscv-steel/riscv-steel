//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 03.04.2020 18:35:35
// Module Name: tb_integer_file
// Project Name: Steel Core
// Description: 32-bit Integer Register File testbench
// 
// Dependencies: globals.vh
//               integer_file.v
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

module tb_integer_file();

    reg CLK;
    
    reg [4:0] RS_1_ADDR;
    reg [4:0] RS_2_ADDR;
    wire [31:0] RS_1;
    wire [31:0] RS_2;
        
    reg [4:0] RD_ADDR;
    reg WR_EN;
    reg [31:0] RD;    
    
    integer_file dut(
    
        .CLK(               CLK),
        
        .RS_1_ADDR(         RS_1_ADDR),
        .RS_2_ADDR(         RS_2_ADDR),
        .RD_ADDR(           RD_ADDR),
        .RS_1(              RS_1),
        .RS_2(              RS_2),
        
        .WR_EN(             WR_EN),
        .RD(                RD)
        
    );
    
    integer i;
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    initial
    begin
    
        $display("Testing Integer Register File...");
    
        CLK = 1'b0;
        
        RS_1_ADDR = 5'b00000;
        RS_2_ADDR = 5'b00000;
        RD_ADDR = 5'b00000;
        WR_EN = 1'b0;
        RD = 32'b0;
        
        $display("Testing values on power up...");
        
        for(i = 0; i < 32; i=i+1)
        begin
        
            RS_1_ADDR = i[4:0];
            
            #20;
            
            if(RS_1 != 32'h00000000)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        end
        
        $display("Power up values OK.");        
        
        $display("Testing write operation...");
            
        for(i = 0; i < 32; i=i+1)
        begin        
            
            RD_ADDR = i[4:0];
            WR_EN = 1'b1;
            RD = $random;            
            
            #20;
            
            WR_EN = 1'b0;
            RS_1_ADDR = RD_ADDR;
            RS_2_ADDR = RD_ADDR;            
            
            #20;
            
            if(RD_ADDR == 5'b00000)
            begin
                if(RS_1 != 32'h00000000)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
                if(RS_2 != 32'h00000000)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            end
            if(RD_ADDR != 5'b00000)
            begin
                if(RS_1 != RD)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
                if(RS_2 != RD)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            end        
        
        end
        
        $display("Write operation seems to work.");
        
        $display("Integer Register File successfully tested.");
        
    end

endmodule
