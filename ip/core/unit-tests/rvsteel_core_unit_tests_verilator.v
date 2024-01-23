/**************************************************************************************************

MIT License

Copyright (c) RISC-V Steel Project

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

Project Name:  RISC-V Steel 32-bit Processor Core - Unit tests from the RISC-V Architectural Suite
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

**************************************************************************************************/

module rvsteel_core_verilator_sim(input clock);

  reg reset;
  reg halt;

  wire   [31:0]  rw_address;
  wire   [31:0]  read_data;
  wire           read_request;
  wire           read_response;
  wire   [31:0]  write_data;
  wire   [3:0 ]  write_strobe;
  wire           write_request;
  wire           write_response;
  
  rvsteel_core
  dut0 (

    // Global signals
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
    .halt                         (halt                         ),
  
    // IO interface
  
    .rw_address                   (rw_address                   ),
    .read_data                    (read_data                    ),
    .read_request                 (read_request                 ),
    .read_response                (read_response                ),
    .write_data                   (write_data                   ),
    .write_strobe                 (write_strobe                 ),
    .write_request                (write_request                ),
    .write_response               (write_response               ),
  
    // Interrupt signals (hardwire inputs to zero if unused)
  
    .irq_external                 (1'b0                         ),
    .irq_external_response        (),
    .irq_timer                    (1'b0                         ),
    .irq_timer_response           (),
    .irq_software                 (1'b0                         ),
    .irq_software_response        (),
  
    // Real Time Clock (hardwire to zero if unused)
  
    .real_time_clock              (64'b0                        )

  );
  
  ram_memory #(
    
    .MEMORY_SIZE                  (2097152                      )
  
  ) dut1 (
  
    // Global signals
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
    
    // IO interface
  
    .rw_address                   (rw_address                   ),
    .read_data                    (read_data                    ),
    .read_request                 (read_request                 ),
    .read_response                (read_response                ),
    .write_data                   (write_data                   ),
    .write_strobe                 (write_strobe                 ),
    .write_request                (write_request                ),
    .write_response               (write_response               )    

  );
    
  string unit_test_programs_array [0:44];
  string golden_reference_array [0:44];
  
  integer     i, m, n, z;
  integer     first_cycle;
  integer     cycle_count;
  integer     current_test;
  reg [31:0]  current_golden_reference [0:2047];
 
  initial begin

    unit_test_programs_array[0] = "../unit-tests/programs/add-01.hex";
    unit_test_programs_array[1] = "../unit-tests/programs/addi-01.hex";
    unit_test_programs_array[2] = "../unit-tests/programs/and-01.hex";
    unit_test_programs_array[3] = "../unit-tests/programs/andi-01.hex";
    unit_test_programs_array[4] = "../unit-tests/programs/auipc-01.hex";
    unit_test_programs_array[5] = "../unit-tests/programs/beq-01.hex";
    unit_test_programs_array[6] = "../unit-tests/programs/bge-01.hex";
    unit_test_programs_array[7] = "../unit-tests/programs/bgeu-01.hex";
    unit_test_programs_array[8] = "../unit-tests/programs/blt-01.hex";
    unit_test_programs_array[9] = "../unit-tests/programs/bltu-01.hex";
    unit_test_programs_array[10] = "../unit-tests/programs/bne-01.hex";
    unit_test_programs_array[11] = "../unit-tests/programs/ebreak.hex";
    unit_test_programs_array[12] = "../unit-tests/programs/ecall.hex";
    unit_test_programs_array[13] = "../unit-tests/programs/fence-01.hex";
    unit_test_programs_array[14] = "../unit-tests/programs/jal-01.hex";
    unit_test_programs_array[15] = "../unit-tests/programs/jalr-01.hex";
    unit_test_programs_array[16] = "../unit-tests/programs/lb-align-01.hex";
    unit_test_programs_array[17] = "../unit-tests/programs/lbu-align-01.hex";
    unit_test_programs_array[18] = "../unit-tests/programs/lh-align-01.hex";
    unit_test_programs_array[19] = "../unit-tests/programs/lhu-align-01.hex";
    unit_test_programs_array[20] = "../unit-tests/programs/lui-01.hex";
    unit_test_programs_array[21] = "../unit-tests/programs/lw-align-01.hex";
    unit_test_programs_array[22] = "../unit-tests/programs/misalign-lh-01.hex";
    unit_test_programs_array[23] = "../unit-tests/programs/misalign-lhu-01.hex";
    unit_test_programs_array[24] = "../unit-tests/programs/misalign-lw-01.hex";
    unit_test_programs_array[25] = "../unit-tests/programs/misalign-sh-01.hex";
    unit_test_programs_array[26] = "../unit-tests/programs/misalign-sw-01.hex";
    unit_test_programs_array[27] = "../unit-tests/programs/or-01.hex";
    unit_test_programs_array[28] = "../unit-tests/programs/ori-01.hex";
    unit_test_programs_array[29] = "../unit-tests/programs/sb-align-01.hex";
    unit_test_programs_array[30] = "../unit-tests/programs/sh-align-01.hex";
    unit_test_programs_array[31] = "../unit-tests/programs/sll-01.hex";
    unit_test_programs_array[32] = "../unit-tests/programs/slli-01.hex";
    unit_test_programs_array[33] = "../unit-tests/programs/slt-01.hex";
    unit_test_programs_array[34] = "../unit-tests/programs/slti-01.hex";
    unit_test_programs_array[35] = "../unit-tests/programs/sltiu-01.hex";
    unit_test_programs_array[36] = "../unit-tests/programs/sltu-01.hex";
    unit_test_programs_array[37] = "../unit-tests/programs/sra-01.hex";
    unit_test_programs_array[38] = "../unit-tests/programs/srai-01.hex";
    unit_test_programs_array[39] = "../unit-tests/programs/srl-01.hex";
    unit_test_programs_array[40] = "../unit-tests/programs/srli-01.hex";
    unit_test_programs_array[41] = "../unit-tests/programs/sub-01.hex";
    unit_test_programs_array[42] = "../unit-tests/programs/sw-align-01.hex";
    unit_test_programs_array[43] = "../unit-tests/programs/xor-01.hex";
    unit_test_programs_array[44] = "../unit-tests/programs/xori-01.hex";

    golden_reference_array[0] = "../unit-tests/references/add-01.reference.hex";
    golden_reference_array[1] = "../unit-tests/references/addi-01.reference.hex";
    golden_reference_array[2] = "../unit-tests/references/and-01.reference.hex";
    golden_reference_array[3] = "../unit-tests/references/andi-01.reference.hex";
    golden_reference_array[4] = "../unit-tests/references/auipc-01.reference.hex";
    golden_reference_array[5] = "../unit-tests/references/beq-01.reference.hex";
    golden_reference_array[6] = "../unit-tests/references/bge-01.reference.hex";
    golden_reference_array[7] = "../unit-tests/references/bgeu-01.reference.hex";
    golden_reference_array[8] = "../unit-tests/references/blt-01.reference.hex";
    golden_reference_array[9] = "../unit-tests/references/bltu-01.reference.hex";
    golden_reference_array[10] = "../unit-tests/references/bne-01.reference.hex";
    golden_reference_array[11] = "../unit-tests/references/ebreak.reference.hex";
    golden_reference_array[12] = "../unit-tests/references/ecall.reference.hex";
    golden_reference_array[13] = "../unit-tests/references/fence-01.reference.hex";
    golden_reference_array[14] = "../unit-tests/references/jal-01.reference.hex";
    golden_reference_array[15] = "../unit-tests/references/jalr-01.reference.hex";
    golden_reference_array[16] = "../unit-tests/references/lb-align-01.reference.hex";
    golden_reference_array[17] = "../unit-tests/references/lbu-align-01.reference.hex";
    golden_reference_array[18] = "../unit-tests/references/lh-align-01.reference.hex";
    golden_reference_array[19] = "../unit-tests/references/lhu-align-01.reference.hex";
    golden_reference_array[20] = "../unit-tests/references/lui-01.reference.hex";
    golden_reference_array[21] = "../unit-tests/references/lw-align-01.reference.hex";
    golden_reference_array[22] = "../unit-tests/references/misalign-lh-01.reference.hex";
    golden_reference_array[23] = "../unit-tests/references/misalign-lhu-01.reference.hex";
    golden_reference_array[24] = "../unit-tests/references/misalign-lw-01.reference.hex";
    golden_reference_array[25] = "../unit-tests/references/misalign-sh-01.reference.hex";
    golden_reference_array[26] = "../unit-tests/references/misalign-sw-01.reference.hex";
    golden_reference_array[27] = "../unit-tests/references/or-01.reference.hex";
    golden_reference_array[28] = "../unit-tests/references/ori-01.reference.hex";
    golden_reference_array[29] = "../unit-tests/references/sb-align-01.reference.hex";
    golden_reference_array[30] = "../unit-tests/references/sh-align-01.reference.hex";
    golden_reference_array[31] = "../unit-tests/references/sll-01.reference.hex";
    golden_reference_array[32] = "../unit-tests/references/slli-01.reference.hex";
    golden_reference_array[33] = "../unit-tests/references/slt-01.reference.hex";
    golden_reference_array[34] = "../unit-tests/references/slti-01.reference.hex";
    golden_reference_array[35] = "../unit-tests/references/sltiu-01.reference.hex";
    golden_reference_array[36] = "../unit-tests/references/sltu-01.reference.hex";
    golden_reference_array[37] = "../unit-tests/references/sra-01.reference.hex";
    golden_reference_array[38] = "../unit-tests/references/srai-01.reference.hex";
    golden_reference_array[39] = "../unit-tests/references/srl-01.reference.hex";
    golden_reference_array[40] = "../unit-tests/references/srli-01.reference.hex";
    golden_reference_array[41] = "../unit-tests/references/sub-01.reference.hex";
    golden_reference_array[42] = "../unit-tests/references/sw-align-01.reference.hex";
    golden_reference_array[43] = "../unit-tests/references/xor-01.reference.hex";
    golden_reference_array[44] = "../unit-tests/references/xori-01.reference.hex";
    
    i = 0;
    m = 0;
    n = 0;
    z = 0;
    first_cycle = 1;
    cycle_count = 0;
    current_test = 0;
    reset   = 1'b0;
    halt    = 1'b0;
      
    $display("Running unit test programs from RISC-V Architectural Test Suite.");
  
  end

  always @(posedge clock) begin
    
    if (current_test < 45) begin

      if (first_cycle == 1) begin

        // Reset     
        reset = 1'b1;
        for(i = 0; i < 524287; i=i+1) dut1.ram[i] = 32'hdeadbeef;
        for(i = 0; i < 2048;   i=i+1) current_golden_reference[i] = 32'hdeadbeef;
        
        // Initialization
        $readmemh(unit_test_programs_array[current_test],  dut1.ram                );      
        $readmemh(golden_reference_array[current_test],    current_golden_reference);

        $display("Running test: %s", unit_test_programs_array[current_test]);
        first_cycle = 0;

      end
      else reset = 1'b0;

      // Main loop: run test
      if (cycle_count < 500000) begin

        cycle_count = cycle_count + 1;
                
        // After each clock cycle it tests whether the test program finished its execution
        // This event is signaled by writing 1 to the address 0x00001000
        if(rw_address == 32'h00001000 &&
           write_request == 1'b1 &&
           write_data == 32'h00000001) begin
           
          // The beginning and end of signature are stored at
          // 0x00001ffc (ram[2046]) and 0x00001ff8 (ram[2047]).
          m =  {9'b0, dut1.ram[2047][24:2]}; // m holds the address of the beginning of the signature
          n =  {9'b0, dut1.ram[2046][24:2]}; // n holds the address of the end of the signature
          
          // Compare signature with golden reference
          z = 0;
          for(m = {9'b0, dut1.ram[2047][24:2]}; m < n; m=m+1) begin
            if (dut1.ram[m] !== current_golden_reference[z]) begin
              $display("TEST FAILED: %s", unit_test_programs_array[current_test]);
              $display("-- Signature at line %d differs from golden reference.", z+1);
              $display("-- Signature: %h. Golden reference: %h", dut1.ram[m], current_golden_reference[z]);              
              $finish(0);
            end            
            z=z+1;
          end

          // Starts a new test
          cycle_count = 0;
          first_cycle = 1;
          current_test = current_test + 1;
          
        end

      end
      else begin
        
        // The program ran for 500000 cycles and did not finish (something is wrong)
        $display("TEST FAILED (probably hanging): %s", unit_test_programs_array[current_test]);
        $finish(0);

      end
      
    end
    else begin

      $display("------------------------------------------------------------------------------------------");
      $display("RISC-V Steel Processor Core IP passed ALL unit tests from RISC-V Architectural Test");
      $display("------------------------------------------------------------------------------------------");
      $finish(0);

    end    
   
  end

endmodule