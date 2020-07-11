//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 05.07.2020 00:20:31
// Module Name: gpio
// Project Name: Steel SoC 
// Description: GPIO Unit 
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

module gpio(
    input wire CLK,
    input wire RESET,
    input wire WDATA,
    input wire [5:0] WADDR,
    input wire WR_EN,
    output wire [31:0] RDATA,
    output wire IRQ,
    inout wire [15:0] GPIO
    );

    reg [15:0] confvec;
    reg [15:0] invec;
    reg [15:0] outvec;
    reg [15:0] irqvec;
    
    assign RDATA = {confvec, invec};

    genvar i;
    generate
    for (i=0; i<16; i=i+1)
    begin : gengpio
        assign GPIO[i] = confvec[i] ? outvec[i] : 1'bZ;
    end
    endgenerate

    always @ (posedge CLK)
    begin
        invec <= GPIO;
        if(RESET)
        begin            
            outvec <= 16'h0000;
        end
        else if(WR_EN && WADDR[5:4] == 2'b00)
        begin
            outvec[WADDR[3:0]] <= WDATA;
        end       
    end
    
    always @ (posedge CLK)
    begin
        if(RESET)
        begin            
            confvec <= 16'hFFFF;
        end
        else if(WR_EN && WADDR[5:4] == 2'b01)
        begin
            confvec[WADDR[3:0]] <= WDATA;
        end       
    end
    
    always @ (posedge CLK)
    begin
        if(RESET)
        begin            
            irqvec <= 16'h0000;
        end
        else if(WR_EN && WADDR[5:4] == 2'b10)
        begin
            irqvec[WADDR[3:0]] <= WDATA;
        end       
    end
    
    parameter STATE_INIT =      2'b10;
    parameter STATE_CHANGE =    2'b11;
    parameter STATE_LOW  =      2'b00;
    parameter STATE_HIGH =      2'b01;
    
    reg [1:0] curr_state [0:15];
    reg [1:0] next_state [0:15];
    reg [15:0] irqsrcs;
    
    genvar j;
    generate
    for (j = 0; j < 16; j = j+1)
    begin : ios
    
        always @*
        begin
            case(curr_state[j])
                STATE_INIT:
                    if(invec[j] == 1'b0) next_state[j] = STATE_LOW;
                    else if(invec[j] == 1'b1) next_state[j] = STATE_HIGH;
                    else next_state[j] = STATE_INIT;
                STATE_LOW: 
                    if(irqvec[j] == 1'b1)
                    begin
                        if(invec[j] == 1'b1) next_state[j] = STATE_CHANGE;
                        else next_state[j] = STATE_LOW;
                    end
                    else
                    begin
                        if(invec[j] == 1'b1) next_state[j] = STATE_HIGH;
                        else next_state[j] = STATE_LOW;
                    end
                STATE_HIGH: 
                    if(irqvec[j] == 1'b1)
                    begin
                        if(invec[j] == 1'b0) next_state[j] = STATE_CHANGE;
                        else next_state[j] = STATE_HIGH;
                    end
                    else
                    begin
                        if(invec[j] == 1'b0) next_state[j] = STATE_LOW;
                        else next_state[j] = STATE_HIGH;
                    end
                STATE_CHANGE:
                    if(invec[j] == 1'b0) next_state[j] = STATE_LOW;
                    else next_state[j] = STATE_HIGH;
                default:
                    next_state[j] = STATE_INIT;
            endcase
        end
        
        always @*
        begin
            case(curr_state[j])
                STATE_INIT:     irqsrcs[j] = 1'b0;
                STATE_LOW:      irqsrcs[j] = 1'b0;
                STATE_HIGH:     irqsrcs[j] = 1'b0;
                STATE_CHANGE:   irqsrcs[j] = 1'b1;
                default:        irqsrcs[j] = 1'b0;
            endcase
        end
        
        always @(posedge CLK)
        begin
            if(RESET) curr_state[j] <= STATE_INIT;
            else curr_state[j] <= next_state[j];
        end
         
    end
    endgenerate    
    
    assign IRQ = |irqsrcs;

endmodule