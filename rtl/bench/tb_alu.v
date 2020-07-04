//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com)
// 
// Create Date: 03.04.2020 18:35:35
// Module Name: tb_alu
// Project Name: Steel Core
// Description: RISC-V Steel Core 32-bit ALU testbench
// 
// Dependencies: alu.v
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

module tb_alu();

    reg [31:0] OP_1;
    reg [31:0] OP_2;
    reg [3:0] OPCODE;
    wire [31:0] RESULT;
    
    alu dut(

        .OP_1(          OP_1),
        .OP_2(          OP_2),
        .OPCODE(      OPCODE),
        .RESULT(      RESULT)
    
    );
    
    reg [31:0] expected_result;
    integer i;
    
    initial
    begin
    
        $display("Testing ALU...");
        
        $display("Executing extreme values test for ADD and SUB operations...");
        
        OP_1 = 32'h00000001; // decimal = 1
        OP_2 = 32'h7FFFFFFF; // the biggest positive decimal
        OPCODE = `ALU_ADD;
        expected_result = 32'h80000000; // the lowest negative decimal
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
            
        OP_1 = 32'h80000000; // the lowest negative decimal
        OP_2 = 32'h00000001; // decimal = 1
        OPCODE = `ALU_SUB;
        expected_result = 32'h7FFFFFFF; // the biggest positive decimal
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        OP_1 = 32'h00000000; // decimal = 0
        OP_2 = 32'h00000001; // decimal = 1
        OPCODE = `ALU_SUB;
        expected_result = 32'hFFFFFFFF; // decimal = -1
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        OP_1 = 32'hFFFFFFFF; // decimal = -1
        OP_2 = 32'h00000001; // decimal = 1
        OPCODE = `ALU_ADD;
        expected_result = 32'h00000000; // decimal = 0
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        OP_1 = 32'h00000001; // decimal = 1
        OP_2 = 32'hFFFFFFFF; // decimal = -1
        OPCODE = `ALU_ADD;
        expected_result = 32'h00000000; // decimal = 0
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        OP_1 = 32'h00000001; // decimal = 1
        OP_2 = 32'hFFFFFFFF; // decimal = -1
        OPCODE = `ALU_SUB;
        expected_result = 32'h00000002; // decimal = 2
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        OP_1 = 32'hFFFFFFFF; // decimal = -1
        OP_2 = 32'h00000001; // decimal = 1
        OPCODE = `ALU_SUB;
        expected_result = 32'hFFFFFFFE; // decimal = -2
        #10;
        if (RESULT != expected_result)
            begin
                $display("FAIL. Check the results.");
                $finish;
            end
        
        $display("Test successful.");
        $display("Testing 10000 pseudorandom values for all operations...");
        
        $display("Testing ADD operation...");
            OPCODE = `ALU_ADD;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 + OP_2;
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("ADD operation successfully tested.");
        
        $display("Testing SUB operation...");
            OPCODE = `ALU_SUB;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 - OP_2;
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("SUB operation successfully tested.");
        
        $display("Testing SLTU operation...");
            OPCODE = `ALU_SLTU;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = {31'b0, OP_1 < OP_2};
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("SLTU operation successfully tested.");
        
        $display("Testing SLT operation...");
            OPCODE = `ALU_SLT;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = {31'b0, $signed(OP_1) < $signed(OP_2)};
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("SLT operation successfully tested.");
        
        $display("Testing AND operation...");
            OPCODE = `ALU_AND;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 & OP_2;
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("AND operation successfully tested.");
        
        $display("Testing OR operation...");
            OPCODE = `ALU_OR;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 | OP_2;
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("OR operation successfully tested.");
        
        $display("Testing XOR operation...");
            OPCODE = `ALU_XOR;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 ^ OP_2;
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("XOR operation successfully tested.");
        
        $display("Testing SLL operation...");
            OPCODE = `ALU_SLL;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 << OP_2[4:0];
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("SLL operation successfully tested.");
        
        $display("Testing SRL operation...");
            OPCODE = `ALU_SRL;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = OP_1 >> OP_2[4:0];
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("SRL operation successfully tested.");
        
        $display("Testing SRA operation...");
            OPCODE = `ALU_SRA;
            for(i = 0; i < 10000; i=i+1)
            begin
            
                OP_1 = $random;
                OP_2 = $random;            
                #10;
                expected_result = $signed(OP_1) >>> OP_2[4:0];
                if (RESULT != expected_result)
                begin
                    $display("FAIL. Check the results.");
                    $finish;
                end
            
            end
        $display("SRA operation successfully tested.");
        
        $display("All ALU operations successfully tested for pseudorandom values.");
        
        $display("ALU successfully tested.");
    
    end

endmodule
