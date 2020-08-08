//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 22:01:22
// Module Name: imm_generator
// Project Name: Steel Core 
// Description: Generates the immediate according with the instruction 
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

module imm_generator(
    
    input wire [31:7] INSTR,
    input wire [2:0] IMM_TYPE,
    output reg [31:0] IMM
    
    );
    
    wire [31:0] i_type;
    wire [31:0] s_type;
    wire [31:0] b_type;
    wire [31:0] u_type;
    wire [31:0] j_type;
    wire [31:0] csr_type;
    
    assign i_type = { {20{INSTR[31]}}, INSTR[31:20] };
    assign s_type = { {20{INSTR[31]}}, INSTR[31:25], INSTR[11:7] };
    assign b_type = { {19{INSTR[31]}}, INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8], 1'b0 };
    assign u_type = { INSTR[31:12], 12'h000 };
    assign j_type = { {11{INSTR[31]}}, INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21], 1'b0 };
    assign csr_type = { 27'b0, INSTR[19:15] };
    
    always @(*)
    begin
       case (IMM_TYPE)
           3'b000: IMM = i_type; 
           `I_TYPE: IMM = i_type;
           `S_TYPE: IMM = s_type;
           `B_TYPE: IMM = b_type;
           `U_TYPE: IMM = u_type;
           `J_TYPE: IMM = j_type;
           `CSR_TYPE: IMM = csr_type;
           3'b111: IMM = i_type;
       endcase
    end
    
endmodule
