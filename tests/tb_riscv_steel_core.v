/**************************************************************************************************

MIT License

Copyright (c) 2020-2023 Rafael Calcada

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

Project Name:  RISC-V Steel Core
Project Repo:  github.com/riscv-steel/riscv-steel-core
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

**************************************************************************************************/

/**************************************************************************************************

This is a testbench/simulation for module riscv_steel_core.
-----------------------------------------------------------

It executes all unit tests from RISC-V Compatibility Test Framework v2.0.

A successful execution ends with the message:
"RISC-V Steel Core passed ALL tests from RISC-V Compatibility Test Framework v2.0."

How tests work:
---------------

In this testbench a 2 MB memory is connected to the core. Test programs are loaded into memory
and executed. Upon compiling the tests, the RVMODEL_HALT macro were written such that:
  - The address of the beginning of the signature area is saved at 0x00001ffc
  - The address of the end of the signature area is saved at 0x00001ff8
  - The core writes 1 to address 0x00001000 to flag the test execution ended

The testbench detects the moment the core writes 1 to 0x00001000 and compares the signatures
obtained against their golden references. If the result for a test does not match the golden
reference an error message is printed and the testbench execution is stopped.

How the test programs are compiled and loaded into memory:
----------------------------------------------------------

Instruction on how to compile the test programs can be found at:

https://github.com/riscv-non-isa/riscv-arch-test/tree/old-framework-2.x

This is the branch that keeps version 2.0 of the test framework. The main branch now holds the 
current version (3.0beta).

The test programs were compiled following the instructions contained in the doc/ folder for a new
target. The compiled test programs (ELFs) were converted to 'hex dumps' and
saved as Memory Initialization Files (*.mem) with the help of elf2hex tool.
 
**************************************************************************************************/

