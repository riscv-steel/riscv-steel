//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 26.04.2020 20:52:25
// Module Name: tb_steel_top
// Project Name: Steel Core
// Description: RISC-V Steel Core testbench
// 
// Dependencies: load_unit.v
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
`include "../globals.vh"

module tb_steel_top();

    reg CLK;
    reg RESET;              
    wire [31:0] I_ADDR;
    reg [31:0] INSTR;        
    wire [31:0] D_ADDR;
    wire [31:0] DATA_OUT;
    wire WR_REQ;
    wire [3:0] WR_MASK;
    reg [31:0] DATA_IN;        
    reg E_IRQ;
    reg T_IRQ;
    reg S_IRQ;

    steel_top dut(

        .CLK(CLK),
        .RESET(RESET),        
        .REAL_TIME(64'b0),        
        .I_ADDR(I_ADDR),
        .INSTR(INSTR),        
        .D_ADDR(D_ADDR),
        .DATA_OUT(DATA_OUT),
        .WR_REQ(WR_REQ),
        .WR_MASK(WR_MASK),
        .DATA_IN(DATA_IN),        
        .E_IRQ(E_IRQ),
        .T_IRQ(T_IRQ),
        .S_IRQ(S_IRQ)

    );
    
    reg [7:0] ram [0:65535]; // 8KB RAM
    integer i;
    integer f;
    wire [12:0] eff_i_addr;
    wire [12:0] eff_d_addr;
    
    assign eff_i_addr = I_ADDR[12:0];
    assign eff_d_addr = D_ADDR[12:0];    
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    initial
    begin
    
        f = $fopen("../../../../../mem/bgeu.txt","w");
        
        // LOADS PROGRAM INTO MEMORY 
        for(i = 0; i < 65535; i=i+1) ram[i] = 8'b0;
        $readmemh("bgeu.mem",ram);
        
        // INITIAL VALUES
        RESET = 1'b0;        
        CLK = 1'b0;        
        E_IRQ = 1'b0;
        T_IRQ = 1'b0;
        S_IRQ = 1'b0;
        
        // RESET
        #5;
        RESET = 1'b1;
        #15;
        RESET = 1'b0;
                   
        #800;
        
        $fwrite(f, "%d", ram[1024]);
        $fclose(f);        
        
        $stop;
        
    end
    
    always @(posedge CLK or posedge RESET)
    begin
        if(RESET)
        begin
            INSTR = {ram[eff_i_addr+3],ram[eff_i_addr+2],ram[eff_i_addr+1],ram[eff_i_addr]};
            DATA_IN = {ram[eff_d_addr+3],ram[eff_d_addr+2],ram[eff_d_addr+1],ram[eff_d_addr]};
        end
        else
        begin
            INSTR = {ram[eff_i_addr+3],ram[eff_i_addr+2],ram[eff_i_addr+1],ram[eff_i_addr]};
            DATA_IN = {ram[eff_d_addr+3],ram[eff_d_addr+2],ram[eff_d_addr+1],ram[eff_d_addr]};
            if(WR_REQ)
            begin
                ram[eff_d_addr] <= DATA_OUT[7:0];
                if(WR_MASK[1])
                begin
                    ram[eff_d_addr+1] <= DATA_OUT[15:8];
                end
                if(WR_MASK[2])
                begin
                    ram[eff_d_addr+2] <= DATA_OUT[23:16];
                end
                if(WR_MASK[3])
                begin
                    ram[eff_d_addr+3] <= DATA_OUT[31:24];
                end
            end
            else
            begin                
                DATA_IN = {ram[eff_d_addr+3],ram[eff_d_addr+2],ram[eff_d_addr+1],ram[eff_d_addr]};
            end
        end
    end

endmodule
