//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 02.06.2020 01:28:57
// Module Name: store_unit
// Project Name: Steel Core 
// Description: Controls the data memory interface
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

module store_unit(

    input wire [1:0] FUNCT3,
    input wire [31:0] IADDER_OUT, 
    input wire [31:0] RS2,
    input wire MEM_WR_REQ,
    output reg [31:0] DATA_OUT,
    output wire [31:0] D_ADDR,
    output reg [3:0] WR_MASK,
    output wire WR_REQ
    
    );   
    
    reg [3:0] half_wr_mask;
    reg [3:0] byte_wr_mask;
    reg [31:0] half_dout;
    reg [31:0] byte_dout;
    
    assign D_ADDR = {IADDER_OUT[31:2], 2'b0};
    assign WR_REQ = MEM_WR_REQ;
    
    always @*
    begin
    
        case(FUNCT3[1:0])
        
            2'b00: WR_MASK = byte_wr_mask;
            2'b01: WR_MASK = half_wr_mask;
            2'b10: WR_MASK = {4{MEM_WR_REQ}};
            2'b11: WR_MASK = {4{MEM_WR_REQ}};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(FUNCT3[1:0])
        
            2'b00: DATA_OUT = byte_dout;
            2'b01: DATA_OUT = half_dout;
            2'b10: DATA_OUT = RS2;
            2'b11: DATA_OUT = RS2;
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1:0])
        
            2'b00: byte_dout = {24'b0, RS2[7:0]};
            2'b01: byte_dout = {16'b0, RS2[7:0], 8'b0};
            2'b10: byte_dout = {8'b0, RS2[7:0], 16'b0};
            2'b11: byte_dout = {RS2[7:0], 24'b0};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1:0])
        
            2'b00: byte_wr_mask = {3'b0, MEM_WR_REQ};
            2'b01: byte_wr_mask = {2'b0, MEM_WR_REQ, 1'b0};
            2'b10: byte_wr_mask = {1'b0, MEM_WR_REQ, 2'b0};
            2'b11: byte_wr_mask = {MEM_WR_REQ, 3'b0};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1])
        
            1'b0: half_dout = {16'b0, RS2[15:0]};
            1'b1: half_dout = {RS2[15:0], 16'b0};
            
        endcase
    
    end
    
    always @*
    begin
    
        case(IADDER_OUT[1])
        
            1'b0: half_wr_mask = {2'b0, {2{MEM_WR_REQ}}};
            1'b1: half_wr_mask = {{2{MEM_WR_REQ}}, 2'b0};
            
        endcase
    
    end
                                                                
endmodule
