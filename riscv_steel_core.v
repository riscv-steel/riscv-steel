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

Top Module:    riscv_steel_core
 
**************************************************************************************************/

`timescale 1ns / 1ps

// ------------------------------------------------------------------------------------------------
// Constants and encodings (from RISC-V specifications)
// ------------------------------------------------------------------------------------------------

`define FUNCT7_SUB          7'b0100000
`define FUNCT7_SRA          7'b0100000
`define FUNCT7_ADD          7'b0000000
`define FUNCT7_SLT          7'b0000000
`define FUNCT7_SLTU         7'b0000000
`define FUNCT7_AND          7'b0000000
`define FUNCT7_OR           7'b0000000
`define FUNCT7_XOR          7'b0000000
`define FUNCT7_SLL          7'b0000000
`define FUNCT7_SRL          7'b0000000
`define FUNCT7_SRAI         7'b0100000
`define FUNCT7_SLLI         7'b0000000
`define FUNCT7_SRLI         7'b0000000
`define FUNCT7_ECALL        7'b0000000
`define FUNCT7_EBREAK       7'b0000000
`define FUNCT7_MRET         7'b0011000
`define FUNCT3_ADD          3'b000
`define FUNCT3_SUB          3'b000
`define FUNCT3_SLT          3'b010
`define FUNCT3_SLTU         3'b011
`define FUNCT3_AND          3'b111
`define FUNCT3_OR           3'b110
`define FUNCT3_XOR          3'b100
`define FUNCT3_SLL          3'b001
`define FUNCT3_SRL          3'b101
`define FUNCT3_SRA          3'b101
`define FUNCT3_ADDI         3'b000
`define FUNCT3_SLTI         3'b010
`define FUNCT3_SLTIU        3'b011
`define FUNCT3_ANDI         3'b111
`define FUNCT3_ORI          3'b110
`define FUNCT3_XORI         3'b100
`define FUNCT3_SLLI         3'b001
`define FUNCT3_SRLI         3'b101
`define FUNCT3_SRAI         3'b101
`define FUNCT3_BEQ          3'b000
`define FUNCT3_BNE          3'b001
`define FUNCT3_BLT          3'b100
`define FUNCT3_BGE          3'b101
`define FUNCT3_BLTU         3'b110
`define FUNCT3_BGEU         3'b111
`define FUNCT3_JALR         3'b000
`define FUNCT3_SB           3'b000
`define FUNCT3_SH           3'b001
`define FUNCT3_SW           3'b010
`define FUNCT3_LB           3'b000
`define FUNCT3_LH           3'b001
`define FUNCT3_LW           3'b010
`define FUNCT3_LBU          3'b100
`define FUNCT3_LHU          3'b101
`define FUNCT3_CSRRW        3'b001
`define FUNCT3_CSRRS        3'b010
`define FUNCT3_CSRRC        3'b011
`define FUNCT3_CSRRWI       3'b101
`define FUNCT3_CSRRSI       3'b110
`define FUNCT3_CSRRCI       3'b111
`define FUNCT3_FENCE        3'b000
`define FUNCT3_ECALL        3'b000
`define FUNCT3_EBREAK       3'b000
`define FUNCT3_MRET         3'b000
`define OPCODE_OP           7'b0110011
`define OPCODE_OP_IMM       7'b0010011
`define OPCODE_LOAD         7'b0000011
`define OPCODE_STORE        7'b0100011
`define OPCODE_BRANCH       7'b1100011
`define OPCODE_JAL          7'b1101111
`define OPCODE_JALR         7'b1100111
`define OPCODE_LUI          7'b0110111
`define OPCODE_AUIPC        7'b0010111
`define OPCODE_MISC_MEM     7'b0001111
`define OPCODE_SYSTEM       7'b1110011
`define RS1_ECALL           5'b00000
`define RS1_EBREAK          5'b00000
`define RS1_MRET            5'b00000
`define RS2_ECALL           5'b00000
`define RS2_EBREAK          5'b00001
`define RS2_MRET            5'b00010
`define RD_ECALL            5'b00000
`define RD_EBREAK           5'b00000
`define RD_MRET             5'b00000
`define NOP_INSTRUCTION     32'h00000013

// ------------------------------------------------------------------------------------------------
// CSR Addresses (from RISC-V specifications)
// ------------------------------------------------------------------------------------------------

// Machine Information Registers
`define MARCHID             12'hF12
`define MIMPID              12'hF13

// Counters and timers 
`define CYCLE               12'hC00
`define TIME                12'hC01
`define INSTRET             12'hC02
`define CYCLEH              12'hC80
`define TIMEH               12'hC81
`define INSTRETH            12'hC82

// Machine Trap Setup
`define MSTATUS             12'h300
`define MSTATUSH            12'h310
`define MISA                12'h301
`define MIE                 12'h304
`define MTVEC               12'h305

// Machine Trap Handling
`define MSCRATCH            12'h340
`define MEPC                12'h341
`define MCAUSE              12'h342
`define MTVAL               12'h343
`define MIP                 12'h344

// Machine Performance Counters
`define MCYCLE              12'hB00
`define MINSTRET            12'hB02
`define MCYCLEH             12'hB80
`define MINSTRETH           12'hB82

// ------------------------------------------------------------------------------------------------
// Encodings for muxes and state machines (not from RISC-V specifications)
// ------------------------------------------------------------------------------------------------

// Writeback Mux selection
`define WB_ALU                 3'b000
`define WB_LOAD_UNIT           3'b001
`define WB_UPPER_IMM           3'b010
`define WB_TARGET_ADDER        3'b011
`define WB_CSR                 3'b100
`define WB_PC_PLUS_4           3'b101

// Immediate format selection
`define I_TYPE_IMMEDIATE    3'b001
`define S_TYPE_IMMEDIATE    3'b010
`define B_TYPE_IMMEDIATE    3'b011
`define U_TYPE_IMMEDIATE    3'b100
`define J_TYPE_IMMEDIATE    3'b101
`define CSR_TYPE_IMMEDIATE  3'b110

// Program Counter source selection
`define PC_BOOT             2'b00
`define PC_EPC              2'b01
`define PC_TRAP             2'b10
`define PC_NEXT             2'b11

// Load size encoding
`define LOAD_SIZE_BYTE      2'b00
`define LOAD_SIZE_HALF      2'b01
`define LOAD_SIZE_WORD      2'b10

// CSR File operation
`define CSR_RWX             2'b01
`define CSR_RSX             2'b10
`define CSR_RCX             2'b11

