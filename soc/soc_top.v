//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 04.07.2020 20:56:52
// Module Name: soc_top
// Project Name: Steel SoC 
// Description: An example system built with Steel Core 
// 
// Dependencies: steel_top.v
//               bus_arbiter.v
//               ram.v
//               gpio.v
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

-----------------------------------------------------------------------------

Licença MIT

Copyright (c) 2019 Rafael de Oliveira Calçada

Permissão é concedida, gratuitamente, a qualquer pessoa que obtenha uma
cópia deste software e dos arquivos de documentação associados
(o "Software"), para negociar sobre o Software sem restrições, incluindo,
sem limitação, os direitos de uso, cópia, modificação, fusão, publicação, 
distribuição, sublicenciamento e/ou venda de cópias do Software e o direito
de permitir que pessoas a quem o Software seja fornecido o façam, sob as
seguintes condições:

O aviso de direitos autorais acima e este aviso de permissão devem ser
incluídos em todas as cópias ou partes substanciais do Software.

O SOFTWARE É FORNECIDO "TAL COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO,
EXPRESSA OU IMPLÍCITA, INCLUINDO, MAS NÃO SE LIMITANDO A GARANTIAS DE
COMERCIALIZAÇÃO, ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA E NÃO INFRAÇÃO.
EM NENHUM CASO OS AUTORES OU TITULARES DE DIREITOS AUTORAIS SERÃO
RESPONSÁVEIS POR QUALQUER REIVINDICAÇÃO, DANOS OU OUTRA RESPONSABILIDADE,
SEJA EM AÇÕES CIVIS, PENAIS OU OUTRAS, PROVENIENTE, FORA OU EM CONEXÃO
COM O SOFTWARE OU O USO RELACIONADO AO SOFTWARE.

********************************************************************************/

`timescale 1ns / 1ps

module soc_top(

    input wire CLK,
    input wire RESET,
    
    inout wire [15:0] GPIO
    
    );
    
    wire [63:0] timer;
    wire e_irq;
    wire [31:0] daddr_gpio;
    wire [31:0] daddr_core;
    wire [31:0] daddr_mem;
    wire [31:0] dout_gpio;
    wire [31:0] dout_core;
    wire [31:0] dout_mem;
    wire wr_req_gpio;
    wire wr_req_core;
	wire wr_req_mem;
    wire [31:0] din_gpio;
    wire [31:0] din_core;
    wire [31:0] din_mem;
    wire [3:0] wr_mask_core;
    wire [3:0] wr_mask_mem;
    wire [31:0] i_addr;
    wire [31:0] instr;
	 
    steel_top core(
    
        .CLK(CLK),
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
        
        .CLK(CLK),
        .RESET(RESET),
        .D_ADDR(daddr_core),
        .DATA_OUT(dout_core),
        .WR_REQ(wr_req_core),
        .WR_MASK(wr_mask_core),
        .DATA_IN(din_core),
        
        .D_ADDR_1(daddr_gpio),
        .DATA_OUT_1(dout_gpio),
        .WR_MASK_1(),
        .WR_REQ_1(wr_req_gpio),
        .DATA_IN_1(din_gpio),
        
        .D_ADDR_2(daddr_mem),
        .DATA_OUT_2(dout_mem),
        .WR_REQ_2(wr_req_mem),
        .WR_MASK_2(wr_mask_mem),
        .DATA_IN_2(din_mem)     
        
        );
        
    ram mem(
        
        .CLK(CLK),
        .ADDRA(daddr_mem[11:2]),
        .ADDRB(i_addr[11:2]),
        .DINA(dout_mem),
        .WEA(wr_mask_mem),
        .DOUTA(din_mem),
        .DOUTB(instr)
        
        ); 
    
	/*ram ram_inst(
			.address_a ( i_addr[6:2] ),
			.address_b ( daddr_mem[6:2] ),
			.byteena_b ( wr_mask_mem ),
			.clock ( CLK ),
			.data_a ( 32'b0 ),
			.data_b ( dout_mem ),
			.wren_a ( 1'b0 ),
			.wren_b ( wr_req_mem ),
			.q_a ( instr ),
			.q_b ( din_mem )
			);*/
	 
    gpio io(
    
        .CLK(CLK),
        .RESET(RESET),
        .WDATA(dout_gpio[0]),
        .WADDR(daddr_gpio[7:2]),
        .WR_EN(wr_req_gpio),
        .RDATA(din_gpio),
        .IRQ(e_irq),
        .GPIO(GPIO)
        );
    
endmodule