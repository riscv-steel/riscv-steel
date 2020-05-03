//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada
// 
// Create Date: 26.04.2020 20:52:25
// Module Name: tb_load_unit
// Project Name: Steel Core
// Description: RISC-V Steel Core Load Unit testbench
// 
// Dependencies: load_unit.v
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "../globals.vh"

module tb_steel_top();

    reg CLK;
    reg RESET;      
    reg [63:0] REAL_TIME;        
    wire [31:0] I_ADDR;
    reg [31:0] INSTR;        
    wire [31:0] D_ADDR;
    wire [31:0] DATA_OUT;
    wire WR_REQ;
    wire [3:0] WR_MASK;
    reg [31:0] DATA_IN;        
    reg E_IRQ;
    reg T_IRQ;
    reg S_IRQ;

    steel_top dut(

        .CLK(CLK),
        .RESET(RESET),        
        .REAL_TIME(REAL_TIME),        
        .I_ADDR(I_ADDR),
        .INSTR(INSTR),        
        .D_ADDR(D_ADDR),
        .DATA_OUT(DATA_OUT),
        .WR_REQ(WR_REQ),
        .WR_MASK(WR_MASK),
        .DATA_IN(DATA_IN),        
        .E_IRQ(E_IRQ),
        .T_IRQ(T_IRQ),
        .S_IRQ(S_IRQ)

    );

endmodule