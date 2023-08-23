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

Project Name:  RISC-V Steel Core
Project Repo:  github.com/riscv-steel/riscv-steel-core
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

**************************************************************************************************/

/**************************************************************************************************

This is a testbench/simulation for module riscv_steel_core intended to be run in AMD Xilinx Vivado.

How to run it in Vivado:
------------------------

  - Open project riscv-arch-test.xpr (located in tests/riscv-architectural-test-suite) in Vivado
    and click on "Run simulation > Run behavioral simulation".
  - Run the simulation for at least 3ms by executing "run 3ms" in Vivado's integraged Tcl Console.

The following message is displayed on the Tcl Console for a successful run:

    "RISC-V Steel passed ALL unit tests from RISC-V Architectural Test Suite."

How this simulation work:
-------------------------

The RISC-V Architectural Test Suite (https://github.com/riscv-non-isa/riscv-arch-test/) provides a
set of unit test programs written in assembly that can be used to check whether a device meets the
functional specifications of the RISC-V architecture. Each unit test is intended to test a single
instruction and generates a signature with the results of its execution. A instruction following
its functional specification must generate the same signature from a golden reference signature
provided by the Test Suite.

For this simulation we compiled all unit test programs for a RV32I device. As required by the Test
Suite we modified the assembly macro RVMODEL_HALT (called when a unit test completes execution)
such that:

  - the memory address where the generated signature begins gets saved at 0x00001ffc
  - the memory address where the generated signature ends gets saved at 0x00001ff8
  - a STORE instruction writing 1 to address 0x00001000 is executed after a unit test finishes
    running. This flags to the simulator the end of a unit test.
    
This simulation runs a loop to detect the moment a STORE to address 0x00001000 is executed in
RISC-V Steel, triggering the comparision between the generated signature and the golden
reference.

The compilation of the unit tests generates ELFs (binaries). Using objdump and elf2hex tools
from RISC-V GNU Toolchain the binaries are converted to 'hex dumps' and saved with *.mem 
extension so they can be used with Vivado to initialize RAM memories.

The compiled unit tests are loaded into a RAM memory connected to RISC-V Steel one at a time and
then executed.
 
**************************************************************************************************/

