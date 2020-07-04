//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 02.04.2020 23:23:16
// Module Name: register_file
// Project Name: Steel Core 
// Description: RISC-V Steel Core 32-bit Integer Register File
// 
// Dependencies: -
// 
// Version 0.02
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
`include "globals.vh"

module integer_file(
    
    input wire CLK,
    
    // connections with pipeline stage 2
    input wire [4:0] RS_1_ADDR,
    input wire [4:0] RS_2_ADDR,    
    output wire [31:0] RS_1,
    output wire [31:0] RS_2,
    
    // connections with pipeline stage 3
    input wire [4:0] RD_ADDR,
    input wire WR_EN,
    input wire [31:0] RD

    );
    
    wire [31:0] rs1_wire;
    wire [31:0] rs2_wire;  
    wire [31:1] enable;
    wire fwd_op1_enable;
    wire fwd_op2_enable;
    wire op1_zero;
    wire op2_zero;
    wire [31:0] reg_en;
    reg [31:0] rs1_reg;
    reg [31:0] rs2_reg;
    wire rs1_addr_is_x0;
    wire rs2_addr_is_x0;
    reg [31:0] Q [31:1];
    
    always @(posedge CLK)
        if(WR_EN) Q[RD_ADDR] <= RD;
    
    assign rs1_addr_is_x0 = RS_1_ADDR == 5'b00000;
    assign rs2_addr_is_x0 = RS_2_ADDR == 5'b00000;
    assign fwd_op1_enable = RS_1_ADDR == RD_ADDR ? 1'b1 : 1'b0;
    assign fwd_op2_enable = RS_2_ADDR == RD_ADDR ? 1'b1 : 1'b0;
    assign op1_zero = rs1_addr_is_x0 == 1'b1 ? 1'b1 : 1'b0;
    assign op2_zero = rs2_addr_is_x0 == 1'b1 ? 1'b1 : 1'b0;
    assign rs1_wire = fwd_op1_enable == 1'b1 ? RD : Q[RS_1_ADDR];
    assign rs2_wire = fwd_op2_enable == 1'b1 ? RD : Q[RS_2_ADDR];
    assign RS_1 = op1_zero == 1'b1 ? 32'h00000000 : rs1_wire;
    assign RS_2 = op2_zero == 1'b1 ? 32'h00000000 : rs2_wire;
    
endmodule