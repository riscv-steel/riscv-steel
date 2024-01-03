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

`timescale 1ns / 1ps

module rvsteel_core_unit_tests();

  reg clock;
  reg reset;
  reg halt;
  
  reg read_response_test;
  reg write_response_test;  

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

    // Global clock and active-high reset
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
    .halt                         (halt                         ),
  
    // IO interface
  
    .rw_address                   (rw_address                   ),
    .read_data                    (read_data                    ),
    .read_request                 (read_request                 ),
    .read_response                (read_response &
                                   read_response_test           ),
    .write_data                   (write_data                   ),
    .write_strobe                 (write_strobe                 ),
    .write_request                (write_request                ),
    .write_response               (write_response &
                                   write_response_test          ),
  
    // Interrupt signals (hardwire inputs to zero if unused)
  
    .irq_external                 (1'b0),
    .irq_external_response             (),
    .irq_timer                    (1'b0),
    .irq_timer_response                (),
    .irq_software                 (1'b0),  
    .irq_software_response             (),
  
    // Real Time Clock (hardwire to zero if unused)
  
    .real_time_clock              (64'b0)

  );
  
  ram_memory #(
    
    .MEMORY_SIZE                  (2097152                      )
  
  ) dut1 (
  
    // Global clock and active-high reset
  
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
  
  integer     i, j, k, m, n, t, u, z;
  integer     failing_tests_counter;
  integer     current_test_failed_flag;
  reg [31:0]  current_golden_reference [0:2047];
 
  always begin
    
    read_response_test = 1'b1;
    write_response_test = 1'b1;
    #200;
    
    for (t = 0; t < 10000; t=t+1) begin
      read_response_test = $random();
      write_response_test = $random();
      #20;
    end
    
    read_response_test = 1'b1;
    write_response_test = 1'b1;
    
  end
  
  always begin
    
    halt = 1'b0;
    #1000;
    
    for (u = 0; u < 10000; u=u+1) begin
      halt = $random();
      #20;
    end
    
    halt = 1'b0;
    
  end
 
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
        if(rw_address == 32'h00001000 &&
           write_request == 1'b1 &&
           write_data == 32'h00000001) begin
           
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

module ram_memory #(

  // Memory size in bytes
  parameter MEMORY_SIZE      = 8192,
  
  // File with program and data
  parameter MEMORY_INIT_FILE = ""

  ) (
  
  // Global signals

  input   wire          clock,
  input   wire          reset,

  // IO interface

  input  wire   [31:0]  rw_address,
  output reg    [31:0]  read_data,
  input  wire           read_request,
  output reg            read_response,
  input  wire   [31:0]  write_data,
  input  wire   [3:0 ]  write_strobe,
  input  wire           write_request,
  output reg            write_response

  );

  localparam ADDR_BUS_WIDTH = $clog2(MEMORY_SIZE)-1;

  wire                        reset_internal;
  wire [ADDR_BUS_WIDTH:0]     effective_address;
  wire                        invalid_address;
  
  reg                         reset_reg;
  reg [31:0]                  ram [0:(MEMORY_SIZE/4)-1];
  
  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;
  assign invalid_address = $unsigned(rw_address) >= $unsigned(MEMORY_SIZE);

  integer i;  
  initial begin
    for (i = 0; i < MEMORY_SIZE/4; i = i + 1) ram[i] = 32'h00000000;
    if (MEMORY_INIT_FILE != "")      
      $readmemh(MEMORY_INIT_FILE,ram);
  end

  assign effective_address =
    $unsigned(rw_address[31:0] >> 2);
  
  always @(posedge clock) begin
    if (reset_internal | invalid_address)
      read_data <= 32'h00000000;
    else
      read_data <= ram[effective_address];
  end

  always @(posedge clock) begin
    if(write_request) begin
      if(write_strobe[0])
        ram[effective_address][7:0  ] <= write_data[7:0  ];
      if(write_strobe[1])
        ram[effective_address][15:8 ] <= write_data[15:8 ];
      if(write_strobe[2])
        ram[effective_address][23:16] <= write_data[23:16];
      if(write_strobe[3])
        ram[effective_address][31:24] <= write_data[31:24];
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end
  
endmodule