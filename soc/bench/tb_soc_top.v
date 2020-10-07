//////////////////////////////////////////////////////////////////////////////////
// Engineer: Rafael de Oliveira Calçada (rafaelcalcada@gmail.com) 
// 
// Create Date: 11.07.2020 14:55:12
// Module Name: tb_soc_top
// Project Name: Steel SoC 
// Description: Example SoC testbench 
// 
// Dependencies: globals.vh
//               machine_control.v
//               alu.v
//               integer_file.v
//               branch_unit.v
//               decoder.v
//               csr_file.v
//               imm_generator.v
//               load_unit.v
//               store_unit.v
//               steel_top.v
//               bus_arbiter.v
//               ram.v
//               uart_tx.v
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

module tb_soc_top();

    reg CLK;
    reg RESET;
    wire UART_TX;
    
    soc_top #(
        
        .BOOT_ADDRESS(32'h00000018)
        
        ) dut (
        
        .CLK(CLK),
        .RESET(RESET),
        .UART_TX(UART_TX)
    );
    
    always #10 CLK = !CLK;
    
    // The purpose of this testbench is to observe the UART waveform
    
    initial
    begin
        CLK = 1'b0;
        RESET = 1'b1;
        #100;
        RESET = 1'b0;
        $stop();
    end            
    
endmodule