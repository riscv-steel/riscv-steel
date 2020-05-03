//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada
// 
// Create Date: 26.04.2020 20:30:54
// Module Name: load_unit
// Project Name: Steel Core 
// Description: Sign extends the data read from memory
// 
// Dependencies: -
// 
// Version 0.01
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "globals.vh"

module load_unit(

    input wire [1:0] LOAD_SIZE,
    input wire LOAD_UNSIGNED,
    input wire [31:0] DATA_IN,
    output wire [31:0] OUTPUT
    
    );    
    
    assign OUTPUT[7:0] = DATA_IN[7:0];
    assign OUTPUT[15:8] = LOAD_SIZE[0] | LOAD_SIZE[1] ? DATA_IN[15:8] : (LOAD_UNSIGNED == 1'b1 ? 8'b0 : {8{OUTPUT[7]}}); 
    assign OUTPUT[31:16] = LOAD_SIZE[1] ? DATA_IN[31:16] : (LOAD_UNSIGNED == 1'b1 ? 16'b0 : {16{OUTPUT[15]}});
    
                                                                
endmodule
