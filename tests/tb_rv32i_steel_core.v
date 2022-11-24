/**************************************************************************************************

MIT License

Copyright (c) 2022 Rafael Calcada

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
Project Repo:  github.com/rafaelcalcada/steel-core
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

**************************************************************************************************/

/**************************************************************************************************

This is a testbench for module rv32i_steel_core.
------------------------------------------------

It executes all unit tests from RISC-V Test Suite and all compliance tests from
RISC-V Compliance Suite.

A successful execution ends with printing:
"RISC-V Steel Core passed ALL tests from RISC-V Test and Compliance suites."

How tests work:
---------------

In this testbench a 64KB memory is connected to the core. Test programs are loaded into memory
and executed. All programs store their results at the address 0x00001000.

The results are compared against their golden references. If the result for a test does not
match the golden reference an error message is printed and the testbench execution is aborted.

How the test programs are compiled and loaded into memory:
----------------------------------------------------------

The test programs from RISC-V Test and Compliance suites were compiled following the instructions
contained in their repositories. The compiled test programs were converted to 'hex dumps' and
saved as Memory Initialization Files (*.mem) with the help o SiFive's elf2hex tool
(available at https://github.com/sifive/elf2hex). These files are loaded into memory using
Verilog's $readmemh() system task. 
 
**************************************************************************************************/