module tb_riscv_steel_core();

  reg           clock;
  reg           reset;
  reg           halt;
  reg   [31:0]  instruction_in;
  reg   [31:0]  data_in;
  reg   [31:0]  ram [0:524287]; // 2 MB RAM memory
  reg           instruction_in_valid;
  reg           data_rw_valid;
  reg           instruction_valid_test;
  reg           data_rw_valid_test;

  wire          data_write_request;
  wire  [31:0]  instruction_address;
  wire  [31:0]  data_rw_address;
  wire  [31:0]  data_out;
  wire  [3:0 ]  data_write_strobe;
  wire          instruction_address_valid;
  wire          data_rw_address_valid;
  
  riscv_steel_core
  dut (

    // Basic system signals
    .clock                      (clock                      ),
    .reset                      (reset                      ),
    .halt                       (halt                       ),
    .boot_address               (32'h00000000               ), // boot address of all test programs

    // Instruction fetch interface
    .instruction_address        (instruction_address        ),
    .instruction_address_valid  (instruction_address_valid  ),
    .instruction_in             (instruction_in             ),
    .instruction_in_valid       (instruction_in_valid       ),
      
    // Data fetch/write interface
    .data_rw_address            (data_rw_address            ),
    .data_rw_address_valid      (data_rw_address_valid      ),
    .data_out                   (data_out                   ),
    .data_write_request         (data_write_request         ),
    .data_write_strobe          (data_write_strobe          ),
    .data_in                    (data_in                    ),
    .data_rw_valid              (data_rw_valid              ),
    
    // Interrupt signals (inputs hardwired to zero because they're not needed for the tests)
    .irq_external               (1'b0                       ),
    .irq_timer                  (1'b0                       ),
    .irq_software               (1'b0                       ),
    .irq_external_ack           (),
    .irq_timer_ack              (),
    .irq_software_ack           (),

    // Real Time Counter (hardwired to zero because they're not needed too)
    .real_time                  (64'b0                      )

  );
  
  // Reflection of *_valid signals
  always @(posedge clock) begin
    if (reset) begin
      instruction_in_valid <= 1'b0;
      data_rw_valid <= 1'b0;
    end
    else begin
      instruction_in_valid <= instruction_address_valid & instruction_valid_test;
      data_rw_valid <= data_rw_address_valid & data_rw_valid_test;
    end
  end
  
  // Randomly assert/deassert *_valid and halt signals
  integer x;
  initial begin
    #0;
    instruction_valid_test = 1'b1;
    data_rw_valid_test = 1'b1;
    halt <= 1'b0;
    for(x = 0; x < 100; x=x+1) begin
      #1000;
      instruction_valid_test = $random();
      data_rw_valid_test = $random();    
      halt <= $random();
    end
    #1000;
    instruction_valid_test = 1'b1;
    data_rw_valid_test = 1'b1;
    halt <= 1'b0;
  end

  // RAM output registers
  always @(posedge clock) begin
    if (reset) begin
      data_in            <= 32'h00000000;
      instruction_in     <= 32'h00000000;
    end
    else begin
      data_in            <= ram[$unsigned(data_rw_address     [24:2])];
      instruction_in     <= ram[$unsigned(instruction_address [24:2])];
    end
  end
  
  // Memory implementation
  always @(posedge clock) begin
    if(data_write_request) begin
      if(data_write_strobe[0])
        ram[$unsigned(data_rw_address[24:2])][7:0  ]  <= data_out[7:0  ];
      if(data_write_strobe[1])
        ram[$unsigned(data_rw_address[24:2])][15:8 ]  <= data_out[15:8 ];
      if(data_write_strobe[2])
        ram[$unsigned(data_rw_address[24:2])][23:16]  <= data_out[23:16];
      if(data_write_strobe[3])
        ram[$unsigned(data_rw_address[24:2])][31:24]  <= data_out[31:24];
    end
  end
  
  always #10 clock = !clock;
  
  reg [8*30:0] riscv_test_program [0:53] = {
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
    "misalign-beq-01.mem",
    "misalign-bge-01.mem",
    "misalign-bgeu-01.mem",
    "misalign-blt-01.mem",
    "misalign-bltu-01.mem",
    "misalign-bne-01.mem",
    "misalign-jal-01.mem",
    "misalign-lh-01.mem",
    "misalign-lhu-01.mem",
    "misalign-lw-01.mem",
    "misalign-sh-01.mem",
    "misalign-sw-01.mem",
    "misalign1-jalr-01.mem",
    "misalign2-jalr-01.mem",
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
  
  reg [8*35:0] riscv_test_program_goldenref [0:53] = {
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
    "misalign-beq-01.reference.mem",
    "misalign-bge-01.reference.mem",
    "misalign-bgeu-01.reference.mem",
    "misalign-blt-01.reference.mem",
    "misalign-bltu-01.reference.mem",
    "misalign-bne-01.reference.mem",
    "misalign-jal-01.reference.mem",
    "misalign-lh-01.reference.mem",
    "misalign-lhu-01.reference.mem",
    "misalign-lw-01.reference.mem",
    "misalign-sh-01.reference.mem",
    "misalign-sw-01.reference.mem",
    "misalign1-jalr-01.reference.mem",
    "misalign2-jalr-01.reference.mem",
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
  
  integer i, j, k, m, n, z;
  integer test_error_flag;
  integer current_test_goldenref_match;
  reg [31:0] current_test_goldenref [0:2047];
  
  initial begin
  
    reset = 1'b0;        
    clock = 1'b0;
    test_error_flag = 0; // value '0' flags no errors
      
    $display("Running test programs from RISC-V Compatibility Test Framework v2.0.");
    
    for(k = 0; k < 54; k=k+1) begin            
      // Reset
      reset = 1'b1;
      #20;
      reset = 1'b0;
      // Clear RAM
      for(i = 0; i < 524287; i=i+1) ram[i] = 32'b0;
      // Clear signature
      for(i = 0; i < 2048;   i=i+1) current_test_goldenref[i] = 32'b0;
      // Load test program into RAM
      $readmemh(riscv_test_program[k],ram);      
      // Load reference signature for this test
      $readmemh(riscv_test_program_goldenref[k],current_test_goldenref);   
      // Execution is aborted if j reaches 500000 cycles (~1ms)
      for(j = 0; j < 500000; j=j+1) begin
        #20;
        // Tests flag the end of their execution by writing 1 to the address 0x00001000
        if(data_write_request == 1'b1 && data_rw_address == 32'h00001000) begin   
          // The start and final memory position of the signature are stored at
          // 0x00001ffc (ram[2046]) and 0x00001ff8 (ram[2047]).
          m = ram[2047][24:2];
          n = ram[2046][24:2];
          z = 0;
          current_test_goldenref_match = 0;
          for(m = ram[2047][24:2]; m < n; m=m+1) begin
            if (ram[m] !== current_test_goldenref[z]) begin
              $display("TEST FAILED: %s", riscv_test_program[k]);
              $display("Signature at line %d differs from golden reference.", z+1);
              $display("Signature: %h. Golden reference: %h", ram[m], current_test_goldenref[z]);
              test_error_flag = 1; // value '1' flags an error
              current_test_goldenref_match = 1; // not a match!
              $stop();
            end
            z=z+1;
          end
          if (current_test_goldenref_match == 0) begin            
            $display("Passed on test: %s", riscv_test_program[k]);            
            j = 999999; // large value skips this loop (without flagging error)
          end
        end
      end
      // The program ran for 500000 cycles and did not reach a result (test failed)
      if (j == 500000) begin
        $display("TEST FAILED (probably hanging): %s", riscv_test_program[k]);
        $stop();
      end
    end
    
    if (test_error_flag == 0) begin
      $display("RISC-V Steel Core passed ALL tests from RISC-V Compatibility Test Framework v2.0.");
      $stop();
    end
    else begin
      $display("FAILED on one or more tests. Sorry.");
      $stop();
    end
   
  end

endmodule