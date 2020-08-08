//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 20:30:54
// Module Name: load_unit
// Project Name: Steel Core 
// Description: Sign extends the data read from memory
// 
// Dependencies: globals.vh
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
`include "globals.vh"

module load_unit(

    input wire [1:0] LOAD_SIZE,
    input wire LOAD_UNSIGNED,
    input wire [31:0] DATA_IN,
    input wire [1:0] IADDER_OUT_1_TO_0,
    output reg [31:0] OUTPUT
    
    );    
    
    reg [7:0] byte;
    reg [15:0] half;    
    wire [23:0] byte_ext;
    wire [15:0] half_ext;
    
    always @*
    begin
    
        case(LOAD_SIZE)
        
            2'b00: OUTPUT = {byte_ext, byte};
            2'b01: OUTPUT = {half_ext, half};
            2'b10: OUTPUT = DATA_IN;
            2'b11: OUTPUT = DATA_IN;
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT_1_TO_0)
        
            2'b00: byte = DATA_IN[7:0];
            2'b01: byte = DATA_IN[15:8];
            2'b10: byte = DATA_IN[23:16];
            2'b11: byte = DATA_IN[31:24];
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT_1_TO_0[1])
        
            1'b0: half = DATA_IN[15:0];
            1'b1: half = DATA_IN[31:16];
            
        endcase
    
    end
    
    assign byte_ext = LOAD_UNSIGNED == 1'b1 ? 24'b0 : {24{byte[7]}};
    assign half_ext = LOAD_UNSIGNED == 1'b1 ? 16'b0 : {16{half[15]}};
                                                                
endmodule
