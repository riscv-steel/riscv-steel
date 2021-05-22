//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 06.07.2020 21:30:07
// Module Name: bus_arbiter
// Project Name: Steel SoC 
// Description: Bus arbiter 
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

module bus_arbiter(
    input wire CLK,
    input wire RESET,
    
    // Connection with the core
    input wire [31:0] D_ADDR,
    input wire [31:0] DATA_OUT,
    input wire WR_REQ,
    input wire [3:0] WR_MASK,
    output reg [31:0] DATA_IN,
    
    // PORT #1 - Connected to UART
    output wire [31:0] DATA_OUT_1,
    output wire WR_REQ_1,
    input wire [31:0] DATA_IN_1,
    
    // PORT #2 - Connected to MAIN MEMORY
    output wire [31:0] D_ADDR_2,
    output wire [31:0] DATA_OUT_2,
    output wire WR_REQ_2,
    output wire [3:0] WR_MASK_2,
    input wire [31:0] DATA_IN_2,
    
    // PORT #3 - Connected to UART receiver
    output wire D_ADDR_3,
    input wire [31:0] DATA_IN_3,
    output wire WR_REQ_3
    
    );
    
    reg [1:0] last_access;
    wire uart_tx_access = D_ADDR[31:16] == 16'h0001;
    wire uart_rx_access = D_ADDR[31:16] == 16'h0002;
    wire ram_access = ~(uart_tx_access | uart_rx_access);
    
    always @(posedge CLK)
    begin
        if(RESET) last_access <= 2'b00;
        else begin
            if(uart_tx_access == 1'b1) last_access <= 2'b01;
            else if(uart_rx_access == 1'b1) last_access <= 2'b10;
            else last_access <= 2'b00;
        end
    end
    
    assign DATA_OUT_1 = uart_tx_access ? DATA_OUT : 32'b0;
    assign WR_REQ_1 = uart_tx_access ? WR_REQ : 1'b0;
    
    assign D_ADDR_2 = ram_access ? D_ADDR : 32'b0;
    assign DATA_OUT_2 = ram_access ? DATA_OUT : 32'b0;
    assign WR_REQ_2 = ram_access ? WR_REQ : 1'b0;
    assign WR_MASK_2 = ram_access ? WR_MASK : 4'b0;
    
    assign D_ADDR_3 = uart_rx_access ? D_ADDR[2] : 1'b0;
    assign WR_REQ_3 = uart_rx_access ? WR_REQ : 1'b0;
    
    always @(*)
    begin
        case (last_access)
            2'b00: DATA_IN = DATA_IN_2; // RAM
            2'b01: DATA_IN = DATA_IN_1; // UART TX
            2'b10: DATA_IN = DATA_IN_3; // UART RX
            2'b11: DATA_IN = DATA_IN_2; // RAM
        endcase
    end
    
endmodule