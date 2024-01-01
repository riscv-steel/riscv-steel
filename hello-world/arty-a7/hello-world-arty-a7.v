/**************************************************************************************************

MIT License

Copyright (c) 2020-present Rafael Calcada

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

**************************************************************************************************/

/**************************************************************************************************

Project Name:  RISC-V Steel System-on-Chip - Hello World demo for Arty-A7 FPGA development boards
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    hello_world_arty_a7
 
**************************************************************************************************/

/*

The 'clock' signal is connected to Arty's 100MHz board clock and is divided by 2.
The 'reset' signal is connected to BTN0
The 'halt'  signal is connected to BTN1
The UART signals are connect to the UART-USB bridge

*/

module hello_world_arty_a7 (

  input   wire clock,
  input   wire reset,
  input   wire halt,
  input   wire uart_rx,
  output  wire uart_tx

  );

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;  
  always @(posedge clock) clock_50mhz <= !clock_50mhz;
  
  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;  
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
    halt_debounced <= halt;
  end

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (8192               ),
    .MEMORY_INIT_FILE         ("hello-world.hex"  ),
    .BOOT_ADDRESS             (32'h00000000       )

  ) rvsteel_soc_instance (
    
    .clock                    (clock_50mhz        ),
    .reset                    (reset_debounced    ),
    .halt                     (halt_debounced     ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            )

  );

endmodule