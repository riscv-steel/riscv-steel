//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 20:52:25
// Module Name: tb_load_unit
// Project Name: Steel Core
// Description: RISC-V Steel Core Load Unit testbench
// 
// Dependencies: globals.vh
//               load_unit.v
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


module tb_load_unit();

    reg [1:0] LOAD_SIZE;
    reg LOAD_UNSIGNED;
    reg [31:0] DATA_IN;
    reg [1:0] IADDER_OUT_1_TO_0;
    wire [31:0] OUTPUT;
    
    load_unit dut(
    
        .LOAD_SIZE(LOAD_SIZE),
        .LOAD_UNSIGNED(LOAD_UNSIGNED),
        .DATA_IN(DATA_IN),
        .IADDER_OUT_1_TO_0(IADDER_OUT_1_TO_0),
        .OUTPUT(OUTPUT)
        
        );
    
    integer i;
    
    initial
    begin
        
        $display("Testing Load Unit...");
        
        $display("Testing Load Unit for LB operation.");
        LOAD_SIZE = 2'b00;
        LOAD_UNSIGNED = 1'b0;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            IADDER_OUT_1_TO_0 = $random;
            
            #10;
            
            if(IADDER_OUT_1_TO_0 == 2'b00 & OUTPUT != { {24{DATA_IN[7]}} , DATA_IN[7:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0 == 2'b01 & OUTPUT != { {24{DATA_IN[15]}} , DATA_IN[15:8]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0 == 2'b10 & OUTPUT != { {24{DATA_IN[23]}} , DATA_IN[23:16]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0 == 2'b11 & OUTPUT != { {24{DATA_IN[31]}} , DATA_IN[31:24]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LB operation successfully tested.");
        
        $display("Testing Load Unit for LH operation.");
        LOAD_SIZE = 2'b01;
        LOAD_UNSIGNED = 1'b0;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            IADDER_OUT_1_TO_0 = $random;
            IADDER_OUT_1_TO_0[0] = 1'b0;
                       
            #10;
            
            if(IADDER_OUT_1_TO_0[1] == 1'b0 & OUTPUT != { {16{DATA_IN[15]}} , DATA_IN[15:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0[1] == 1'b1 & OUTPUT != { {16{DATA_IN[31]}} , DATA_IN[31:16]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LH operation successfully tested.");
        
        $display("Testing Load Unit for LW operation.");
        LOAD_SIZE = 2'b10;
        LOAD_UNSIGNED = 1'b0;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            IADDER_OUT_1_TO_0 = 2'b00;
            
            #10;
            
            if(OUTPUT != DATA_IN[31:0])
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LW operation successfully tested.");        
        
        $display("Testing Load Unit for LBU operation.");
        LOAD_SIZE = 2'b00;
        LOAD_UNSIGNED = 1'b1;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            IADDER_OUT_1_TO_0 = $random;
            
            #10;
            
            if(IADDER_OUT_1_TO_0 == 2'b00 & OUTPUT != { 24'b0 , DATA_IN[7:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0 == 2'b01 & OUTPUT != { 24'b0 , DATA_IN[15:8]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0 == 2'b10 & OUTPUT != { 24'b0 , DATA_IN[23:16]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0 == 2'b11 & OUTPUT != { 24'b0 , DATA_IN[31:24]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LBU operation successfully tested.");
        
        $display("Testing Load Unit for LHU operation.");
        
        LOAD_SIZE = 2'b01;
        LOAD_UNSIGNED = 1'b1;
        
        for(i = 0; i < 10000; i=i+1)
        begin
        
            DATA_IN = $random;
            IADDER_OUT_1_TO_0 = $random;
            IADDER_OUT_1_TO_0[0] = 1'b0;
                       
            #10;
            
            if(IADDER_OUT_1_TO_0[1] == 1'b0 & OUTPUT != { 16'b0 , DATA_IN[15:0]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
            else if(IADDER_OUT_1_TO_0[1] == 1'b1 & OUTPUT != { 16'b0 , DATA_IN[31:16]})
            begin
                $display("FAIL. Wrong result.");
                $finish;
            end
        
        end
        
        $display("LHU operation successfully tested.");        
        
        $display("Load Unit successfully tested.");
        
    end
                                                                
endmodule
