//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 05.07.2020 00:20:31
// Module Name: tb_ram
// Project Name: Steel SoC 
// Description: RAM memory array testbench 
// 
// Dependencies: ram.v
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

module tb_ram();

    reg CLK;
    reg [10:0] ADDRA;
    reg [10:0] ADDRB;
    reg [31:0] DINA;
    reg [3:0] WEA;
    wire [31:0] DOUTA;
    wire [31:0] DOUTB;
    
    ram dut(
        .CLK(CLK),
        .ADDRA(ADDRA),
        .ADDRB(ADDRB),
        .DINA(DINA),
        .WEA(WEA),
        .DOUTA(DOUTA),
        .DOUTB(DOUTB)
    );
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    integer i;
    
    initial
    begin
        
        $display("Testing RAM by showing its data...");
        
        CLK = 1'b0;
        WEA = 4'b0;
        DINA = 32'b0;
        #20;
        for(i = 0; i < 2048; i = i+1)
        begin
            ADDRA = i[10:0];
            ADDRB = i[10:0];
            #20;
            $display("Port A - %d: %h", ADDRA, DOUTA);
            $display("Port B - %d: %h", ADDRB, DOUTB);
        end
        
        $display("RAM end.");
        
        $display("Writting word...");
        
        WEA = 4'b1111;
        DINA = 32'hFFFFFFFF;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hFFFFFFFF)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("Writting halfword (upper)...");
        
        WEA = 4'b1100;
        DINA = 32'hEEEEEEEE;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hEEEEFFFF)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("Writting halfword (lower)...");
        
        WEA = 4'b0011;
        DINA = 32'hDDDDDDDD;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hEEEEDDDD)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("Writting byte (msb)...");
        
        WEA = 4'b1000;
        DINA = 32'hCCCCCCCC;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hCCEEDDDD)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("Writting byte (2 msb)...");
        
        WEA = 4'b0100;
        DINA = 32'hBBBBBBBB;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hCCBBDDDD)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("Writting byte (3 msb)...");
        
        WEA = 4'b0010;
        DINA = 32'hAAAAAAAA;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hCCBBAADD)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("Writting byte (4 msb)...");
        
        WEA = 4'b0001;
        DINA = 32'h99999999;
        ADDRA = 10'b0000001010;
        #20;
        
        if(DOUTA != 32'hCCBBAA99)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        $display("RAM seems to work.");
        
    end

endmodule