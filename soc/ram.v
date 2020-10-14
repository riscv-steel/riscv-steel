//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 06.07.2020 21:38:42
// Module Name: ram
// Project Name: Steel SoC 
// Description: 8 KByte Random Access Memory 
// 
// Dependencies: -
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

module ram(

    input wire CLK,
    
    input wire [10:0] ADDRA,
    input wire [10:0] ADDRB,
    input wire [31:0] DINA,
    input wire [3:0] WEA,
    output wire [31:0] DOUTA,
    output wire [31:0] DOUTB
     
    );
    
    reg [31:0] ram [0:8191];
    reg [10:0] prev_addra;
    reg [10:0] prev_addrb;
    
    integer i;
    
    // MEMORY INITIALIZATION
    initial
    begin
        for(i = 0; i < 2048;i = i+1) ram[i] = 32'b0;
        $readmemh("hello.hex", ram);
    end
    
    always @(posedge CLK) prev_addra <= ADDRA;
    always @(posedge CLK) prev_addrb <= ADDRB;
    
    always @(posedge CLK)
    begin 
        if(WEA[0]) ram[ADDRA][7:0] <= DINA[7:0];
        if(WEA[1]) ram[ADDRA][15:8] <= DINA[15:8];
        if(WEA[2]) ram[ADDRA][23:16] <= DINA[23:16];
        if(WEA[3]) ram[ADDRA][31:24] <= DINA[31:24];
    end
    
    assign DOUTA = ram[prev_addra];
    assign DOUTB = ram[prev_addrb];
    
endmodule
