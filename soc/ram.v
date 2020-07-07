//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 06.07.2020 21:38:42
// Module Name: ram
// Project Name: Steel SoC 
// Description: 4 KByte Random Access Memory 
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

module ram(

    input wire CLK,
    
    input wire [9:0] ADDRA,
    input wire [9:0] ADDRB,
    input wire [31:0] DINA,
    input wire [3:0] WEA,
    output wire [31:0] DOUTA,
    output wire [31:0] DOUTB
     
    );
    
    reg [31:0] ram [0:1023];
    reg [9:0] prev_addra;
    reg [9:0] prev_addrb;
    
    integer i;
    
    initial
    begin
        //$readmemh("yourprogram.mem", ram);
    end
    
    always @(posedge CLK) prev_addra <= ADDRA;
    always @(posedge CLK) prev_addrb <= ADDRB;
    
    always @(posedge CLK)
    begin 
        if(WEA[0]) ram[ADDRA][7:0] <= DINA[7:0];
        if(WEA[1]) ram[ADDRA][15:8] <= DINA[15:8];
        if(WEA[2]) ram[ADDRA][23:16] <= DINA[23:16];
        if(WEA[3]) ram[ADDRA][31:24] <= DINA[31:24];
    end
    
    assign DOUTA = ram[prev_addra];
    assign DOUTB = ram[prev_addrb];
    
endmodule