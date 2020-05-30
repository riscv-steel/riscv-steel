//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 18:29:52
// Module Name: branch_unit
// Project Name: Steel Core 
// Description: RISC-V Steel Core Branch Decision Unit
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

module branch_unit(

    input wire [6:2] OPCODE_6_TO_2,
    input wire [2:0] FUNCT3,
    input wire [31:0] RS1,
    input wire [31:0] RS2,
    output wire BRANCH_TAKEN
    
    );
    
    wire pc_mux_sel;
    wire pc_mux_sel_en;
    wire is_branch;
    wire is_jal;
    wire is_jalr;
    wire is_jump;
    wire eq;
    wire ne;
    wire lt;
    wire ge;
    wire ltu;
    wire geu;
    reg take;

    assign is_jal = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & ~OPCODE_6_TO_2[4] & OPCODE_6_TO_2[3] & OPCODE_6_TO_2[2];
    assign is_jalr = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & ~OPCODE_6_TO_2[4] & ~OPCODE_6_TO_2[3] & OPCODE_6_TO_2[2];
    assign is_jump = is_jal | is_jalr;
    assign eq = (RS1 == RS2);
    assign ne = !eq;
    assign lt = RS1[31] ^ RS2[31] ? RS1[31] : ltu;
    assign ge = !lt;
    assign ltu = (RS1 < RS2);
    assign geu = !ltu;
    assign is_branch = OPCODE_6_TO_2[6] & OPCODE_6_TO_2[5] & ~OPCODE_6_TO_2[4] & ~OPCODE_6_TO_2[3] & ~OPCODE_6_TO_2[2];
    assign pc_mux_sel_en = is_branch | is_jal | is_jalr;
    assign pc_mux_sel = (is_jump == 1'b1) ? 1'b1 : take;
    assign BRANCH_TAKEN = pc_mux_sel_en & pc_mux_sel;
    
    always @(*)
    begin
        case (FUNCT3)
            3'b000: take = eq;
            3'b001: take = ne;
            3'b100: take = lt;
            3'b101: take = ge;
            3'b110: take = ltu;
            3'b111: take = geu;
            default: take = 1'b0;
        endcase
    end
    
endmodule