module riscv_steel_core_unit_tests();

  reg           clock;
  reg           reset_n;
  
  reg   [31:0]  ram [0:524287];

  wire  [31:0]  mem_address;
  reg   [31:0]  mem_read_data;  
  wire          mem_read_request;
  reg           mem_read_request_ack;
  wire  [31:0]  mem_write_data;
  wire          mem_write_request;
  reg           mem_write_request_ack;
  wire  [3:0 ]  mem_write_strobe;  

  reg           data_read_request_ack_test;
  reg           data_write_request_ack_test;
  
  riscv_steel_core 
  dut (

    // Global clock and active-low reset
    .clock                      (clock                      ),
    .reset_n                    (reset_n                    ),
      
    // Memory read / write interface
    .mem_address                (mem_address                ),
    .mem_read_data              (mem_read_data              ),
    .mem_read_request           (mem_read_request           ),
    .mem_read_request_ack       (mem_read_request_ack       ),
    .mem_write_data             (mem_write_data             ),    
    .mem_write_strobe           (mem_write_strobe           ),
    .mem_write_request          (mem_write_request          ),
    .mem_write_request_ack      (mem_write_request_ack      ),    
    
    // Interrupt signals (inputs hardwired to zero because they're not needed for the tests)
    .irq_external               (1'b0                       ),
    .irq_timer                  (1'b0                       ),
    .irq_software               (1'b0                       ),
    .irq_external_ack           (),
    .irq_timer_ack              (),
    .irq_software_ack           (),

    // Real Time Counter (hardwired to zero because they're not needed too)
    .real_time_counter          (64'b0                      )

  );
  
  // Read / write acknowledgement
  always @(posedge clock) begin
    if (!reset_n) begin
      mem_read_request_ack   <= 1'b0;
      mem_write_request_ack  <= 1'b0;
    end
    else begin
      mem_read_request_ack   <= mem_read_request    & data_read_request_ack_test;
      mem_write_request_ack  <= mem_write_request   & data_write_request_ack_test;
    end
  end
  
  // Randomly assert / deassert *_ack
  integer x;
  initial begin
    #0;
    data_read_request_ack_test    = 1'b1;
    data_write_request_ack_test   = 1'b1;
    for(x = 0; x < 100; x=x+1) begin
      #1000;
      data_read_request_ack_test    = $random();
      data_write_request_ack_test   = $random();
    end
    #1000;
    data_read_request_ack_test    = 1'b1;
    data_write_request_ack_test   = 1'b1;
  end

  // RAM output registers
  always @(posedge clock)
    if (!reset_n)
      mem_read_data <= 32'h00000000;
    else
      mem_read_data <= ram[$unsigned(mem_address[20:2])];
  
  // Memory implementation
  always @(posedge clock) begin
    if(mem_write_request) begin
      if(mem_write_strobe[0])
        ram[$unsigned(mem_address[24:2])][7:0  ]  <= mem_write_data[7:0  ];
      if(mem_write_strobe[1])
        ram[$unsigned(mem_address[24:2])][15:8 ]  <= mem_write_data[15:8 ];
      if(mem_write_strobe[2])
        ram[$unsigned(mem_address[24:2])][23:16]  <= mem_write_data[23:16];
      if(mem_write_strobe[3])
        ram[$unsigned(mem_address[24:2])][31:24]  <= mem_write_data[31:24];
    end
  end
  
  always #10 clock = !clock;
  
  reg [8*30:0] unit_test_programs_array [0:44] = {
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
  
  reg [8*35:0] golden_reference_array [0:44] = {
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
  
  integer i, j, k, m, n, z;
  integer failing_tests_counter;
  integer current_test_failed_flag;
  reg [31:0] current_golden_reference [0:2047];
  
  initial begin
  
    reset_n = 1'b1;        
    clock   = 1'b0;
    failing_tests_counter = 0;
      
    $display("Running unit test programs from RISC-V Architectural Test Suite.");
    
    // Main loop: run one test in unit_test_programs_array[0:44] at a time
    for(k = 0; k < 45; k=k+1) begin       

      // Reset
      reset_n = 1'b0;
      for(i = 0; i < 524287; i=i+1) ram[i] = 32'b0;
      for(i = 0; i < 2048;   i=i+1) current_golden_reference[i] = 32'b0;
      #20;
      reset_n = 1'b1;
      
      // Initialization
      $readmemh(unit_test_programs_array[k], ram                     );
      $readmemh(golden_reference_array[k]  , current_golden_reference);   

      // Run loop
      for(j = 0; j < 500000; j=j+1) begin

        // After each clock cycle it tests whether the test program finished its execution
        // This event is signaled by writing 1 to the address 0x00001000
        #20;
        if(mem_write_request == 1'b1 &&
           mem_address == 32'h00001000 &&
           mem_write_data == 32'h00000001) begin   

          // The beginning and end of signature are stored at
          // 0x00001ffc (ram[2046]) and 0x00001ff8 (ram[2047]).
          m = ram[2047][24:2]; // m holds the address of the beginning of the signature
          n = ram[2046][24:2]; // n holds the address of the end of the signature

          // Compare signature with golden reference
          z = 0;
          current_test_failed_flag = 0;
          for(m = ram[2047][24:2]; m < n; m=m+1) begin
            if (ram[m] !== current_golden_reference[z]) begin
              $display("TEST FAILED: %s", unit_test_programs_array[k]);
              $display("Signature at line %d differs from golden reference.", z+1);
              $display("Signature: %h. Golden reference: %h", ram[m], current_golden_reference[z]);
              failing_tests_counter = failing_tests_counter + 1;
              current_test_failed_flag = 1; // not a match!
              $stop();
            end
            z=z+1;
          end

          // Skip main loop in a successful run 
          if (current_test_failed_flag == 0) begin            
            $display("Passed on test: %s", unit_test_programs_array[k]);            
            j = 999999; // large value skips this loop (without flagging error)
          end

        end // if

      end // Run loop

      // The program ran for 500000 cycles and did not finish (something is wrong)
      if (j == 500000) begin
        $display("TEST FAILED (probably hanging): %s", unit_test_programs_array[k]);
        $stop();
      end

    end // Main loop
    
    if (failing_tests_counter == 0) begin
      $display("RISC-V Steel passed ALL unit tests from RISC-V Architectural Test Suite");
      $stop();
    end
    else begin
      $display("FAILED on one or more unit tests.");
      $stop();
    end
   
  end

endmodule
