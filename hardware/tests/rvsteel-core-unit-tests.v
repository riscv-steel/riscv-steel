/**************************************************************************************************

MIT License

Copyright (c) Rafael Calcada

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

Project Name:  RISC-V Steel
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

**************************************************************************************************/

/**************************************************************************************************

This is a testbench/simulation for module rvsteel_core intended to be run in AMD Xilinx Vivado.

How to run it in Vivado:
------------------------

  - Open rvsteel-core-unit-tests.xpr (located in hardware/tests/rvsteel-core-unit-tests)
    in Vivado and click on "Run simulation > Run behavioral simulation".
  - Run the simulation for at least 20ms by executing "run 20ms" in Vivado's integraged Tcl Console.

The following message is displayed in the Tcl Console for a successful run:

    "RISC-V Steel 32-bit Processor passed ALL unit tests from RISC-V Architectural Test Suite"
 
**************************************************************************************************/

`timescale 1ns / 1ps

module rvsteel_core_unit_tests();

  reg clock;
  reg reset;

  wire   [31:0]  mem_address;
  wire   [31:0]  mem_read_data;
  wire           mem_read_request;
  wire           mem_read_request_ack;
  wire   [31:0]  mem_write_data;
  wire   [3:0 ]  mem_write_strobe;
  wire           mem_write_request;
  wire           mem_write_request_ack;
  
  rvsteel_core
  dut0 (

    // Global clock and active-high reset
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
  
    // Interface with Memory
  
    .mem_address                  (mem_address                 ),
    .mem_read_data                (mem_read_data               ),
    .mem_read_request             (mem_read_request            ),
    .mem_read_request_ack         (mem_read_request_ack        ),
    .mem_write_data               (mem_write_data              ),
    .mem_write_strobe             (mem_write_strobe            ),
    .mem_write_request            (mem_write_request           ),
    .mem_write_request_ack        (mem_write_request_ack       ),
  
    // Interrupt signals (hardwire inputs to zero if unused)
  
    .irq_external                 (1'b0),
    .irq_external_ack             (),
    .irq_timer                    (1'b0),
    .irq_timer_ack                (),
    .irq_software                 (1'b0),  
    .irq_software_ack             (),
  
    // Real Time Clock (hardwire to zero if unused)
  
    .real_time_clock              (64'b0)

  );
  
  tightly_coupled_memory #(
    
    .MEMORY_SIZE                (2097152          )
  
  ) dut1 (
  
    // Global clock and active-high reset
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
    
    // Memory Interface
  
    .mem_address                  (mem_address                 ),
    .mem_read_data                (mem_read_data               ),
    .mem_read_request             (mem_read_request            ),
    .mem_read_request_ack         (mem_read_request_ack        ),
    .mem_write_data               (mem_write_data              ),
    .mem_write_strobe             (mem_write_strobe            ),
    .mem_write_request            (mem_write_request           ),
    .mem_write_request_ack        (mem_write_request_ack       )    

  );
  
  always #10 clock = !clock;
  
  reg [159:0] unit_test_programs_array [0:44] = {
    "add-01.mem",
    "addi-01.mem",
    "and-01.mem",
    "andi-01.mem",
    "auipc-01.mem",
    "beq-01.mem",
    "bge-01.mem",
    "bgeu-01.mem",
    "blt-01.mem",
    "bltu-01.mem",
    "bne-01.mem",
    "ebreak.mem",
    "ecall.mem",
    "fence-01.mem",
    "jal-01.mem",
    "jalr-01.mem",
    "lb-align-01.mem",
    "lbu-align-01.mem",
    "lh-align-01.mem",
    "lhu-align-01.mem",
    "lui-01.mem",
    "lw-align-01.mem",
    "misalign-lh-01.mem",
    "misalign-lhu-01.mem",
    "misalign-lw-01.mem",
    "misalign-sh-01.mem",
    "misalign-sw-01.mem",
    "or-01.mem",
    "ori-01.mem",
    "sb-align-01.mem",
    "sh-align-01.mem",
    "sll-01.mem",
    "slli-01.mem",
    "slt-01.mem",
    "slti-01.mem",
    "sltiu-01.mem",
    "sltu-01.mem",
    "sra-01.mem",
    "srai-01.mem",
    "srl-01.mem",
    "srli-01.mem",
    "sub-01.mem",
    "sw-align-01.mem",
    "xor-01.mem",
    "xori-01.mem"
  };
  
  reg [511:0] golden_reference_array [0:44] = {
    "add-01.reference.mem",
    "addi-01.reference.mem",
    "and-01.reference.mem",
    "andi-01.reference.mem",
    "auipc-01.reference.mem",
    "beq-01.reference.mem",
    "bge-01.reference.mem",
    "bgeu-01.reference.mem",
    "blt-01.reference.mem",
    "bltu-01.reference.mem",
    "bne-01.reference.mem",
    "ebreak.reference.mem",
    "ecall.reference.mem",
    "fence-01.reference.mem",
    "jal-01.reference.mem",
    "jalr-01.reference.mem",
    "lb-align-01.reference.mem",
    "lbu-align-01.reference.mem",
    "lh-align-01.reference.mem",
    "lhu-align-01.reference.mem",
    "lui-01.reference.mem",
    "lw-align-01.reference.mem",
    "misalign-lh-01.reference.mem",
    "misalign-lhu-01.reference.mem",
    "misalign-lw-01.reference.mem",
    "misalign-sh-01.reference.mem",
    "misalign-sw-01.reference.mem",
    "or-01.reference.mem",
    "ori-01.reference.mem",
    "sb-align-01.reference.mem",
    "sh-align-01.reference.mem",
    "sll-01.reference.mem",
    "slli-01.reference.mem",
    "slt-01.reference.mem",
    "slti-01.reference.mem",
    "sltiu-01.reference.mem",
    "sltu-01.reference.mem",
    "sra-01.reference.mem",
    "srai-01.reference.mem",
    "srl-01.reference.mem",
    "srli-01.reference.mem",
    "sub-01.reference.mem",
    "sw-align-01.reference.mem",
    "xor-01.reference.mem",
    "xori-01.reference.mem"
  };
  
  integer     i, j, k, m, n, z;
  integer     failing_tests_counter;
  integer     current_test_failed_flag;
  reg [31:0]  current_golden_reference [0:2047];
 
  initial begin
    
    i = 0;
    j = 0;
    k = 0;
    m = 0;
    n = 0;
    z = 0;    
    current_test_failed_flag = 0;
    failing_tests_counter = 0;
    clock   = 1'b0;
    reset   = 1'b0;
      
    $display("Running unit test programs from RISC-V Architectural Test Suite.");
    
    for(k = 0; k < 45; k=k+1) begin
    
      // Reset     
      reset = 1'b1;
      for(i = 0; i < 524287; i=i+1) dut1.ram[i] = 32'hdeadbeef;
      for(i = 0; i < 2048;   i=i+1) current_golden_reference[i] = 32'hdeadbeef;
      #40;
      reset = 1'b0;
      
      // Initialization
      $readmemh(unit_test_programs_array[k],  dut1.ram                );      
      $readmemh(golden_reference_array[k],    current_golden_reference);
            
      // Main loop: run test
      for(j = 0; j < 500000; j=j+1) begin
                
        // After each clock cycle it tests whether the test program finished its execution
        // This event is signaled by writing 1 to the address 0x00001000
        #20;        
        if(mem_address == 32'h00001000 &&
           mem_write_request == 1'b1 &&
           mem_write_data == 32'h00000001) begin
           
          // The beginning and end of signature are stored at
          // 0x00001ffc (ram[2046]) and 0x00001ff8 (ram[2047]).
          m =  dut1.ram[2047][24:2]; // m holds the address of the beginning of the signature
          n =  dut1.ram[2046][24:2]; // n holds the address of the end of the signature
          
          // Compare signature with golden reference
          z = 0;
          current_test_failed_flag = 0;
          for(m = dut1.ram[2047][24:2]; m < n; m=m+1) begin
            if (dut1.ram[m] !== current_golden_reference[z]) begin
              $display("TEST FAILED: %s", unit_test_programs_array[k]);
              $display("Signature at line %d differs from golden reference.", z+1);
              $display("Signature: %h. Golden reference: %h", dut1.ram[m], current_golden_reference[z]);
              failing_tests_counter = failing_tests_counter+1;
              current_test_failed_flag = 1;
              $stop();
            end            
            z=z+1;
          end
          
          // Skip main loop in a successful run 
          if (current_test_failed_flag == 0) begin            
            $display("Passed on test: %s", unit_test_programs_array[k]);            
            j = 999999; // skip main loop
          end
          
        end
      end
      
      // The program ran for 500000 cycles and did not finish (something is wrong)
      if (j == 500000) begin
        $display("TEST FAILED (probably hanging): %s", unit_test_programs_array[k]);
        $stop();
      end
      
    end
    
    if (failing_tests_counter == 0) begin
      $display("RISC-V Steel 32-bit Processor passed ALL unit tests from RISC-V Architectural Test Suite");
      $finish();
    end    
    else begin
      $display("FAILED on one or more unit tests.");
      $finish();
    end
   
  end

endmodule