module tb_rv32i_steel_core();

  reg           clock;
  reg           reset;
  reg   [31:0]  instruction_data;
  reg   [31:0]  data_read;
  reg   [31:0]  ram [0:16383]; // 64 KB RAM memory

  wire          data_write_request;
  wire  [31:0]  instruction_address;
  wire  [31:0]  data_rw_address;
  wire  [31:0]  data_write;
  wire  [3:0 ]  data_write_mask;
  
  rv32i_steel_core dut (

    // Basic system signals
    .clock                      (clock                ),
    .reset                      (reset                ),
    .boot_address               (32'h00000000         ), // boot address of all test programs

    // Instruction fetch interface
    .instruction_address        (instruction_address  ),
    .instruction_data           (instruction_data     ),
      
    // Data fetch/write interface
    .data_rw_address            (data_rw_address      ),
    .data_write                 (data_write           ),
    .data_write_request         (data_write_request   ),
    .data_write_mask            (data_write_mask      ),
    .data_read                  (data_read            ),
    
    // Interrupt signals (hardwired to zero because they're not needed for the tests)
    .interrupt_request_external (1'b0                 ),
    .interrupt_request_timer    (1'b0                 ),
    .interrupt_request_software (1'b0                 ),

    // Real Time Counter (hardwired to zero because they're not needed too)
    .real_time                  (64'b0                )

  );
  
  // 64 KB RAM memory implementation
  always @(posedge clock or posedge reset) begin
    if(reset) begin
      instruction_data  = ram[instruction_address[16:2] ];
      data_read         = ram[data_rw_address[16:2]     ];
    end
    else begin
      instruction_data  = ram[instruction_address[16:2] ];
      data_read         = ram[data_rw_address[16:2]     ];
      if(data_write_request) begin
        if(data_write_mask[0])
          ram[data_rw_address[16:2] ][7:0  ]  <= data_write[7:0  ];
        if(data_write_mask[1])
          ram[data_rw_address[16:2] ][15:8 ]  <= data_write[15:8 ];
        if(data_write_mask[2])
          ram[data_rw_address[16:2] ][23:16]  <= data_write[23:16];
        if(data_write_mask[3])
          ram[data_rw_address[16:2] ][31:24]  <= data_write[31:24];
      end
    end
  end
  
  // 50MHz clock signal
  always #10 clock = !clock;
  
  // ----------------------------------------------------------------------------------------------
  //
  // UNIT TEST PROGRAMS (from RISC-V TEST SUITE)
  //
  // ----------------------------------------------------------------------------------------------
  
  reg [8*20:0] rv32i_unit_test_program [0:38] = {
    "rv32ui-p-addi.mem",
    "rv32ui-p-bgeu.mem",
    "rv32ui-p-lb.mem",
    "rv32ui-p-or.mem",
    "rv32ui-p-sltiu.mem",
    "rv32ui-p-sub.mem",
    "rv32ui-p-add.mem",
    "rv32ui-p-blt.mem",
    "rv32ui-p-lbu.mem",
    "rv32ui-p-sb.mem",
    "rv32ui-p-slt.mem",
    "rv32ui-p-sw.mem",
    "rv32ui-p-andi.mem",
    "rv32ui-p-bltu.mem",
    "rv32ui-p-lh.mem",
    "rv32ui-p-sh.mem",
    "rv32ui-p-sltu.mem",
    "rv32ui-p-xori.mem",
    "rv32ui-p-and.mem",
    "rv32ui-p-bne.mem",
    "rv32ui-p-lhu.mem",
    "rv32ui-p-simple.mem",
    "rv32ui-p-srai.mem",
    "rv32ui-p-xor.mem",
    "rv32ui-p-auipc.mem",
    "rv32ui-p-fence_i.mem",
    "rv32ui-p-lui.mem",
    "rv32ui-p-slli.mem",
    "rv32ui-p-sra.mem",
    "rv32ui-p-beq.mem",
    "rv32ui-p-jal.mem",
    "rv32ui-p-lw.mem",
    "rv32ui-p-sll.mem",
    "rv32ui-p-srli.mem",
    "rv32ui-p-bge.mem",
    "rv32ui-p-jalr.mem",
    "rv32ui-p-ori.mem",
    "rv32ui-p-slti.mem",
    "rv32ui-p-srl.mem"
  };
  
  // ----------------------------------------------------------------------------------------------
  //
  // COMPLIANCE TEST PROGRAMS (from RISC-V COMPLIANCE SUITE)
  //
  // ----------------------------------------------------------------------------------------------
  
  reg [8*30:0] rv32i_compliance_test_program [0:53] = {
    "I-ADD-01.elf.mem",
    "I-BLT-01.elf.mem",
    "I-JAL-01.elf.mem",
    "I-MISALIGN_JMP-01.elf.mem",
    "I-SB-01.elf.mem",
    "I-SRA-01.elf.mem",
    "I-ADDI-01.elf.mem",
    "I-BLTU-01.elf.mem",
    "I-JALR-01.elf.mem",
    "I-MISALIGN_LDST-01.elf.mem",
    "I-SH-01.elf.mem",
    "I-SRAI-01.elf.mem",
    "I-AND-01.elf.mem",
    "I-BNE-01.elf.mem",
    "I-LB-01.elf.mem",
    "I-NOP-01.elf.mem",
    "I-SLL-01.elf.mem",
    "I-SRL-01.elf.mem",
    "I-ANDI-01.elf.mem",
    "I-DELAY_SLOTS-01.elf.mem",
    "I-LBU-01.elf.mem",
    "I-OR-01.elf.mem",
    "I-SLLI-01.elf.mem",
    "I-SRLI-01.elf.mem",
    "I-AUIPC-01.elf.mem",
    "I-EBREAK-01.elf.mem",
    "I-LH-01.elf.mem",
    "I-ORI-01.elf.mem",
    "I-SLT-01.elf.mem",
    "I-SUB-01.elf.mem",
    "I-BEQ-01.elf.mem",
    "I-ECALL-01.elf.mem",
    "I-LHU-01.elf.mem",
    "I-RF_size-01.elf.mem",
    "I-SLTI-01.elf.mem",
    "I-SW-01.elf.mem",
    "I-BGE-01.elf.mem",
    "I-ENDIANESS-01.elf.mem",
    "I-LUI-01.elf.mem",
    "I-RF_width-01.elf.mem",
    "I-SLTIU-01.elf.mem",
    "I-XOR-01.elf.mem",
    "I-BGEU-01.elf.mem",
    "I-IO-01.elf.mem",
    "I-LW-01.elf.mem",
    "I-RF_x0-01.elf.mem",
    "I-SLTU-01.elf.mem",
    "I-XORI-01.elf.mem",
    "I-CSRRC-01.elf.mem",
    "I-CSRRCI-01.elf.mem",
    "I-CSRRS-01.elf.mem",
    "I-CSRRSI-01.elf.mem",
    "I-CSRRW-01.elf.mem",
    "I-CSRRWI-01.elf.mem"
  };
  
  // ----------------------------------------------------------------------------------------------
  //
  // GOLDEN REFERENCE OUTPUTS FOR COMPLIANCE TESTS
  //
  // ----------------------------------------------------------------------------------------------
  
  reg [8*30:0] rv32i_compliance_test_program_goldenref [0:53] = {
    "I-ADD-01.golden.mem",
    "I-BLT-01.golden.mem",
    "I-JAL-01.golden.mem",
    "I-MISALIGN_JMP-01.golden.mem",
    "I-SB-01.golden.mem",
    "I-SRA-01.golden.mem",
    "I-ADDI-01.golden.mem",
    "I-BLTU-01.golden.mem",
    "I-JALR-01.golden.mem",
    "I-MISALIGN_LDST-01.golden.mem",
    "I-SH-01.golden.mem",
    "I-SRAI-01.golden.mem",
    "I-AND-01.golden.mem",
    "I-BNE-01.golden.mem",
    "I-LB-01.golden.mem",
    "I-NOP-01.golden.mem",
    "I-SLL-01.golden.mem",
    "I-SRL-01.golden.mem",
    "I-ANDI-01.golden.mem",
    "I-DELAY_SLOTS-01.golden.mem",
    "I-LBU-01.golden.mem",
    "I-OR-01.golden.mem",
    "I-SLLI-01.golden.mem",
    "I-SRLI-01.golden.mem",
    "I-AUIPC-01.golden.mem",
    "I-EBREAK-01.golden.mem",
    "I-LH-01.golden.mem",
    "I-ORI-01.golden.mem",
    "I-SLT-01.golden.mem",
    "I-SUB-01.golden.mem",
    "I-BEQ-01.golden.mem",
    "I-ECALL-01.golden.mem",
    "I-LHU-01.golden.mem",
    "I-RF_size-01.golden.mem",
    "I-SLTI-01.golden.mem",
    "I-SW-01.golden.mem",
    "I-BGE-01.golden.mem",
    "I-ENDIANESS-01.golden.mem",
    "I-LUI-01.golden.mem",
    "I-RF_width-01.golden.mem",
    "I-SLTIU-01.golden.mem",
    "I-XOR-01.golden.mem",
    "I-BGEU-01.golden.mem",
    "I-IO-01.golden.mem",
    "I-LW-01.golden.mem",
    "I-RF_x0-01.golden.mem",
    "I-SLTU-01.golden.mem",
    "I-XORI-01.golden.mem",
    "I-CSRRC-01.golden.mem",
    "I-CSRRCI-01.golden.mem",
    "I-CSRRS-01.golden.mem",
    "I-CSRRSI-01.golden.mem",
    "I-CSRRW-01.golden.mem",
    "I-CSRRWI-01.golden.mem"
  };
  
  integer i, j, k, m, n, z;
  integer test_error_flag;
  integer current_test_goldenref_match;
  reg [31:0] current_test_goldenref [0:256];
  
  initial begin
  
    reset = 1'b0;        
    clock = 1'b0;
    test_error_flag = 0; // value '0' flags no errors
    
    // --------------------------------------------------------------------------------------------
    //
    // RUN UNIT TEST PROGRAMS
    //
    // --------------------------------------------------------------------------------------------
    
    $display("Running unit test programs from RISC-V Test Suite.");
    
    for(k = 0; k < 39; k=k+1) begin
      // Clear RAM
      for(i = 0; i < 16384; i=i+1) ram[i] = 32'b0;
      // Load test program into RAM
      $readmemh(rv32i_unit_test_program[k],ram);            
      // Reset core for 1 clock cycle
      #20;
      reset = 1'b1;
      #20;
      reset = 1'b0; 
      // Run test program
      // ----------------
      // 'j' is counting the number of cycles
      // Execution is aborted if j reached 500000 cycles (10ms)
      for(j = 0; j < 500000; j=j+1) begin
        // Run 1 clock cycle
        #20;
        // The test program writes the result at address 0x00001000
        if(data_write_request == 1'b1 && data_rw_address == 32'h00001000) begin
          // For unit tests, the valid result is 0x00000001
          // If the value is different prints an error message and stop
          if (data_write !== 32'h00000001) begin
            $display("TEST FAILED: %s", rv32i_unit_test_program[k]);
            test_error_flag = 1; // value '1' flags an error
            $stop();
          end
          else begin
            $display("Passed on unit test: %s", rv32i_unit_test_program[k]);            
            j = 999999; // large value skips this loop (without flagging error)
          end
        end
      end
      // The program ran for 500000 cycles and did not reach a result (test failed)
      if (j == 500000) begin
        $display("TEST FAILED (probably hanging): %s", rv32i_unit_test_program[k]);
        $stop();
      end
    end
    
    // --------------------------------------------------------------------------------------------
    //
    // RUN COMPLIANCE TEST PROGRAMS
    //
    // --------------------------------------------------------------------------------------------
    
    $display("Running compliance test programs from RISC-V Compliance Suite.");
    
    for(k = 0; k < 54; k=k+1) begin
      // Clear RAM
      for(i = 0; i < 16384; i=i+1) ram[i] = 32'b0;
      // Clear signature
      for(i = 0; i < 256;   i=i+1) current_test_goldenref[i] = 32'b0;
      // Load test program into RAM
      $readmemh(rv32i_compliance_test_program[k],ram);      
      // Load reference signature for this test
      $readmemh(rv32i_compliance_test_program_goldenref[k],current_test_goldenref);        
      // Reset core for 1 clock cycle
      #20;
      reset = 1'b1;
      #20;
      reset = 1'b0; 
      // Run test program
      // ----------------
      // 'j' is counting the number of cycles
      // Execution is aborted if j reached 500000 cycles (10ms)
      for(j = 0; j < 500000; j=j+1) begin
        // Run 1 clock cycle
        #20;
        // The compliance test flags the end of its execution by writing
        // to the address 0x00001000
        if(data_write_request == 1'b1 && data_rw_address == 32'h00001000) begin   
          // The start and final memory position of the signature are stored at
          // ram[2046] and ram[2047].
          // These addresses are accessed and their content is compared to
          // the golden reference.
          m = ram[2047][16:2]; // transforms content of ram[2047] into an index for ram[]
          n = ram[2046][16:2]; // transforms content of ram[2046] into an index for ram[]
          z = 0;
          current_test_goldenref_match = 0;
          for(m = ram[2047][16:2]; m < n; m=m+1) begin
            if (ram[m] !== current_test_goldenref[z]) begin
              $display("TEST FAILED: %s", rv32i_compliance_test_program[k]);
              $display("Signature at line %d differs from golden reference.", z+1);
              $display("Signature: %h. Golden reference: %h", ram[m], current_test_goldenref[z]);
              test_error_flag = 1; // value '1' flags an error
              current_test_goldenref_match = 1; // not a match!
              $stop();
            end
            z=z+1;
          end
          if (current_test_goldenref_match == 0) begin            
            $display("Passed on compliance test: %s", rv32i_compliance_test_program[k]);            
            j = 999999; // large value skips this loop (without flagging error)
          end
        end
      end
      // The program ran for 500000 cycles and did not reach a result (test failed)
      if (j == 500000) begin
        $display("TEST FAILED (probably hanging): %s", rv32i_compliance_test_program[k]);
        $stop();
      end
    end
    
    if (test_error_flag == 0)
      $display("RISC-V Steel Core passed ALL tests from RISC-V Test and Compliance suites.");
    else
      $display("FAILED on one or more tests. Sorry.");
   
  end

endmodule