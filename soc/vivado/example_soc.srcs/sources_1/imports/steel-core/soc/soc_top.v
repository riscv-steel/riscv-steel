//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 04.07.2020 20:56:52
// Module Name: soc_top
// Project Name: Steel Example SoC 
// Description: Example system built with Steel Core 
// 
// Dependencies: steel_core.v
//               ram.v
//               bus_arbiter.v
//               uart_tx.v
//               uart_rx.v
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

module soc_top #(

    parameter BOOT_ADDRESS = 32'h00000014
    
    )(

    input wire CLK,
    input wire RESET,
    
    input wire UART_RX,
    output wire UART_TX
    
    );
    
    wire e_irq;
    wire [31:0] daddr_uart;
    wire [31:0] daddr_core;
    wire [31:0] daddr_mem;
    wire [31:0] dout_uart_tx;
    wire [31:0] dout_uart_rx;
    wire [31:0] dout_core;
    wire [31:0] dout_mem;
    wire wr_req_uart_tx;
    wire wr_req_uart_rx;
    wire wr_req_core;
	wire wr_req_mem;
    wire [31:0] din_uart_tx;
    wire [31:0] din_uart_rx;
    wire [31:0] din_core;
    wire [31:0] din_mem;
    wire [3:0] wr_mask_core;
    wire [3:0] wr_mask_mem;
    wire [31:0] i_addr;
    wire [31:0] instr;		
	
	reg clk50mhz = 1'b0;
	always @(posedge CLK) clk50mhz <= !clk50mhz;
	
    steel_core_top #(
    
        .BOOT_ADDRESS(BOOT_ADDRESS)
    
        ) core (
    
        .CLK(clk50mhz),
        .RESET(RESET),
        .REAL_TIME(64'b0),
        .I_ADDR(i_addr),
        .INSTR(instr),
        .D_ADDR(daddr_core),
        .DATA_OUT(dout_core),
        .WR_REQ(wr_req_core),
        .WR_MASK(wr_mask_core),
        .DATA_IN(din_core),
        .E_IRQ(e_irq),
        .T_IRQ(1'b0),
        .S_IRQ(1'b0)
        
        );
        
    bus_arbiter ba(
        
        .CLK(clk50mhz),
        .RESET(RESET),
        .D_ADDR(daddr_core),
        .DATA_OUT(dout_core),
        .WR_REQ(wr_req_core),
        .WR_MASK(wr_mask_core),
        .DATA_IN(din_core),
        
        .DATA_OUT_1(dout_uart_tx),
        .WR_REQ_1(wr_req_uart_tx),
        .DATA_IN_1(din_uart_tx),
        
        .D_ADDR_2(daddr_mem),
        .DATA_OUT_2(dout_mem),
        .WR_REQ_2(wr_req_mem),
        .WR_MASK_2(wr_mask_mem),
        .DATA_IN_2(din_mem),
        
        .D_ADDR_3(daddr_uart_rx),
        .DATA_IN_3(din_uart_rx),
        .WR_REQ_3(wr_req_uart_rx)
        
        );
        
    ram mem(
        
        .CLK(clk50mhz),
        .ADDRA(daddr_mem[13:2]),
        .ADDRB(i_addr[13:2]),
        .DINA(dout_mem),
        .WEA(wr_mask_mem),
        .DOUTA(din_mem),
        .DOUTB(instr)
        
        );    
	 
    uart_tx utx(
    
        .CLK(clk50mhz),        
        .RESET(RESET),
        .WDATA(dout_uart_tx[7:0]),
        .WR_EN(wr_req_uart_tx),
        .RDATA(din_uart_tx),
        .TX(UART_TX)
        
        );
    
    uart_rx urx(
    
        .CLK(clk50mhz),
        .RESET(RESET),
        .WR_EN(wr_req_uart_rx),
        .DADDR(daddr_uart_rx),
        .DONE(e_irq),
        .RDATA(din_uart_rx),
        .RX(UART_RX)
        
        ); 
    
endmodule