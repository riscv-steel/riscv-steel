//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 05.08.2020 13:52:21
// Module Name: uart_rx
// Project Name: Steel SoC 
// Description: UART receiver (9600 baud, 1 stop bit, no parity, no control)
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

module uart_rx #(

    parameter TICKS_PER_BIT = 5208 // 9600 baud rate

    )(

    input wire CLK,
    input wire RESET,
    input wire WR_EN,
    input wire DADDR,
    input wire RX,    
    output reg [31:0] RDATA,
    output reg DONE
    
    );

    localparam TPB_HALF = TICKS_PER_BIT / 2;

    // Regs and wires
    wire done;
    wire half_done;
    reg [14:0] timer;
    reg [14:0] half_timer;
    reg [3:0] index;
    reg [7:0] RDATA_reg;
    
    // States
    localparam STATE_READY   = 3'b001;
    localparam STATE_RECEIVE = 3'b010;
    localparam STATE_DONE    = 3'b100;
    
    // State register
    reg [2:0] rx_state;
    reg [31:0] RDATA1;
    
    // Output    
    always @(*)
    begin
        case (rx_state)
            STATE_READY: DONE = 1'b0;
            STATE_RECEIVE: DONE = 1'b0;
            STATE_DONE: DONE = 1'b1;
            default: DONE = 1'b0;
        endcase
    end
    
    // State update    
    always @(posedge CLK)
    begin
        if(RESET) begin
            RDATA_reg <= 8'b00000000;
            RDATA1 <= 32'h00000000;
            rx_state <= STATE_READY;
        end
        else begin
            case (rx_state)
                STATE_READY:
                begin
                    RDATA_reg <= 8'b00000000;
                    RDATA1 <= 32'h00000000;
                    if(RX == 1'b0 && half_done) rx_state <= STATE_RECEIVE;
                    else rx_state <= STATE_READY;
                end
                STATE_RECEIVE:
                begin
                    RDATA1 <= 32'h00000000;
                    if(done)
                    begin
                        if(index == 8)
                        begin
                            RDATA_reg <= RDATA_reg;
                            rx_state <= STATE_DONE;
                        end
                        else
                        begin
                            RDATA_reg <= RDATA_reg >> 1;
                            RDATA_reg[7] <= RX;  
                            rx_state <= STATE_RECEIVE;
                        end
                    end
                    else RDATA_reg <= RDATA_reg;                    
                end
                STATE_DONE:
                begin
                    RDATA_reg <= RDATA_reg;
                    RDATA1 <= 32'h00000001;
                    if(WR_EN) rx_state <= STATE_READY;
                    else rx_state <= STATE_DONE;
                end                
                default:
                begin
                    RDATA_reg <= RDATA_reg;
                    RDATA1 <= 32'h00000000;
                    rx_state <= STATE_READY;
                end        
            endcase
        end
    end
    
    // Half Timer
    always @(posedge CLK)
    begin
        if(rx_state == STATE_READY && RX == 1'b1) half_timer <= 15'b0;
        else if(rx_state == STATE_READY && RX == 1'b0) half_timer <= half_timer + 1;
        else  half_timer <= 15'b0;        
    end
    
    assign half_done = (half_timer >= TPB_HALF) ? 1'b1 : 1'b0;
    
    // Timer
    always @(posedge CLK)
    begin
        if (rx_state == STATE_READY) timer <= 15'b0; 
        else if(rx_state == STATE_RECEIVE || rx_state == STATE_DONE)
        begin
            if(done) timer <= 15'b0;
            else timer <= timer + 1;
        end
    end
    
    assign done = (timer >= TICKS_PER_BIT) ? 1'b1 : 1'b0;
    
    // Data index update    
    always @(posedge CLK)
    begin
        if(rx_state == STATE_READY) index <= 1'b0;
        else if(done) index <= index + 1;
    end
    
    always @(posedge CLK)
    begin
        if(RESET) RDATA <= 32'b0;
        else
        begin
            if(DADDR == 1'b0) RDATA <= {24'b0, RDATA_reg};
            else RDATA <= RDATA1;
        end
    end 
    
endmodule