module riscv_steel_core (

  // Basic system signals
  input  wire           clock,
  input  wire           reset,
  input  wire   [31:0]  boot_address,

  // Instruction fetch interface
  output wire   [31:0]  instruction_address,
  input  wire   [31:0]  instruction_in,
    
  // Data fetch/write interface
  output wire   [31:0]  data_rw_address,
  output wire   [31:0]  data_out,
  output wire           data_write_request,
  output wire   [3:0 ]  data_write_mask,
  input  wire   [31:0]  data_in,
  
  // Interrupt signals (hardwire to zero if unused)
  input  wire           interrupt_request_external,
  input  wire           interrupt_request_timer,
  input  wire           interrupt_request_software,

  // Real Time Counter (hardwire to zero if unused)
  input  wire   [63:0]  real_time

  );
    
  // ----------------------------------------------------------------------------------------------
  // Declaration of buses, signals and registers
  // ----------------------------------------------------------------------------------------------
  
  reg   [31:0]  program_counter;
  reg   [31:0]  next_program_counter;
  reg   [31:0]  writeback_multiplexer_output;
  reg   [4:0 ]  instruction_rd_address_stage3;  
  reg   [11:0]  instruction_csr_address_stage3;  
  reg   [31:0]  rs1_data_stage3;  
  reg   [31:0]  rs2_data_stage3;
  reg   [31:0]  program_counter_stage3;
  reg   [31:0]  program_counter_plus_4_stage3;    
  reg   [31:0]  target_address_adder_stage3;  
  reg   [3:0 ]  alu_operation_code_stage3;
  reg   [1:0 ]  load_size_stage3;
  reg   [2:0 ]  writeback_mux_selector_stage3;  
  reg   [2:0 ]  csr_operation_stage3;  
  reg   [31:0]  immediate_stage3;
  reg           load_unsigned_stage3;  
  reg           alu_2nd_operand_source_stage3;
  reg           csr_file_write_enable_stage3;
  reg           integer_file_write_enable_stage3;  
  
  wire  [1:0 ]  program_counter_source;
  wire  [31:0]  exception_program_counter;
  wire  [31:0]  load_data;
  wire  [31:0]  alu_output;
  wire  [31:0]  trap_address;
  wire  [31:0]  next_address;
  wire  [31:0]  branch_target_address;
  wire  [31:0]  program_counter_plus_4;
  wire  [31:0]  instruction;
  wire  [6:0 ]  instruction_opcode;
  wire  [6:0 ]  instruction_funct7;
  wire  [2:0 ]  instruction_funct3;
  wire  [4:0 ]  instruction_rs1_address;
  wire  [4:0 ]  instruction_rs2_address;
  wire  [4:0 ]  instruction_rd_address;
  wire  [11:0]  instruction_csr_address;
  wire  [31:0]  target_address_adder;
  wire  [31:0]  immediate;
  wire  [31:0]  rs1_data;
  wire  [31:0]  rs2_data;
  wire  [31:0]  csr_data_out;
  wire  [2:0 ]  writeback_mux_selector;
  wire  [2:0 ]  immediate_type;
  wire  [2:0 ]  csr_operation;
  wire  [3:0 ]  alu_operation_code;
  wire  [1:0 ]  load_size;
  wire          load_unsigned;
  wire          alu_2nd_operand_source;
  wire          csr_file_write_enable;
  wire          integer_file_write_enable;
  wire          target_address_source;
  wire          take_branch;
  wire          take_trap;
  wire          flush_pipeline;
  wire          ecall;
  wire          ebreak;
  wire          mret;
  wire          store;
  wire          load;
  wire          misaligned_load;
  wire          misaligned_store;
  wire          illegal_instruction;    
       
  // ----------------------------------------------------------------------------------------------
  // PIPELINE STAGE 1
  // ----------------------------------------------------------------------------------------------
  
  assign instruction_address =
    reset ?
    boot_address :
    next_program_counter;   
    
  always @* begin : next_program_counter_mux
    case (program_counter_source)
      `PC_BOOT: next_program_counter = boot_address;
      `PC_EPC:  next_program_counter = exception_program_counter;
      `PC_TRAP: next_program_counter = trap_address;
      `PC_NEXT: next_program_counter = next_address;
    endcase
  end
    
  assign program_counter_plus_4 =
    program_counter + 32'h00000004;
  
  assign branch_target_address =
    {target_address_adder[31:1], 1'b0};

  assign next_address =
   take_branch ?
   branch_target_address :
   program_counter_plus_4;
    
  always @(posedge clock) begin : program_counter_reg_implementation
    if(reset)
      program_counter <= boot_address;
    else
      program_counter <= next_program_counter;
  end
    
  // ----------------------------------------------------------------------------------------------
  // PIPELINE STAGE 2
  // ----------------------------------------------------------------------------------------------
    
  assign instruction =
    flush_pipeline == 1'b1 ?
    32'h00000013 :
    instruction_in;
  
  assign instruction_opcode       = instruction[6:0  ];
  assign instruction_funct3       = instruction[14:12];
  assign instruction_funct7       = instruction[31:25];
  assign instruction_rs1_address  = instruction[19:15];
  assign instruction_rs2_address  = instruction[24:20];
  assign instruction_rd_address   = instruction[11:7 ];
  assign instruction_csr_address  = instruction[31:20]; 

  assign target_address_adder =
    target_address_source == 1'b1 ?
    rs1_data + immediate :
    program_counter + immediate;
  
  assign misaligned_word =
    instruction_funct3[1:0] == 2'b10 &
    (target_address_adder[1] | target_address_adder[0]);

  assign misaligned_half =
    instruction_funct3[1:0] == 2'b01 &
    target_address_adder[0];
    
  assign misaligned = misaligned_word | misaligned_half;
  assign misaligned_store = store & misaligned;
  assign misaligned_load  = load  & misaligned;

  data_fetch_store_unit data_fetch_store_unit_instance (

    .instruction_funct3 (instruction_funct3   ),
    .load_store_address (target_address_adder ), 
    .rs2_data           (rs2_data             ),
    .store              (store                ),
    .misaligned_store   (misaligned_store     ),
    .take_trap          (take_trap            ),
    .write_request      (data_write_request   ),
    .rw_address         (data_rw_address      ),
    .store_data         (data_out             ),
    .write_mask         (data_write_mask      )
  
  );
    
  decoder decoder_instance (
  
    .instruction_opcode         (instruction_opcode         ),
    .instruction_funct7         (instruction_funct7         ),
    .instruction_funct3         (instruction_funct3         ),
    .instruction_rs1_address    (instruction_rs1_address    ),
    .instruction_rs2_address    (instruction_rs2_address    ),
    .instruction_rd_address     (instruction_rd_address     ),
    .alu_operation_code         (alu_operation_code         ),
    .load_size                  (load_size                  ),
    .load_unsigned              (load_unsigned              ),
    .alu_2nd_operand_source     (alu_2nd_operand_source     ),
    .target_address_source      (target_address_source      ),
    .csr_file_write_enable      (csr_file_write_enable      ),
    .integer_file_write_enable  (integer_file_write_enable  ),
    .writeback_mux_selector     (writeback_mux_selector     ),
    .immediate_type             (immediate_type             ),
    .csr_operation              (csr_operation              ),
    .illegal_instruction        (illegal_instruction        ),
    .ecall                      (ecall                      ),
    .ebreak                     (ebreak                     ),
    .mret                       (mret                       ),
    .load                       (load                       ),
    .store                      (store                      )
      
  );
    
  imm_generator imm_generator_instance (
      
    .instruction_31_downto_7        (instruction[31:7]  ),
    .immediate_type                 (immediate_type     ),
    .immediate_data                 (immediate          )

  );
    
  branch_decision branch_decision_instance (

    .instruction_opcode             (instruction_opcode ),
    .instruction_funct3             (instruction_funct3 ),
    .rs1_data                       (rs1_data           ),
    .rs2_data                       (rs2_data           ),
    .take_branch                    (take_branch        )

  );
    
  integer_file integer_file_instance (
    
    .clock         (clock                                 ),
    .rs1_addr      (instruction_rs1_address               ),
    .rs2_addr      (instruction_rs2_address               ),    
    .rd_addr       (instruction_rd_address_stage3         ),
    .write_enable  (flush_pipeline ?
                    1'b0 :
                    integer_file_write_enable_stage3      ),
    .rd_data       (writeback_multiplexer_output          ),
    .rs1_data      (rs1_data                              ),
    .rs2_data      (rs2_data                              )

  );

  csr_file csr_file_instance (

    .clock                          (clock                          ),
    .reset                          (reset                          ),    
    .write_enable                   (flush_pipeline ?
                                     1'b0 :
                                     csr_file_write_enable_stage3   ),
    .csr_address                    (instruction_csr_address_stage3 ),
    .csr_operation                  (csr_operation_stage3           ),
    .immediate_data_4_to_0          (immediate_stage3[4:0]          ),
    .csr_data_in                    (rs1_data_stage3                ),
    .csr_data_out                   (csr_data_out                   ),    
    .program_counter_stage3         (program_counter_stage3         ),
    .target_address_adder_stage3    (target_address_adder_stage3    ),    
    .interrupt_request_external     (interrupt_request_external     ),
    .interrupt_request_timer        (interrupt_request_timer        ),
    .interrupt_request_software     (interrupt_request_software     ),    
    .misaligned_load                (misaligned_load                ),
    .misaligned_store               (misaligned_store               ),
    .misaligned_instruction_address (take_branch & next_address[1]  ),
    .illegal_instruction            (illegal_instruction            ),
    .ecall                          (ecall                          ),
    .ebreak                         (ebreak                         ),
    .mret                           (mret                           ),    
    .real_time                      (real_time                      ),    
    .exception_program_counter      (exception_program_counter      ),
    .program_counter_source         (program_counter_source         ),
    .flush_pipeline                 (flush_pipeline                 ),
    .trap_address                   (trap_address                   ),
    .take_trap                      (take_trap                      )

  );
       
  always @(posedge clock) begin
    if(reset) begin
      instruction_rd_address_stage3     <= 5'b00000;
      instruction_csr_address_stage3    <= 12'b000000000000;
      rs1_data_stage3                   <= 32'h00000000;
      rs2_data_stage3                   <= 32'h00000000;
      program_counter_stage3            <= boot_address;
      program_counter_plus_4_stage3     <= 32'h00000000;
      target_address_adder_stage3       <= 32'h00000000;
      alu_operation_code_stage3         <= 4'b0000;
      load_size_stage3                  <= 2'b00;
      load_unsigned_stage3              <= 1'b0;
      alu_2nd_operand_source_stage3     <= 1'b0;
      csr_file_write_enable_stage3      <= 1'b0;
      integer_file_write_enable_stage3  <= 1'b0;
      writeback_mux_selector_stage3     <= `WB_ALU;
      csr_operation_stage3              <= 3'b000;
      immediate_stage3                  <= 32'h00000000;
    end
    else begin
      instruction_rd_address_stage3     <= instruction_rd_address;
      instruction_csr_address_stage3    <= instruction_csr_address;
      rs1_data_stage3                   <= rs1_data;
      rs2_data_stage3                   <= rs2_data;
      program_counter_stage3            <= program_counter;
      program_counter_plus_4_stage3     <= program_counter_plus_4;
      target_address_adder_stage3       <= target_address_adder;
      alu_operation_code_stage3         <= alu_operation_code;
      load_size_stage3                  <= load_size;
      load_unsigned_stage3              <= load_unsigned;
      alu_2nd_operand_source_stage3     <= alu_2nd_operand_source;
      csr_file_write_enable_stage3      <= csr_file_write_enable;
      integer_file_write_enable_stage3  <= integer_file_write_enable;
      writeback_mux_selector_stage3     <= writeback_mux_selector;
      csr_operation_stage3              <= csr_operation;
      immediate_stage3                  <= immediate;
    end
  end    
    
  // ----------------------------------------------------------------------------------------------
  // PIPELINE STAGE 2
  // ----------------------------------------------------------------------------------------------
  
  always @* begin
    case (writeback_mux_selector_stage3)
      `WB_ALU:          writeback_multiplexer_output = alu_output;
      `WB_LOAD_UNIT:    writeback_multiplexer_output = load_data;
      `WB_UPPER_IMM:    writeback_multiplexer_output = immediate_stage3;
      `WB_TARGET_ADDER: writeback_multiplexer_output = target_address_adder_stage3;
      `WB_CSR:          writeback_multiplexer_output = csr_data_out;
      `WB_PC_PLUS_4:    writeback_multiplexer_output = program_counter_plus_4_stage3;
      default:          writeback_multiplexer_output = alu_output;
    endcase
  end

  load_unit load_unit_instance (
  
    .load_size                  (load_size_stage3                 ),
    .load_unsigned              (load_unsigned_stage3             ),
    .data_read                  (data_in                          ),
    .load_store_address_1_to_0  (target_address_adder_stage3[1:0] ),
    .load_data                  (load_data                        )
  
  );
    
  rv32i_alu rv32i_alu_instance (

    .first_operand              (rs1_data_stage3                  ),
    .second_operand             (alu_2nd_operand_source_stage3 ?
                                 rs2_data_stage3 :
                                 immediate_stage3                 ),
    .operation_code             (alu_operation_code_stage3        ),    
    .operation_result           (alu_output                       )

  );
    
endmodule

// ------------------------------------------------------------------------------------------------
//
// RISC-V 32-bit Arithmetic and Logic Unit
// 
// This unit applies one of the following arithmetic/logic operations to
// first_operand and second_operand:
//
//  Operation name                operation_code        RISC-V instruction 
//  -----------------------------------------------------------------------------------------------
//  Addition                      0000                  ADD
//  Subtraction                   1000                  SUB
//  Set on less than              0010                  SLT
//  Set on less than unsigned     0011                  SLTU
//  Logical AND                   0111                  AND
//  Logical OR                    0110                  OR
//  Logical XOR                   0100                  XOR
//  Shift left (logical)          0001                  SLL
//  Shift right (logical)         0101                  SRL
//  Shift right (arithmetic)      1101                  SRA
//  -----------------------------------------------------------------------------------------------
//
// All operations are performed simultaneously. The bits of operation_code are
// used to select the desired result.
//
// ------------------------------------------------------------------------------------------------
module rv32i_alu (

  input  wire   [31:0]  first_operand,
  input  wire   [31:0]  second_operand,
  input  wire   [3:0 ]  operation_code,
  output reg    [31:0]  operation_result

  );
  
  wire signed   [31:0]  signed_op1;
  wire signed   [31:0]  adder_second_operand_mux;
  wire          [31:0]  minus_second_operand;
  wire          [31:0]  alu_sra_result;
  wire          [31:0]  alu_srl_result;
  wire          [31:0]  shift_right_mux;
  wire                  alu_slt_result;
  wire                  alu_sltu_result;
  
  assign signed_op1 = 
    first_operand;

  assign minus_second_operand = 
    - second_operand;

  assign adder_second_operand_mux = 
    operation_code[3] == 1'b1 ?
    minus_second_operand : 
    second_operand;

  assign alu_sra_result = 
    signed_op1 >>> second_operand[4:0];

  assign alu_srl_result = 
    first_operand >> second_operand[4:0];

  assign shift_right_mux = 
    operation_code[3] == 1'b1 ?
    alu_sra_result : 
    alu_srl_result;

  assign alu_sltu_result = 
    first_operand < second_operand;

  assign alu_slt_result =
    first_operand[31] ^ second_operand[31] ?
    first_operand[31] :
    alu_sltu_result;

  always @* begin : operation_result_mux
    case (operation_code[2:0])
      `FUNCT3_ADD:
        operation_result =
          first_operand + adder_second_operand_mux;
      `FUNCT3_SRL:
        operation_result =
          shift_right_mux;
      `FUNCT3_OR: 
        operation_result = 
          first_operand | second_operand;
      `FUNCT3_AND: 
        operation_result = 
          first_operand & second_operand;            
      `FUNCT3_XOR: 
        operation_result = 
          first_operand ^ second_operand;
      `FUNCT3_SLT: 
        operation_result = 
          {31'b0, alu_slt_result};
      `FUNCT3_SLTU: 
        operation_result = 
          {31'b0, alu_sltu_result};
      `FUNCT3_SLL: 
        operation_result = 
          first_operand << second_operand[4:0];
    endcase
  end
    
endmodule

// ------------------------------------------------------------------------------------------------
//
// Branch Decision
// 
// This unit generates the 'take_branch' signal, used by the program counter 
// (PC) circuitry to decide the next value of the PC register.
//
// - instruction_opcode bus must hold the seven bits of the instruction opcode
// - instruction_funct3 bus must hold the three bits of the funct3 field of the 
//   instruction
// - rs1_data (register source 1 data) bus must hold the data stored in the 
//   Integer File register indicated in the RS1 field of the instruction
// - rs2_data (register source 2 data) bus must hold the data stored in the 
//   Integer File register indicated in the RS2 field of the instruction
// 
// Whenever a branch must be taken, signal take_branch will be set to logic 1.
//
// ------------------------------------------------------------------------------------------------
module branch_decision (

  input wire    [6:0]   instruction_opcode,
  input wire    [2:0]   instruction_funct3,
  input wire    [31:0]  rs1_data,
  input wire    [31:0]  rs2_data,
  output wire           take_branch

  );
    
  wire is_branch;
  wire is_jal;
  wire is_jalr;
  wire is_jump;
  wire is_equal;
  wire is_not_equal;
  wire is_less_than;
  wire is_greater_or_equal_than;
  wire is_less_than_unsigned;
  wire is_greater_or_equal_than_unsigned;
  reg  branch_condition_satisfied;

  assign is_jal =
    instruction_opcode == `OPCODE_JAL;

  assign is_jalr =
    instruction_opcode == `OPCODE_JALR;

  assign is_branch =
    instruction_opcode == `OPCODE_BRANCH;

  assign is_jump =
    is_jal | is_jalr;
    
  assign is_equal =
    rs1_data == rs2_data;

  assign is_not_equal =
    !is_equal;

  assign is_less_than =
    rs1_data[31] ^ rs2_data[31] ?
    rs1_data[31] :
    is_less_than_unsigned;

  assign is_greater_or_equal_than =
    !is_less_than;

  assign is_less_than_unsigned =
    rs1_data < rs2_data;

  assign is_greater_or_equal_than_unsigned =
    !is_less_than_unsigned;

  // Determines if the branch condition is satisfied based
  // on the type of branch condition
  always @* begin : branch_condition_satisfied_mux
    case (instruction_funct3)
      `FUNCT3_BEQ:
        branch_condition_satisfied =
          is_equal;
      `FUNCT3_BNE:
        branch_condition_satisfied =
          is_not_equal;
      `FUNCT3_BLT:
        branch_condition_satisfied =
          is_less_than;
      `FUNCT3_BGE:
        branch_condition_satisfied =
          is_greater_or_equal_than;
      `FUNCT3_BLTU:
        branch_condition_satisfied =
          is_less_than_unsigned;
      `FUNCT3_BGEU:
        branch_condition_satisfied =
          is_greater_or_equal_than_unsigned;
      default:
        branch_condition_satisfied =
          1'b0;
      endcase
  end
  
  // If the instruction is type 'jump', the branch is always taken
  // If type 'branch', only if the branch condition is satisfied
  assign take_branch =
    (is_jump == 1'b1) ?
    1'b1 :
      (is_branch == 1'b1) ?
      branch_condition_satisfied :
      1'b0;
    
endmodule

// ------------------------------------------------------------------------------------------------
//
// Immediate Generator
// 
// This unit reorganizes the instruction bits to form the immediate data used 
// with the operation.
//
// - instruction_31_downto_7 is a bus with the upper bits of the instruction
// - immediate_type is a 3-bit signal generated by the instruction decoder, used
//   as a selector for the type of immediate.
// - immediate_data is the output, a 32-bit signal with the generated immediate
//
// ------------------------------------------------------------------------------------------------
module imm_generator (
    
  input wire    [31:7]  instruction_31_downto_7,
  input wire    [2:0]   immediate_type,
  output reg    [31:0]  immediate_data

  );
  
  wire [19:0] sign_extension;
  wire [31:0] i_type_immediate;
  wire [31:0] s_type_immediate;
  wire [31:0] b_type_immediate;
  wire [31:0] u_type_immediate;
  wire [31:0] j_type_immediate;
  wire [31:0] csr_type_immediate;
  
  assign sign_extension = {
    20 {instruction_31_downto_7[31]}
  };

  assign i_type_immediate = {
    sign_extension,
    instruction_31_downto_7[31:20]
  };

  assign s_type_immediate = {
    sign_extension,
    instruction_31_downto_7[31:25],
    instruction_31_downto_7[11:7 ]
  };

  assign b_type_immediate = {
    sign_extension,
    instruction_31_downto_7[7],
    instruction_31_downto_7[30:25],
    instruction_31_downto_7[11:8],
    1'b0
  };

  assign u_type_immediate = {
    instruction_31_downto_7[31:12],
    12'h000
  };

  assign j_type_immediate = {
    sign_extension[11:0],
    instruction_31_downto_7[19:12],
    instruction_31_downto_7[20],
    instruction_31_downto_7[30:21],
    1'b0
  };

  assign csr_type_immediate = {
    27'b0,
    instruction_31_downto_7[19:15]
  };
  
  always @(*) begin : immediate_data_mux
    case (immediate_type) 
      `I_TYPE_IMMEDIATE:
        immediate_data = i_type_immediate;
      `S_TYPE_IMMEDIATE:
        immediate_data = s_type_immediate;
      `B_TYPE_IMMEDIATE:
        immediate_data = b_type_immediate;
      `U_TYPE_IMMEDIATE:
        immediate_data = u_type_immediate;
      `J_TYPE_IMMEDIATE:
        immediate_data = j_type_immediate;
      `CSR_TYPE_IMMEDIATE:
        immediate_data = csr_type_immediate;
      default:
        immediate_data = i_type_immediate;
    endcase
  end
    
endmodule

// ------------------------------------------------------------------------------------------------
//
// Data Fetch/Store Unit
// 
// This unit generates the signals interfacing with the data memory:
//   - rw_address (address to fetch/store data)
//   - store_data (data to be written to memory)
//   - write_mask (write byte-enable mask) 
//   - write_request (0 = fetch data / 1 = write)
//
// When input 'store' is logic 0 the core is reading from memory. 
// If it is logic 1 the core is writing to memory, and the output signals are
// set so that bytes, half words and words are stored in the proper memory
// position.
//
// Steel does not generate unaligned addresses. It means the two last bits of
// rw_address bus are always 2'b00.
//
// ------------------------------------------------------------------------------------------------
module data_fetch_store_unit (

  input wire    [2:0 ]  instruction_funct3,
  input wire    [31:0]  load_store_address, 
  input wire    [31:0]  rs2_data,
  input wire            store,
  input wire            misaligned_store,
  input wire            take_trap,
  output wire           write_request,
  output wire   [31:0]  rw_address,
  output reg    [31:0]  store_data,
  output reg    [3:0 ]  write_mask
    
  );   
  
  reg [3:0] write_mask_for_half;
  reg [3:0] write_mask_for_byte;
  reg [31:0] half_data;
  reg [31:0] byte_data;
  
  assign write_request =
    store & ~misaligned_store & ~take_trap;
  
  assign rw_address = {load_store_address[31:2], 2'b00};
  
  always @* begin
    case(instruction_funct3)
      `FUNCT3_SB: begin
        write_mask = write_mask_for_byte;
        store_data = byte_data;
      end
      `FUNCT3_SH: begin
        write_mask = write_mask_for_half;
        store_data = half_data;
      end
      `FUNCT3_SW: begin
        write_mask = {4{write_request}};
        store_data = rs2_data;
      end
      default: begin
        write_mask = {4{write_request}};
        store_data = rs2_data;
      end 
    endcase
  end
    
  always @* begin
    case(load_store_address[1:0])
      2'b00: begin 
        byte_data = {24'b0, rs2_data[7:0]};
        write_mask_for_byte = {3'b0, write_request};
      end
      2'b01: begin
        byte_data = {16'b0, rs2_data[7:0], 8'b0};
        write_mask_for_byte = {2'b0, write_request, 1'b0};
      end
      2'b10: begin
        byte_data = {8'b0, rs2_data[7:0], 16'b0};
        write_mask_for_byte = {1'b0, write_request, 2'b0};
      end
      2'b11: begin
        byte_data = {rs2_data[7:0], 24'b0};
        write_mask_for_byte = {write_request, 3'b0};
      end
    endcase    
  end
    
  always @* begin
    case(load_store_address[1])
      1'b0: begin
        half_data = {16'b0, rs2_data[15:0]};
        write_mask_for_half = {2'b0, {2{write_request}}};
      end
      1'b1: begin
        half_data = {rs2_data[15:0], 16'b0};
        write_mask_for_half = {{2{write_request}}, 2'b0};
      end
    endcase
  end
                                                                
endmodule

// ------------------------------------------------------------------------------------------------
//
// Integer File
// 
// Provide 31 32-bit integer registers and an addressable hardwired zero
// required for a RV32I implementation. The forwarding tecnique is used. Most 
// FPGA vendor tools will infer a Block RAM for this module.
//
// Buses 'rs1_addr', 'rs2_addr' and 'rd_addr' get their values from fields RS1,
// RS2 and RD of RISC-V instructions.
//
// ------------------------------------------------------------------------------------------------
module integer_file (
  
  input wire            clock,
  
  // Signals used in pipeline stage 2
  input wire    [4:0]   rs1_addr,
  input wire    [4:0]   rs2_addr,    
  output wire   [31:0]  rs1_data,
  output wire   [31:0]  rs2_data,
  
  // Signals used in pipeline stage 3
  input wire    [4:0]   rd_addr,
  input wire            write_enable,
  input wire    [31:0]  rd_data

  );
    
  wire [31:0] rs1_mux;
  wire [31:0] rs2_mux;  
  reg [31:0] Q [31:1];
  
  integer i;
  
  initial
    for (i=1; i <= 31; i=i+1)
      Q[i] <= 32'h00000000;

  always @(posedge clock)
    if (write_enable)
      Q[rd_addr] <= rd_data;

  assign rs1_mux =
    rs1_addr == rd_addr && write_enable == 1'b1 ?
    rd_data :
    Q[rs1_addr];

  assign rs2_mux =
    rs2_addr == rd_addr && write_enable == 1'b1 ?
    rd_data :
    Q[rs2_addr];

  assign rs1_data =
    rs1_addr == 5'b00000 ?
    32'h00000000 :
    rs1_mux;
  
  assign rs2_data =
    rs2_addr == 5'b00000 ?
    32'h00000000 :
    rs2_mux;
    
endmodule

// ------------------------------------------------------------------------------------------------
//
// Decoder Unit
// 
// This unit generates most of the signals that control the operation of other
// architectural units. It also signals an illegal instruction.
//
// ------------------------------------------------------------------------------------------------
module decoder (

  input wire    [6:0] instruction_opcode,
  input wire    [6:0] instruction_funct7,
  input wire    [2:0] instruction_funct3,
  input wire    [4:0] instruction_rs1_address,
  input wire    [4:0] instruction_rs2_address,
  input wire    [4:0] instruction_rd_address,
  
  output wire   [3:0] alu_operation_code,
  output wire   [1:0] load_size,
  output wire         load_unsigned,
  output wire         alu_2nd_operand_source,
  output wire         target_address_source,
  output wire         integer_file_write_enable,
  output wire         csr_file_write_enable,
  output reg    [2:0] writeback_mux_selector,
  output reg    [2:0] immediate_type,
  output wire   [2:0] csr_operation,
  output wire         illegal_instruction,
  output wire         ecall,
  output wire         ebreak,
  output wire         mret,
  output wire         load,
  output wire         store

  );
    
  // ----------------------------------------------------------------------------------------------
  // Instruction type detection
  // ----------------------------------------------------------------------------------------------

  assign branch_type    = instruction_opcode == `OPCODE_BRANCH;
  assign jal_type       = instruction_opcode == `OPCODE_JAL;
  assign jalr_type      = instruction_opcode == `OPCODE_JALR;
  assign auipc_type     = instruction_opcode == `OPCODE_AUIPC;
  assign lui_type       = instruction_opcode == `OPCODE_LUI;
  assign load_type      = instruction_opcode == `OPCODE_LOAD;
  assign store_type     = instruction_opcode == `OPCODE_STORE;
  assign system_type    = instruction_opcode == `OPCODE_SYSTEM;
  assign op_type        = instruction_opcode == `OPCODE_OP;
  assign op_imm_type    = instruction_opcode == `OPCODE_OP_IMM;
  assign misc_mem_type  = instruction_opcode == `OPCODE_MISC_MEM;
  
  // ----------------------------------------------------------------------------------------------
  // Detection of specific instructions
  // ----------------------------------------------------------------------------------------------

  assign addi   = op_imm_type & instruction_funct3 == `FUNCT3_ADDI;
  assign slti   = op_imm_type & instruction_funct3 == `FUNCT3_SLTI;
  assign sltiu  = op_imm_type & instruction_funct3 == `FUNCT3_SLTIU;
  assign andi   = op_imm_type & instruction_funct3 == `FUNCT3_ANDI;
  assign ori    = op_imm_type & instruction_funct3 == `FUNCT3_ORI;
  assign xori   = op_imm_type & instruction_funct3 == `FUNCT3_XORI;  
  assign slli   = op_imm_type & instruction_funct3 == `FUNCT3_SLLI
                              & instruction_funct7 == `FUNCT7_SLLI;  
  assign srli   = op_imm_type & instruction_funct3 == `FUNCT3_SRLI
                              & instruction_funct7 == `FUNCT7_SRLI;
  assign srai   = op_imm_type & instruction_funct3 == `FUNCT3_SRAI
                              & instruction_funct7 == `FUNCT7_SRAI;
  assign add    = op_type     & instruction_funct3 == `FUNCT3_ADD
                              & instruction_funct7 == `FUNCT7_ADD;
  assign sub    = op_type     & instruction_funct3 == `FUNCT3_SUB
                              & instruction_funct7 == `FUNCT7_SUB;
  assign slt    = op_type     & instruction_funct3 == `FUNCT3_SLT
                              & instruction_funct7 == `FUNCT7_SLT;
  assign sltu   = op_type     & instruction_funct3 == `FUNCT3_SLTU
                              & instruction_funct7 == `FUNCT7_SLTU;
  assign is_and = op_type     & instruction_funct3 == `FUNCT3_AND
                              & instruction_funct7 == `FUNCT7_AND;
  assign is_or  = op_type     & instruction_funct3 == `FUNCT3_OR
                              & instruction_funct7 == `FUNCT7_OR;
  assign is_xor = op_type     & instruction_funct3 == `FUNCT3_XOR
                              & instruction_funct7 == `FUNCT7_XOR;  
  assign sll    = op_type     & instruction_funct3 == `FUNCT3_SLL
                              & instruction_funct7 == `FUNCT7_SLL;  
  assign srl    = op_type     & instruction_funct3 == `FUNCT3_SRL
                              & instruction_funct7 == `FUNCT7_SRL;
  assign sra    = op_type     & instruction_funct3 == `FUNCT3_SRA
                              & instruction_funct7 == `FUNCT7_SRA;  
  assign csrxxx = system_type & instruction_funct3 != 3'b000
                              & instruction_funct3 != 3'b100;
  assign ecall  = system_type & instruction_funct3 == `FUNCT3_ECALL
                              & instruction_funct7 == `FUNCT7_ECALL
                              & instruction_rs1_address == `RS1_ECALL
                              & instruction_rs2_address == `RS2_ECALL
                              & instruction_rd_address  == `RD_ECALL;
  assign ebreak = system_type & instruction_funct3 == `FUNCT3_EBREAK
                              & instruction_funct7 == `FUNCT7_EBREAK
                              & instruction_rs1_address == `RS1_EBREAK
                              & instruction_rs2_address == `RS2_EBREAK
                              & instruction_rd_address  == `RD_EBREAK;
  assign mret   = system_type & instruction_funct3 == `FUNCT3_MRET
                              & instruction_funct7 == `FUNCT7_MRET
                              & instruction_rs1_address == `RS1_MRET
                              & instruction_rs2_address == `RS2_MRET
                              & instruction_rd_address  == `RD_MRET;

  // ----------------------------------------------------------------------------------------------
  // Illegal instruction detection
  // ----------------------------------------------------------------------------------------------

  assign illegal_store = 
    store_type &
    (instruction_funct3[2] == 1'b1 ||
    instruction_funct3[1:0] == 2'b11);
  assign illegal_load =
    load_type &
    (instruction_funct3 == 3'b011 ||
     instruction_funct3 == 3'b110 ||
     instruction_funct3 == 3'b111);
  assign illegal_jalr =
    jalr_type &
    instruction_funct3 != 3'b000;
  assign illegal_branch =
    branch_type &
    (instruction_funct3 == 3'b010 ||
    instruction_funct3 == 3'b011);
  assign illegal_op =
    op_type &
    ~(add | sub | slt | sltu | is_and | is_or | is_xor | sll | srl | sra);
  assign illegal_op_imm =
    op_imm_type &
    ~(addi | slti | sltiu | andi | ori | xori | slli | srli | srai);
  assign illegal_system =
    system_type &
    ~(csrxxx | ecall | ebreak | mret);
  assign unknown_type =
    ~(branch_type | jal_type | jalr_type | auipc_type | lui_type | load_type | store_type 
    | system_type | op_type | op_imm_type | misc_mem_type);
  assign illegal_instruction =
    unknown_type | illegal_store | illegal_load | illegal_jalr | illegal_branch | illegal_op 
    | illegal_op_imm | illegal_system;

  // ----------------------------------------------------------------------------------------------
  // Control signals generation
  // ----------------------------------------------------------------------------------------------

  assign alu_operation_code[2:0] =
    instruction_funct3;
  assign alu_operation_code[3] =
    instruction_funct7[5] &
    ~(addi | slti | sltiu | andi | ori | xori);
  assign load =
    load_type &
    ~illegal_load;
  assign store =
    store_type &
    ~illegal_store;
  assign load_size =
    instruction_funct3[1:0];
  assign load_unsigned =
    instruction_funct3[2];
  assign alu_2nd_operand_source =
    instruction_opcode[5];
  assign target_address_source =
    load_type | store_type | jalr_type;
  assign integer_file_write_enable =
    lui_type | auipc_type | jalr_type | jal_type | op_type | op_imm_type | load_type | csrxxx;
  assign csr_file_write_enable =
    csrxxx;
  
  always @* begin : writeback_selector_decoding
    if (op_type == 1'b1 || op_imm_type == 1'b1)
      writeback_mux_selector = `WB_ALU;
    else if (load_type == 1'b1)
      writeback_mux_selector = `WB_LOAD_UNIT;
    else if (jal_type == 1'b1 || jalr_type == 1'b1)
      writeback_mux_selector = `WB_PC_PLUS_4;
    else if (lui_type == 1'b1)
      writeback_mux_selector = `WB_UPPER_IMM;
    else if (auipc_type == 1'b1)
      writeback_mux_selector = `WB_TARGET_ADDER;
    else if (csrxxx == 1'b1)
      writeback_mux_selector = `WB_CSR;
    else
      writeback_mux_selector = `WB_ALU;
  end

  always @* begin : immediate_type_decoding
    if (op_imm_type == 1'b1 || load_type == 1'b1 || jalr_type == 1'b1)
      immediate_type = `I_TYPE_IMMEDIATE;
    else if (store_type == 1'b1)
      immediate_type = `S_TYPE_IMMEDIATE;
    else if (branch_type == 1'b1)
      immediate_type = `B_TYPE_IMMEDIATE;
    else if (jal_type == 1'b1)
      immediate_type = `J_TYPE_IMMEDIATE;
    else if (lui_type == 1'b1 || auipc_type == 1'b1)
      immediate_type = `U_TYPE_IMMEDIATE;
    else if (csrxxx == 1'b1)
      immediate_type = `CSR_TYPE_IMMEDIATE;
    else
      immediate_type = `I_TYPE_IMMEDIATE;
  end

  assign csr_operation = instruction_funct3;
        
endmodule

// ------------------------------------------------------------------------------------------------
//
// Load Unit
// 
// This unit select the appropriate bits of the data fetched from memory (which
// is always 32-bit wide) for half-word and byte loads, and zero-/sign-extend
// it to a 32-bit value. For LW instruction it simply puts the data read from
// memory into load_data.
//
// ------------------------------------------------------------------------------------------------
module load_unit (

  input wire    [1:0 ]  load_size,
  input wire            load_unsigned,
  input wire    [31:0]  data_read,
  input wire    [1:0 ]  load_store_address_1_to_0,
  output reg    [31:0]  load_data
    
  );
    
  reg   [7:0]   byte_data;
  reg   [15:0]  half_data;    
  wire  [23:0]  byte_data_upper_bits;
  wire  [15:0]  half_data_upper_bits;
  
  always @* begin : load_size_mux
    case (load_size)
      `LOAD_SIZE_BYTE:
        load_data = {byte_data_upper_bits, byte_data};
      `LOAD_SIZE_HALF:
        load_data = {half_data_upper_bits, half_data};
      `LOAD_SIZE_WORD:
        load_data = data_read;
      default:
        load_data = data_read;
    endcase
  end
    
  always @* begin : byte_data_mux
    case (load_store_address_1_to_0)    
      2'b00:
        byte_data = data_read[7:0];
      2'b01:
        byte_data = data_read[15:8];
      2'b10:
        byte_data = data_read[23:16];
      2'b11:
        byte_data = data_read[31:24];
    endcase
  end
    
  always @* begin : half_data_mux
    case (load_store_address_1_to_0[1])
      1'b0:
        half_data = data_read[15:0];
      1'b1:
        half_data = data_read[31:16];
    endcase
  end
    
  assign byte_data_upper_bits =
    load_unsigned == 1'b1 ?
    24'b0 :
    {24{byte_data[7]}};
  
  assign half_data_upper_bits =
    load_unsigned == 1'b1 ?
    16'b0 :
    {16{half_data[15]}};
                                                                
endmodule

// ------------------------------------------------------------------------------------------------
//
// Control and Status Register File
// 
// This unit implements the privileged ISA specification from RISC-V. Operation
// in M-mode is supported. H, S and U modes are not implemented.
// Optional registers from M-mode are unimplemented for simplicity.
//
// ------------------------------------------------------------------------------------------------
module csr_file (

  // Basic signals
  input wire            clock,
  input wire            reset,
    
  // CSR registers read/write interface  
  input wire            write_enable,
  input wire    [11:0]  csr_address,
  input wire    [2:0 ]  csr_operation,
  input wire    [4:0 ]  immediate_data_4_to_0,
  input wire    [31:0]  csr_data_in,
  output reg    [31:0]  csr_data_out,
    
  // From pipeline stage 3
  input wire    [31:0]  program_counter_stage3,
  input wire    [31:0]  target_address_adder_stage3,
    
  // // Interface with Interrupt Controller
  input wire            interrupt_request_external,
  input wire            interrupt_request_timer,
  input wire            interrupt_request_software,
    
  // Exception flags
  input wire            misaligned_load,
  input wire            misaligned_store,
  input wire            misaligned_instruction_address,

  // Instruction decoder flags
  input wire            illegal_instruction,
  input wire            ecall,
  input wire            ebreak,
  input wire            mret,
    
  // Real Time counter value
  input wire    [63:0]  real_time,
    
  // Hart state control signals
  output wire   [31:0]  exception_program_counter,
  output reg    [1:0 ]  program_counter_source,
  output wire           flush_pipeline,
  output wire           take_trap,
  output wire   [31:0]  trap_address

  );
    
  reg   [3:0 ]  current_state;
  reg   [3:0 ]  next_state;
  reg   [31:0]  csr_write_data;
  reg   [31:0]  mepc;
  reg   [31:0]  mscratch;
  reg   [31:0]  mtvec;
  reg   [31:0]  mtval;
  reg   [63:0]  mcycle;
  reg   [63:0]  utime;
  reg   [63:0]  minstret;
  reg   [31:0]  mcause;
  reg   [3:0 ]  mcause_cause_code;
  reg           mcause_interrupt_flag;
  reg           mstatus_mie;
  reg           mstatus_mpie;
  reg           mie_meie;
  reg           mie_mtie;
  reg           mie_msie;
  reg           mip_meip;
  reg           mip_mtip;
  reg           mip_msip;
  reg           misaligned_address_exception;
  
  wire  [31:0]  csr_data_mask;
  wire  [31:0]  mstatus;
  wire  [31:0]  mie;
  wire  [31:0]  mip;
  
  parameter STATE_RESET         = 4'b0001; 
  parameter STATE_OPERATING     = 4'b0010;
  parameter STATE_TRAP_TAKEN    = 4'b0100;    
  parameter STATE_TRAP_RETURN   = 4'b1000;

  // ----------------------------------------------------------------------------------------------
  // M-mode Operation Control
  // ----------------------------------------------------------------------------------------------

  assign flush_pipeline =
    current_state != STATE_OPERATING;

  assign interrupt_pending =
    (mie_meie & mip_meip) |
    (mie_mtie & mip_mtip) |
    (mie_msie & mip_msip);
  
  assign exception_pending =
    illegal_instruction |
    misaligned_load |
    misaligned_store |
    misaligned_instruction_address;

  assign take_trap =
    (mstatus_mie & interrupt_pending) |
    exception_pending |
    ecall |
    ebreak;

  always @* begin : m_mode_fsm_next_state_logic
    case (current_state)
      STATE_RESET:
        next_state = STATE_OPERATING;
      STATE_OPERATING: 
        if(take_trap)
          next_state = STATE_TRAP_TAKEN;
        else if(mret)
          next_state = STATE_TRAP_RETURN;
        else
          next_state = STATE_OPERATING;
      STATE_TRAP_TAKEN:
        next_state = STATE_OPERATING;
      STATE_TRAP_RETURN:
        next_state = STATE_OPERATING;
      default:
        next_state = STATE_OPERATING;
    endcase
  end
  
  always @(posedge clock) begin : m_mode_fsm_current_state_register
    if(reset)
      current_state <= STATE_RESET;
    else
      current_state <= next_state;
  end

  always @* begin : program_counter_source_mux
    case (current_state)
      STATE_RESET:
        program_counter_source = `PC_BOOT;
      STATE_OPERATING:
        program_counter_source = `PC_NEXT;
      STATE_TRAP_TAKEN:
        program_counter_source = `PC_TRAP;
      STATE_TRAP_RETURN:
        program_counter_source = `PC_EPC;
      default:
        program_counter_source = `PC_NEXT;
    endcase
  end

  // ----------------------------------------------------------------------------------------------
  // CSR Register File Control
  // ----------------------------------------------------------------------------------------------

  assign csr_data_mask =
    csr_operation[2] == 1'b1 ?
    {27'b0, immediate_data_4_to_0} :
    csr_data_in;

  always @* begin : csr_write_data_mux
    case (csr_operation[1:0])
      `CSR_RWX:
        csr_write_data = csr_data_mask;
      `CSR_RSX:
        csr_write_data = csr_data_out |  csr_data_mask;
      `CSR_RCX:
        csr_write_data = csr_data_out & ~csr_data_mask;
      default:
        csr_write_data = csr_data_out;
    endcase
  end

  always @* begin : csr_data_out_mux
    case (csr_address)
      `MARCHID:       csr_data_out = 32'h00000018; // Steel marchid
      `MIMPID:        csr_data_out = 32'h00000004; // Version 4 
      `CYCLE:         csr_data_out = mcycle    [31:0 ];
      `CYCLEH:        csr_data_out = mcycle    [63:32];
      `TIME:          csr_data_out = utime     [31:0 ];
      `TIMEH:         csr_data_out = utime     [63:32];
      `INSTRET:       csr_data_out = minstret  [31:0 ];
      `INSTRETH:      csr_data_out = minstret  [63:32];
      `MSTATUS:       csr_data_out = mstatus;
      `MSTATUSH:      csr_data_out = 32'h00000000;
      `MISA:          csr_data_out = 32'h40000100; // RV32I base ISA only
      `MIE:           csr_data_out = mie;
      `MTVEC:         csr_data_out = mtvec;
      `MSCRATCH:      csr_data_out = mscratch;
      `MEPC:          csr_data_out = mepc;
      `MCAUSE:        csr_data_out = mcause;
      `MTVAL:         csr_data_out = mtval;
      `MIP:           csr_data_out = mip;
      `MCYCLE:        csr_data_out = mcycle    [31:0 ];
      `MCYCLEH:       csr_data_out = mcycle    [63:32];
      `MINSTRET:      csr_data_out = minstret  [31:0 ];
      `MINSTRETH:     csr_data_out = minstret  [63:32];
      default:        csr_data_out = 32'h00000000;
    endcase
  end

  // ----------------------------------------------------------------------------------------------
  // mstatus : M-mode Status register
  // ----------------------------------------------------------------------------------------------

  assign mstatus = {
    19'b0000000000000000000,
    2'b11,          // M-mode Prior Privilege (always M-mode)
    3'b000,
    mstatus_mpie,   // M-mode Prior Global Interrupt Enable
    3'b000,
    mstatus_mie,    // M-mode Global Interrupt Enable
    3'b000
  };
  
  always @(posedge clock) begin : mstatus_csr_fields_update
    if(reset) begin
      mstatus_mie   <= 1'b0;
      mstatus_mpie  <= 1'b1;
    end
    else if(current_state == STATE_TRAP_RETURN) begin
      mstatus_mie   <= mstatus_mpie;
      mstatus_mpie  <= 1'b1;
    end
    else if(current_state == STATE_TRAP_TAKEN) begin
      mstatus_mpie  <= mstatus_mie;
      mstatus_mie   <= 1'b0;
    end
    else if(current_state == STATE_OPERATING && csr_address == `MSTATUS && write_enable) begin
      mstatus_mie   <= csr_write_data[3];
      mstatus_mpie  <= csr_write_data[7];
    end    
  end

  // ----------------------------------------------------------------------------------------------
  // mie : M-mode Interrupt Enable register
  // ----------------------------------------------------------------------------------------------

  assign mie = {
    20'b0,
    mie_meie,   // M-mode External Interrupt Enable
    3'b0,
    mie_mtie,   // M-mode Timer Interrupt Enable
    3'b0,
    mie_msie,   // M-mode Software Interrupt Enable
    3'b0
  };

  always @(posedge clock) begin : mie_csr_fields_implementation
    if(reset) begin
      mie_meie <= 1'b0;
      mie_mtie <= 1'b0;
      mie_msie <= 1'b0;
    end
    else if(csr_address == `MIE && write_enable) begin            
      mie_meie <= csr_write_data[11];
      mie_mtie <= csr_write_data[7];
      mie_msie <= csr_write_data[3];
    end
  end
  
  // ----------------------------------------------------------------------------------------------
  // mip : M-mode Interrupt Pending
  // ----------------------------------------------------------------------------------------------

  assign mip = {
    20'b0,
    mip_meip,
    3'b0,
    mip_mtip,
    3'b0,
    mip_msip,
    3'b0
  };

  always @(posedge clock) begin : mip_csr_fields_implementation
    if(reset) begin
      mip_meip <= 1'b0;
      mip_mtip <= 1'b0;
      mip_msip <= 1'b0;
    end
    else begin
      mip_meip <= interrupt_request_external;
      mip_mtip <= interrupt_request_timer;
      mip_msip <= interrupt_request_software;
    end
  end
  
  // ----------------------------------------------------------------------------------------------
  // mepc : M-mode Exception Program Counter register
  // ----------------------------------------------------------------------------------------------

  assign exception_program_counter =
    mepc;

  always @(posedge clock) begin : mepc_implementation
    if(reset)
      mepc <= 32'b0;
    else if(current_state == STATE_TRAP_TAKEN)
      mepc <= program_counter_stage3;
    else if(current_state == STATE_OPERATING && csr_address == `MEPC && write_enable)
      mepc <= {csr_write_data[31:2], 2'b00};
  end
  
  // ----------------------------------------------------------------------------------------------
  // mscratch : M-mode Scratch register
  // ----------------------------------------------------------------------------------------------

  always @(posedge clock) begin
    if(reset)
      mscratch <= 32'b0;
    else if(csr_address == `MSCRATCH && write_enable)
      mscratch <= csr_write_data;
  end
  
  // ----------------------------------------------------------------------------------------------
  // mcycle : M-mode Cycle Counter register
  // ----------------------------------------------------------------------------------------------

  always @(posedge clock) begin : mcycle_implementation
    if (reset)
      mcycle <= 64'b0;
    else begin 
      if (csr_address == `MCYCLE && write_enable)
        mcycle <= {mcycle[63:32], csr_write_data} + 1;
      else if (csr_address == `MCYCLEH && write_enable)
        mcycle <= {csr_write_data, mcycle[31:0]} + 1;
      else
        mcycle <= mcycle + 1;      
    end
  end
  
  // ----------------------------------------------------------------------------------------------
  // minstret : M-mode Instruction Retired Counter register
  // ----------------------------------------------------------------------------------------------

  always @(posedge clock) begin : minstret_implementation
    if (reset)
      minstret  <= 64'b0;
    else begin 
      if (csr_address == `MINSTRET && write_enable) begin
        if (current_state == STATE_OPERATING)
          minstret <= {minstret[63:32], csr_write_data} + 1;
        else
          minstret <= {minstret[63:32], csr_write_data};
      end
      else if (csr_address == `MINSTRETH && write_enable) begin
        if (current_state == STATE_OPERATING)
          minstret <= {csr_write_data, minstret[31:0]} + 1;
        else
          minstret <= {csr_write_data, minstret[31:0]};
      end
      else begin
        if (current_state == STATE_OPERATING)
          minstret <= minstret + 1;
        else
          minstret <= minstret;
      end      
    end
  end
  
  // ----------------------------------------------------------------------------------------------
  // utime : Time register (Read-only shadow of mtime)
  // ----------------------------------------------------------------------------------------------

  always @(posedge clock) begin : utime_csr_implementation
    utime <= real_time;
  end
  
  // ----------------------------------------------------------------------------------------------
  // mcause : M-mode Trap Cause register
  // ----------------------------------------------------------------------------------------------

  always @(posedge clock) begin : mcause_implementation
    if(reset) 
      mcause <= 32'h00000000;
    else if(current_state == STATE_TRAP_TAKEN)
      mcause <= {mcause_interrupt_flag, 27'b0, mcause_cause_code};
    else if(current_state == STATE_OPERATING && csr_address == `MCAUSE && write_enable) 
      mcause <= csr_write_data;
  end

  always @(posedge clock) begin : trap_cause_implementation
    if(reset) begin
      mcause_cause_code       <= 4'b0;
      mcause_interrupt_flag   <= 1'b0;
    end
    else if(current_state == STATE_OPERATING) begin 
      if(illegal_instruction) begin
        mcause_cause_code     <= 4'b0010;
        mcause_interrupt_flag <= 1'b0;
      end
      else if(misaligned_instruction_address) begin
        mcause_cause_code     <= 4'b0000;
        mcause_interrupt_flag <= 1'b0;
      end
      else if(ecall) begin
        mcause_cause_code     <= 4'b1011;
        mcause_interrupt_flag <= 1'b0;
      end
      else if(ebreak) begin
        mcause_cause_code     <= 4'b0011;
        mcause_interrupt_flag <= 1'b0;
      end
      else if(misaligned_store) begin
        mcause_cause_code     <= 4'b0110;
        mcause_interrupt_flag <= 1'b0;
      end
      else if(misaligned_load) begin
        mcause_cause_code     <= 4'b0100;
        mcause_interrupt_flag <= 1'b0;
      end
      else if(mstatus_mie & mie_meie & mip_meip) begin
        mcause_cause_code     <= 4'b1011;
        mcause_interrupt_flag <= 1'b1;
      end
      else if(mstatus_mie & mie_mtie & mip_mtip) begin
        mcause_cause_code     <= 4'b0111;
        mcause_interrupt_flag <= 1'b1;
      end
      else if(mstatus_mie & mie_msie & mip_msip) begin
        mcause_cause_code     <= 4'b0011;
        mcause_interrupt_flag <= 1'b1;
      end
    end        
  end
  
  // ----------------------------------------------------------------------------------------------
  // mtval : M-mode Trap Value
  // ----------------------------------------------------------------------------------------------

  always @(posedge clock) begin
    if (reset)
      misaligned_address_exception <= 1'b0;
    else
      misaligned_address_exception <= misaligned_load | misaligned_store | misaligned_instruction_address;
  end

  always @(posedge clock) begin : mtval_implementation
    if(reset) 
      mtval <= 32'h00000000;
    else if(current_state == STATE_TRAP_TAKEN) begin
      if(misaligned_address_exception)
        mtval <= target_address_adder_stage3;
      else
        mtval <= 32'h00000000;
    end
    else if(current_state == STATE_OPERATING && csr_address == `MTVAL && write_enable) 
      mtval <= csr_write_data;
  end
  
  // ----------------------------------------------------------------------------------------------
  // mtvec : M-mode Trap Vector Address register
  // ----------------------------------------------------------------------------------------------
 
  assign base_address_offset =
    mcause_cause_code << 2;

  assign trap_address = 
    mtvec[1:0] == 2'b01 && mcause_interrupt_flag ?
    {mtvec[31:2], 2'b00} + base_address_offset :
    {mtvec[31:2], 2'b00};

  always @(posedge clock) begin : mtvec_implementation
    if(reset)
      mtvec <= 32'b0;
    else if(csr_address == `MTVEC && write_enable)
      mtvec <= {csr_write_data[31:2], 1'b0, csr_write_data[0]};
  end
    
endmodule