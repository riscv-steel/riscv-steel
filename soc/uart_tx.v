//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 05.08.2020 13:52:21
// Module Name: uart_tx
// Project Name: Steel SoC 
// Description: UART transmitter (9600 baud, 1 stop bit, no parity, no control)
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

module uart_tx(

    input wire CLK,
    input wire [7:0] WDATA,
    input wire WR_EN,
    output wire [31:0] RDATA,
    output reg TX
    
    );
    
    // Regs and wires
    wire done;
    reg [9:0] data;
    reg [14:0] timer;
    reg [3:0] index;
    
    // States
    parameter STATE_READY   = 2'b01;
    parameter STATE_LOAD    = 2'b10;
    parameter STATE_SEND    = 2'b00;
    
    // State registers
    reg [2:0] tx_state;    
    
    // State update    
    always @(posedge CLK)
    begin
        case (tx_state)
            STATE_READY:
            begin
                if(WR_EN == 1'b1) tx_state <= STATE_LOAD;
                else tx_state <= STATE_READY;
            end
            STATE_LOAD: tx_state <= STATE_SEND;
            STATE_SEND:
            begin
                if(done)
                begin
                    if(index == 10) tx_state <= STATE_READY;
                    else tx_state <= STATE_LOAD;
                end
            end    
            default: tx_state <= STATE_READY;        
        endcase
    end
    
    // Timer
    always @(posedge CLK)
    begin
        if(tx_state == STATE_READY) timer <= 15'b0;
        else if(done) timer <= 15'b0;
        else timer <= timer + 1;
    end
    
    assign done = (timer == 5208) ? 1'b1 : 1'b0;
    
    // Data index update    
    always @(posedge CLK)
    begin
        if(tx_state == STATE_READY) index <= 1'b0;
        else if(tx_state == STATE_LOAD) index <= index + 1;
    end
    
    // Data update
    always @(posedge CLK)
    begin
        if(tx_state == STATE_READY && WR_EN == 1'b1) data <= {1'b1, WDATA, 1'b0};
    end
    
    // Output generation
    always @(posedge CLK)
    begin
        if(tx_state == STATE_READY) TX <= 1'b1;
        else if(tx_state == STATE_LOAD) TX <= data[index];
        else TX <= TX;
    end
    
    // Output assignments
    assign RDATA = {31'b0, tx_state[0]};

endmodule