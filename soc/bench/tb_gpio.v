//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 05.07.2020 00:20:31
// Module Name: tb_gpio
// Project Name: Steel SoC 
// Description: GPIO Unit Testbench 
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

module tb_gpio();

    reg CLK;
    reg RESET;
    reg WDATA;
    reg [5:0] WADDR;
    reg WR_EN;
    wire [31:0] RDATA;
    wire [15:0] GPIO;
    wire IRQ;
    reg GPIO_IN [0:15];
    
    gpio dut(
        .CLK(CLK),
        .RESET(RESET),
        .WDATA(WDATA),
        .WADDR(WADDR),
        .WR_EN(WR_EN),
        .RDATA(RDATA),
        .IRQ(IRQ),
        .GPIO(GPIO)
    );
    
    assign GPIO = {GPIO_IN[15],GPIO_IN[14],GPIO_IN[13],GPIO_IN[12],GPIO_IN[11],GPIO_IN[10],GPIO_IN[9],GPIO_IN[8],GPIO_IN[7],GPIO_IN[6],GPIO_IN[5],GPIO_IN[4],GPIO_IN[3],GPIO_IN[2],GPIO_IN[1],GPIO_IN[0]};
    
    always
    begin
        #10 CLK = !CLK;
    end
    
    integer i;
    
    initial
    begin
        
        $display("Testing GPIO unit...");
        
        CLK = 1'b0;
        RESET = 1'b0;
        WR_EN = 1'b0;
        WDATA = 1'b0;
        WADDR = 6'b000000;
        GPIO_IN[15] = 1'bZ;
        GPIO_IN[14] = 1'bZ;
        GPIO_IN[13] = 1'bZ;
        GPIO_IN[12] = 1'bZ;
        GPIO_IN[11] = 1'bZ;
        GPIO_IN[10] = 1'bZ;
        GPIO_IN[9] = 1'bZ;
        GPIO_IN[8] = 1'bZ;
        GPIO_IN[7] = 1'bZ;
        GPIO_IN[6] = 1'bZ;
        GPIO_IN[5] = 1'bZ;
        GPIO_IN[4] = 1'bZ;
        GPIO_IN[3] = 1'bZ;
        GPIO_IN[2] = 1'bZ;
        GPIO_IN[1] = 1'bZ;
        GPIO_IN[0] = 1'bZ;
        
        $display("Testing values after reset...");        
        
        #5;        
        RESET = 1'b1;        
        #15;        
        RESET = 1'b0;
        
        if(RDATA !== 32'hFFFF0000)
        begin
            $display("FAIL. Check the results.");
            $stop;
        end
        
        for(i = 0; i < 16; i = i+1)
        begin 
        
            $display("Configuring GPIO number %d as input...", i+1);
            
            WR_EN = 1'b1;
            WADDR = {2'b01, i[3:0]};
            WDATA = 1'b0;
            #40;
            
            if(RDATA[i] !== 1'bZ)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Reading 1 from GPIO number %d...", i+1);
            
            WR_EN = 1'b0;
            GPIO_IN[i] = 1'b1;
            #20;
            
            if(RDATA[i] !== 1'b1)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Reading 0 from GPIO number %d...", i+1);
            
            WR_EN = 1'b0;
            GPIO_IN[i] = 1'b0;
            #20;
            
            if(RDATA[i] !== 1'b0)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Enabling interrupts for GPIO number %d...", i+1);
            
            WR_EN = 1'b1;
            WADDR = {2'b10, i[3:0]};
            WDATA = {1'b1};
            #20;
            
            $display("Checking if low->high transition triggers as interrupt...");
            GPIO_IN[i] = 1'b1;
            #40;
            
            if(IRQ !== 1'b1)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Checking if high->low transition triggers as interrupt...");
            GPIO_IN[i] = 1'b0;
            #40;
            
            if(IRQ !== 1'b1)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Disabling interrupts for GPIO number %d...", i+1);
            
            WR_EN = 1'b1;
            WADDR = {2'b10, i[3:0]};
            WDATA = {1'b0};
            #20;
            
            $display("Configuring GPIO number %d as output...", i+1);
            
            GPIO_IN[i] = 1'bZ;
            WR_EN = 1'b1;
            WADDR = {2'b01, i[3:0]};
            WDATA = 1'b1;
            #40;
            
            if(RDATA[i] !== 1'b0)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Writting 1 to GPIO number %d...", i+1);
            
            WR_EN = 1'b1;
            WADDR = {2'b00, i[3:0]};
            WDATA = 1'b1;
            #40;
            
            if(RDATA[i] !== 1'b1)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("Writting 0 to GPIO number %d...", i+1);
            
            WR_EN = 1'b1;
            WADDR = {2'b00, i[3:0]};
            WDATA = 1'b0;
            #40;
            
            if(RDATA[i] !== 1'b0)
            begin
                $display("FAIL. Check the results.");
                $stop;
            end
            
            $display("GPIO number %d successfully tested.", i+1);
        
        end
        
        $display("GPIO Unit successfully tested.");        
        
    end

endmodule