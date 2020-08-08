//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 05.08.2020 19:57:30
// Module Name: tb_uart_tx
// Project Name: Steel SoC 
// Description: UART transmitter testbench (9600 baud, 1 stop bit, no parity,
//              no control) 
// 
// Dependencies: uart_tx.v
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

module tb_uart_tx();

    reg CLK;
    reg [7:0] WDATA;
    reg WR_EN;
    wire [31:0] RDATA;
    wire TX;
    
    uart_tx dut(
        .CLK(CLK),
        .WDATA(WDATA),
        .WR_EN(WR_EN),
        .RDATA(RDATA),
        .TX(TX)
    );
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    initial
    begin
        
        // The purpose of this testbench is just to observe the UART waveform
        
        $display("Testing UART transmitter unit...");
        
        CLK = 1'b0;
        WR_EN = 1'b0;
        WDATA = 8'h11;
        
        #20;
        WR_EN = 1'b1;
        
    end

endmodule
