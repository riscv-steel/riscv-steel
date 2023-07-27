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

Top Module:    riscv_steel_core
 
**************************************************************************************************/

module riscv_steel_core #(
  
  parameter     [31:0]  BOOT_ADDRESS = 32'h00000000

  ) (

  // Basic system signals
  
  input  wire           clock,
  input  wire           reset_n,

  // Instruction fetch interface

  output wire   [31:0]  instruction_address,
  output wire           instruction_address_valid,
  input  wire   [31:0]  instruction_in,
  input  wire           instruction_in_valid,
    
  // Data fetch/write interface

  output wire   [31:0]  data_rw_address,
  output wire           data_rw_address_valid,
  output wire   [31:0]  data_out,
  output wire           data_write_request,
  output wire   [3:0 ]  data_write_strobe,
  input  wire   [31:0]  data_in,
  input  wire           data_rw_valid,
  
  // Interrupt signals (hardwire inputs to zero if unused)

  input  wire           irq_external,
  output wire           irq_external_ack,
  input  wire           irq_timer,
  output wire           irq_timer_ack,
  input  wire           irq_software,  
  output wire           irq_software_ack,

  // Real Time Counter (hardwire to zero if unused)

  input  wire   [63:0]  real_time

  );

  //-----------------------------------------------------------------------------------------------//
  // Constants                                                                                     //
  //-----------------------------------------------------------------------------------------------//

  // Address of Machine Information CSRs

  localparam MARCHID              = 12'hF12;
  localparam MIMPID               = 12'hF13;

  // Address of Performance Counters CSRs

  localparam CYCLE                = 12'hC00;
  localparam TIME                 = 12'hC01;
  localparam INSTRET              = 12'hC02;
  localparam CYCLEH               = 12'hC80;
  localparam TIMEH                = 12'hC81;
  localparam INSTRETH             = 12'hC82;

  // Address of Machine Trap Setup CSRs

  localparam MSTATUS              = 12'h300;
  localparam MSTATUSH             = 12'h310;
  localparam MISA                 = 12'h301;
  localparam MIE                  = 12'h304;
  localparam MTVEC                = 12'h305;

  // Address of Machine Trap Handling CSRs

  localparam MSCRATCH             = 12'h340;
  localparam MEPC                 = 12'h341;
  localparam MCAUSE               = 12'h342;
  localparam MTVAL                = 12'h343;
  localparam MIP                  = 12'h344;

  // Address of Machine Performance Counters CSRs

  localparam MCYCLE               = 12'hB00;
  localparam MINSTRET             = 12'hB02;
  localparam MCYCLEH              = 12'hB80;
  localparam MINSTRETH            = 12'hB82;

  // Writeback Mux selection

  localparam WB_ALU               = 3'b000;
  localparam WB_LOAD_UNIT         = 3'b001;
  localparam WB_UPPER_IMM         = 3'b010;
  localparam WB_TARGET_ADDER      = 3'b011;
  localparam WB_CSR               = 3'b100;
  localparam WB_PC_PLUS_4         = 3'b101;

  // Immediate format selection

  localparam I_TYPE_IMMEDIATE     = 3'b001;
  localparam S_TYPE_IMMEDIATE     = 3'b010;
  localparam B_TYPE_IMMEDIATE     = 3'b011;
  localparam U_TYPE_IMMEDIATE     = 3'b100;
  localparam J_TYPE_IMMEDIATE     = 3'b101;
  localparam CSR_TYPE_IMMEDIATE   = 3'b110;

  // Program Counter source selection

  localparam PC_BOOT              = 2'b00;
  localparam PC_EPC               = 2'b01;
  localparam PC_TRAP              = 2'b10;
  localparam PC_NEXT              = 2'b11;

  // Load size encoding

  localparam LOAD_SIZE_BYTE       = 2'b00;
  localparam LOAD_SIZE_HALF       = 2'b01;
  localparam LOAD_SIZE_WORD       = 2'b10;

  // CSR File operation encoding

  localparam CSR_RWX              = 2'b01;
  localparam CSR_RSX              = 2'b10;
  localparam CSR_RCX              = 2'b11;

  // States in M-mode

  localparam STATE_RESET          = 4'b0001; 
  localparam STATE_OPERATING      = 4'b0010;
  localparam STATE_TRAP_TAKEN     = 4'b0100;    
  localparam STATE_TRAP_RETURN    = 4'b1000;

  // No operation

  localparam NOP_INSTRUCTION      = 32'h00000013;

  // Opcodes

  localparam OPCODE_OP            = 7'b0110011;
  localparam OPCODE_OP_IMM        = 7'b0010011;
  localparam OPCODE_LOAD          = 7'b0000011;
  localparam OPCODE_STORE         = 7'b0100011;
  localparam OPCODE_BRANCH        = 7'b1100011;
  localparam OPCODE_JAL           = 7'b1101111;
  localparam OPCODE_JALR          = 7'b1100111;
  localparam OPCODE_LUI           = 7'b0110111;
  localparam OPCODE_AUIPC         = 7'b0010111;
  localparam OPCODE_MISC_MEM      = 7'b0001111;
  localparam OPCODE_SYSTEM        = 7'b1110011;

  // Funct3

  localparam FUNCT3_ADD           = 3'b000;
  localparam FUNCT3_SUB           = 3'b000;
  localparam FUNCT3_SLT           = 3'b010;
  localparam FUNCT3_SLTU          = 3'b011;
  localparam FUNCT3_AND           = 3'b111;
  localparam FUNCT3_OR            = 3'b110;
  localparam FUNCT3_XOR           = 3'b100;
  localparam FUNCT3_SLL           = 3'b001;
  localparam FUNCT3_SRL           = 3'b101;
  localparam FUNCT3_SRA           = 3'b101;
  localparam FUNCT3_ADDI          = 3'b000;
  localparam FUNCT3_SLTI          = 3'b010;
  localparam FUNCT3_SLTIU         = 3'b011;
  localparam FUNCT3_ANDI          = 3'b111;
  localparam FUNCT3_ORI           = 3'b110;
  localparam FUNCT3_XORI          = 3'b100;
  localparam FUNCT3_SLLI          = 3'b001;
  localparam FUNCT3_SRLI          = 3'b101;
  localparam FUNCT3_SRAI          = 3'b101;
  localparam FUNCT3_BEQ           = 3'b000;
  localparam FUNCT3_BNE           = 3'b001;
  localparam FUNCT3_BLT           = 3'b100;
  localparam FUNCT3_BGE           = 3'b101;
  localparam FUNCT3_BLTU          = 3'b110;
  localparam FUNCT3_BGEU          = 3'b111;
  localparam FUNCT3_JALR          = 3'b000;
  localparam FUNCT3_SB            = 3'b000;
  localparam FUNCT3_SH            = 3'b001;
  localparam FUNCT3_SW            = 3'b010;
  localparam FUNCT3_LB            = 3'b000;
  localparam FUNCT3_LH            = 3'b001;
  localparam FUNCT3_LW            = 3'b010;
  localparam FUNCT3_LBU           = 3'b100;
  localparam FUNCT3_LHU           = 3'b101;
  localparam FUNCT3_CSRRW         = 3'b001;
  localparam FUNCT3_CSRRS         = 3'b010;
  localparam FUNCT3_CSRRC         = 3'b011;
  localparam FUNCT3_CSRRWI        = 3'b101;
  localparam FUNCT3_CSRRSI        = 3'b110;
  localparam FUNCT3_CSRRCI        = 3'b111;
  localparam FUNCT3_FENCE         = 3'b000;
  localparam FUNCT3_ECALL         = 3'b000;
  localparam FUNCT3_EBREAK        = 3'b000;
  localparam FUNCT3_MRET          = 3'b000;

  // Funct7

  localparam FUNCT7_SUB           = 7'b0100000;
  localparam FUNCT7_SRA           = 7'b0100000;
  localparam FUNCT7_ADD           = 7'b0000000;
  localparam FUNCT7_SLT           = 7'b0000000;
  localparam FUNCT7_SLTU          = 7'b0000000;
  localparam FUNCT7_AND           = 7'b0000000;
  localparam FUNCT7_OR            = 7'b0000000;
  localparam FUNCT7_XOR           = 7'b0000000;
  localparam FUNCT7_SLL           = 7'b0000000;
  localparam FUNCT7_SRL           = 7'b0000000;
  localparam FUNCT7_SRAI          = 7'b0100000;
  localparam FUNCT7_SLLI          = 7'b0000000;
  localparam FUNCT7_SRLI          = 7'b0000000;
  localparam FUNCT7_ECALL         = 7'b0000000;
  localparam FUNCT7_EBREAK        = 7'b0000000;
  localparam FUNCT7_MRET          = 7'b0011000;
  
  // RS1, RS2 and RD encodings for SYSTEM instructions

  localparam RS1_ECALL            = 5'b00000;
  localparam RS1_EBREAK           = 5'b00000;
  localparam RS1_MRET             = 5'b00000;
  localparam RS2_ECALL            = 5'b00000;
  localparam RS2_EBREAK           = 5'b00001;
  localparam RS2_MRET             = 5'b00010;
  localparam RD_ECALL             = 5'b00000;
  localparam RD_EBREAK            = 5'b00000;
  localparam RD_MRET              = 5'b00000; 
  
  //-----------------------------------------------------------------------------------------------//
  // Wires and regs                                                                                //
  //-----------------------------------------------------------------------------------------------//

  wire  [31:0]  adder_second_operand_mux;
  wire  [31:0]  alu_2nd_operand;
  wire          alu_2nd_operand_source;
  reg           alu_2nd_operand_source_stage3;
  wire  [3:0 ]  alu_operation_code;
  reg   [3:0 ]  alu_operation_code_stage3;
  reg   [31:0]  alu_output;
  wire          alu_slt_result;
  wire          alu_sltu_result;
  wire  [31:0]  alu_sra_result;
  wire  [31:0]  alu_srl_result;
  wire  [31:0]  b_type_immediate;
  reg           branch_condition_satisfied;
  wire  [31:0]  branch_target_address;
  wire  [23:0]  byte_data_upper_bits;
  wire          clock_enable;
  wire  [31:0]  csr_data_mask;
  reg   [31:0]  csr_data_out;
  wire          csr_file_write_enable;
  wire          csr_file_write_request;
  reg           csr_file_write_request_stage3;
  wire  [2:0 ]  csr_operation;
  reg   [2:0 ]  csr_operation_stage3;
  wire  [31:0]  csr_type_immediate;
  reg   [31:0]  csr_write_data;    
  reg   [3:0 ]  current_state;
  reg   [31:0]  data_out_internal;
  wire          ebreak;
  wire          ecall;
  wire  [31:0]  exception_program_counter;
  wire          flush_pipeline;
  wire  [15:0]  half_data_upper_bits;
  wire  [31:0]  i_type_immediate;
  wire          illegal_instruction;    
  reg   [31:0]  immediate;
  reg   [31:0]  immediate_stage3;
  reg   [2:0 ]  immediate_type;
  reg   [31:0]  integer_file [31:1];
  wire          integer_file_write_enable;
  wire          integer_file_write_request;
  reg           integer_file_write_request_stage3;
  wire  [31:0]  instruction;
  wire  [2:0 ]  instruction_funct3;
  wire  [6:0 ]  instruction_funct7;
  wire  [6:0 ]  instruction_opcode;  
  wire  [11:0]  instruction_csr_address;
  reg   [11:0]  instruction_csr_address_stage3;  
  wire  [4:0 ]  instruction_rd_address;
  reg   [4:0 ]  instruction_rd_address_stage3;  
  wire  [4:0 ]  instruction_rs1_address;
  wire  [4:0 ]  instruction_rs2_address;
  wire  [31:0]  j_type_immediate;
  wire          load;
  reg   [7:0 ]  load_byte_data;
  reg   [31:0]  load_data;
  reg   [15:0]  load_half_data;
  wire  [1:0 ]  load_size;
  reg   [1:0 ]  load_size_stage3;
  wire          load_unsigned;
  reg           load_unsigned_stage3;  
  reg   [31:0]  mcause;
  reg   [3:0 ]  mcause_cause_code;
  reg           mcause_interrupt_flag;
  reg   [63:0]  mcycle;
  reg   [31:0]  mepc;
  wire  [31:0]  mie;  
  reg           mie_meie;
  reg           mie_msie;
  reg           mie_mtie;  
  wire  [31:0]  mip;
  reg           mip_mtip;
  reg           mip_meip;  
  reg           mip_msip;
  reg   [63:0]  minstret;
  wire  [31:0]  minus_second_operand;
  reg           misaligned_address_exception;
  wire          misaligned_instruction_address;
  wire          misaligned_load;
  wire          misaligned_store;
  wire          mret;
  reg   [31:0]  mscratch;
  wire  [31:0]  mstatus;
  reg           mstatus_mie;
  reg           mstatus_mpie;
  reg   [31:0]  mtvec;
  reg   [31:0]  mtval;
  wire  [31:0]  next_address;
  reg   [31:0]  next_program_counter;
  reg   [3:0 ]  next_state;
  reg   [31:0]  rs1_data_stage3;  
  reg   [31:0]  rs2_data_stage3;
  reg   [31:0]  prev_data_out;
  reg           prev_data_rw_address_valid;
  reg   [31:0]  prev_instruction_address;
  reg           prev_instruction_address_valid;
  reg   [31:0]  prev_rw_address;
  reg           prev_rw_address_valid;
  reg           prev_write_request;
  reg   [3:0 ]  prev_write_strobe;
  reg   [31:0]  program_counter;
  wire  [31:0]  program_counter_plus_4;
  reg   [31:0]  program_counter_plus_4_stage3; 
  reg   [1:0 ]  program_counter_source;  
  reg   [31:0]  program_counter_stage3;
  wire  [4:0 ]  rd_addr;
  wire  [31:0]  rd_data;
  wire          reset;
  wire  [4:0 ]  rs1_addr;
  wire  [31:0]  rs1_data;
  wire  [31:0]  rs1_mux;
  wire  [4:0 ]  rs2_addr;    
  wire  [31:0]  rs2_mux;  
  wire  [31:0]  rs2_data;  
  wire  [31:0]  rw_address_internal;
  wire  [31:0]  s_type_immediate;
  wire  [31:0]  shift_right_mux;
  wire  [19:0]  sign_extension;
  wire          store;
  reg   [31:0]  store_byte_data;
  reg   [31:0]  store_half_data;
  wire          take_branch;
  wire          take_trap;
  wire  [31:0]  target_address_adder;  
  reg   [31:0]  target_address_adder_stage3;
  wire          target_address_source;
  wire  [31:0]  trap_address;
  wire  [31:0]  u_type_immediate;
  reg   [63:0]  utime;  
  wire          write_request_internal;  
  reg   [3:0 ]  write_strobe_for_byte;
  reg   [3:0 ]  write_strobe_for_half;  
  reg   [3:0 ]  write_strobe_internal;
  reg   [2:0 ]  writeback_mux_selector;
  reg   [2:0 ]  writeback_mux_selector_stage3; 
  reg   [31:0]  writeback_multiplexer_output;  

  //-----------------------------------------------------------------------------------------------//
  // Global reset and clock enable logic                                                           //
  //-----------------------------------------------------------------------------------------------//

  assign reset = !reset_n;

  assign clock_enable = 
    !((prev_instruction_address_valid & !instruction_in_valid) |
    (prev_data_rw_address_valid & !data_rw_valid));
  
  //-----------------------------------------------------------------------------------------------//
  // Instruction fetch and instruction address logic                                               //
  //-----------------------------------------------------------------------------------------------//

  assign instruction_address =
    reset ?
    BOOT_ADDRESS :
    (clock_enable ?
      next_program_counter :
      prev_instruction_address);   
  
  assign instruction_address_valid =
    reset ?
    1'b0 :
    (clock_enable ?    
      ((program_counter_source == PC_NEXT) |
       (program_counter_source == PC_BOOT)) :
      prev_instruction_address_valid);

  always @(posedge clock) begin
    if (reset) begin
      prev_instruction_address <= BOOT_ADDRESS;
      prev_instruction_address_valid <= 1'b0;
      prev_data_rw_address_valid <= 1'b0;
    end
    else if(clock_enable) begin
      prev_instruction_address <= instruction_address;
      prev_instruction_address_valid <= instruction_address_valid;    
      prev_data_rw_address_valid <= data_rw_address_valid;
    end
  end 
    
  always @* begin : next_program_counter_mux
    case (program_counter_source)
      PC_BOOT: next_program_counter = BOOT_ADDRESS;
      PC_EPC:  next_program_counter = exception_program_counter;
      PC_TRAP: next_program_counter = trap_address;
      PC_NEXT: next_program_counter = next_address;
    endcase
  end
    
  assign program_counter_plus_4 =
    program_counter + 32'h00000004;
  
  assign target_address_adder =
    target_address_source == 1'b1 ?
    rs1_data + immediate :
    program_counter + immediate;

  assign branch_target_address =
    {target_address_adder[31:1], 1'b0};

  assign next_address =
   take_branch ?
   branch_target_address :
   program_counter_plus_4;
    
  always @(posedge clock) begin : program_counter_reg_implementation
    if (reset)
      program_counter <= BOOT_ADDRESS;
    else if (clock_enable)
      program_counter <= next_program_counter;
  end  
    
  assign instruction =
    flush_pipeline == 1'b1 ?
    NOP_INSTRUCTION :
    instruction_in;
  
  assign instruction_opcode =
    instruction[6:0];

  assign instruction_funct3 =
    instruction[14:12];

  assign instruction_funct7 =
    instruction[31:25];

  assign instruction_rs1_address =
    instruction[19:15];

  assign instruction_rs2_address =
    instruction[24:20];

  assign instruction_rd_address =
    instruction[11:7];

  assign instruction_csr_address =
    instruction[31:20];   

  //-----------------------------------------------------------------------------------------------//
  // Data fetch / store                                                                            //
  //-----------------------------------------------------------------------------------------------//
  
  always @(posedge clock) begin
    if (reset) begin
      prev_rw_address <= 32'b0;
      prev_data_out <= 32'b0;
      prev_write_request <= 1'b0;
      prev_write_strobe <= 4'b0000;
      prev_rw_address_valid <= 1'b0;
    end
    else if (clock_enable) begin
      prev_rw_address <= data_rw_address;
      prev_data_out <= data_out;
      prev_write_request <= data_write_request;
      prev_write_strobe <= data_write_strobe;
      prev_rw_address_valid <= data_rw_address_valid;
    end    
  end

  assign data_rw_address_valid =
    reset ?
    1'b0 :
    (clock_enable ?
      load | store :
      prev_rw_address_valid);

  assign data_rw_address =
    reset ?
    32'b0 :
    (clock_enable ?
      rw_address_internal :
      prev_rw_address);
  
  assign data_write_request =
    reset ?
    1'b0 :
    (clock_enable ?
      write_request_internal :
      prev_write_request);

  assign data_out =
    reset ?
    32'b0 :
    (clock_enable ?
      data_out_internal :
      prev_data_out);

  assign data_write_strobe =
    reset ?
    4'b0 :
    (clock_enable ?
      write_strobe_internal :
      prev_write_strobe);

  assign write_request_internal =
    store & ~misaligned_store & ~take_trap;
  
  assign rw_address_internal = {target_address_adder[31:2], 2'b00};
  
  always @* begin
    case(instruction_funct3)
      FUNCT3_SB: begin
        write_strobe_internal = write_strobe_for_byte;
        data_out_internal     = store_byte_data;
      end
      FUNCT3_SH: begin
        write_strobe_internal = write_strobe_for_half;
        data_out_internal     = store_half_data;
      end
      FUNCT3_SW: begin
        write_strobe_internal = {4{data_write_request}};
        data_out_internal     = rs2_data;
      end
      default: begin
        write_strobe_internal = {4{data_write_request}};
        data_out_internal     = rs2_data;
      end 
    endcase
  end
    
  always @* begin
    case(target_address_adder[1:0])
      2'b00: begin 
        store_byte_data = {24'b0, rs2_data[7:0]};
        write_strobe_for_byte = {3'b0, data_write_request};
      end
      2'b01: begin
        store_byte_data = {16'b0, rs2_data[7:0], 8'b0};
        write_strobe_for_byte = {2'b0, data_write_request, 1'b0};
      end
      2'b10: begin
        store_byte_data = {8'b0, rs2_data[7:0], 16'b0};
        write_strobe_for_byte = {1'b0, data_write_request, 2'b0};
      end
      2'b11: begin
        store_byte_data = {rs2_data[7:0], 24'b0};
        write_strobe_for_byte = {data_write_request, 3'b0};
      end
    endcase    
  end
    
  always @* begin
    case(target_address_adder[1])
      1'b0: begin
        store_half_data = {16'b0, rs2_data[15:0]};
        write_strobe_for_half = {2'b0, {2{data_write_request}}};
      end
      1'b1: begin
        store_half_data = {rs2_data[15:0], 16'b0};
        write_strobe_for_half = {{2{data_write_request}}, 2'b0};
      end
    endcase
  end
    
  //-----------------------------------------------------------------------------------------------//
  // Instruction decoding                                                                          //
  //-----------------------------------------------------------------------------------------------//
    
  // Instruction type detection

  assign branch_type =
    instruction_opcode == OPCODE_BRANCH;

  assign jal_type =
    instruction_opcode == OPCODE_JAL;

  assign jalr_type =
    instruction_opcode == OPCODE_JALR;

  assign auipc_type =
    instruction_opcode == OPCODE_AUIPC;

  assign lui_type =
    instruction_opcode == OPCODE_LUI;

  assign load_type =
    instruction_opcode == OPCODE_LOAD;

  assign store_type =
    instruction_opcode == OPCODE_STORE;

  assign system_type =
    instruction_opcode == OPCODE_SYSTEM;

  assign op_type =
    instruction_opcode == OPCODE_OP;

  assign op_imm_type =
    instruction_opcode == OPCODE_OP_IMM;

  assign misc_mem_type =
    instruction_opcode == OPCODE_MISC_MEM;
  
  // Instruction detection

  assign addi =
    op_imm_type &
    instruction_funct3 == FUNCT3_ADDI;

  assign slti =
    op_imm_type &
    instruction_funct3 == FUNCT3_SLTI;

  assign sltiu =
    op_imm_type &
    instruction_funct3 == FUNCT3_SLTIU;

  assign andi =
    op_imm_type &
    instruction_funct3 == FUNCT3_ANDI;

  assign ori =
    op_imm_type &
    instruction_funct3 == FUNCT3_ORI;

  assign xori =
    op_imm_type &
    instruction_funct3 == FUNCT3_XORI;

  assign slli =
    op_imm_type &
    instruction_funct3 == FUNCT3_SLLI &
    instruction_funct7 == FUNCT7_SLLI;

  assign srli =
    op_imm_type &
    instruction_funct3 == FUNCT3_SRLI &
    instruction_funct7 == FUNCT7_SRLI;

  assign srai =
    op_imm_type &
    instruction_funct3 == FUNCT3_SRAI &
    instruction_funct7 == FUNCT7_SRAI;

  assign add =
    op_type &
    instruction_funct3 == FUNCT3_ADD &
    instruction_funct7 == FUNCT7_ADD;

  assign sub = 
    op_type &
    instruction_funct3 == FUNCT3_SUB &
    instruction_funct7 == FUNCT7_SUB;

  assign slt =
    op_type &
    instruction_funct3 == FUNCT3_SLT &
    instruction_funct7 == FUNCT7_SLT;

  assign sltu =
    op_type &
    instruction_funct3 == FUNCT3_SLTU &
    instruction_funct7 == FUNCT7_SLTU;

  assign is_and =
    op_type &
    instruction_funct3 == FUNCT3_AND &
    instruction_funct7 == FUNCT7_AND;

  assign is_or =
    op_type &
    instruction_funct3 == FUNCT3_OR &
    instruction_funct7 == FUNCT7_OR;

  assign is_xor =
    op_type &
    instruction_funct3 == FUNCT3_XOR &
    instruction_funct7 == FUNCT7_XOR;

  assign sll =
    op_type &
    instruction_funct3 == FUNCT3_SLL &
    instruction_funct7 == FUNCT7_SLL;

  assign srl =
    op_type &
    instruction_funct3 == FUNCT3_SRL &
    instruction_funct7 == FUNCT7_SRL;

  assign sra =
    op_type &
    instruction_funct3 == FUNCT3_SRA &
    instruction_funct7 == FUNCT7_SRA;

  assign csrxxx =
    system_type &
    instruction_funct3 != 3'b000 &
    instruction_funct3 != 3'b100;

  assign ecall =
    system_type &
    instruction_funct3 == FUNCT3_ECALL &
    instruction_funct7 == FUNCT7_ECALL &
    instruction_rs1_address == RS1_ECALL &
    instruction_rs2_address == RS2_ECALL &
    instruction_rd_address  == RD_ECALL;

  assign ebreak =
    system_type &
    instruction_funct3 == FUNCT3_EBREAK &
    instruction_funct7 == FUNCT7_EBREAK &
    instruction_rs1_address == RS1_EBREAK &
    instruction_rs2_address == RS2_EBREAK &
    instruction_rd_address  == RD_EBREAK;

  assign mret =
    system_type &
    instruction_funct3 == FUNCT3_MRET &
    instruction_funct7 == FUNCT7_MRET &
    instruction_rs1_address == RS1_MRET &
    instruction_rs2_address == RS2_MRET &
    instruction_rd_address  == RD_MRET;

  // Illegal instruction detection

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

  // Misaligned address detection

  assign misaligned_word =
    instruction_funct3[1:0] == 2'b10 &
    (target_address_adder[1] | target_address_adder[0]);

  assign misaligned_half =
    instruction_funct3[1:0] == 2'b01 &
    target_address_adder[0];
    
  assign misaligned =
    misaligned_word | misaligned_half;

  assign misaligned_store =
    store & misaligned;

  assign misaligned_load =
    load & misaligned;

  // Control signals generation

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

  assign integer_file_write_request =
    lui_type | auipc_type | jalr_type | jal_type | op_type | op_imm_type | load_type | csrxxx;

  assign csr_file_write_request =
    csrxxx;  

  assign csr_operation = instruction_funct3;

  always @* begin : writeback_selector_decoding
    if (op_type == 1'b1 || op_imm_type == 1'b1)
      writeback_mux_selector = WB_ALU;
    else if (load_type == 1'b1)
      writeback_mux_selector = WB_LOAD_UNIT;
    else if (jal_type == 1'b1 || jalr_type == 1'b1)
      writeback_mux_selector = WB_PC_PLUS_4;
    else if (lui_type == 1'b1)
      writeback_mux_selector = WB_UPPER_IMM;
    else if (auipc_type == 1'b1)
      writeback_mux_selector = WB_TARGET_ADDER;
    else if (csrxxx == 1'b1)
      writeback_mux_selector = WB_CSR;
    else
      writeback_mux_selector = WB_ALU;
  end

  always @* begin : immediate_type_decoding
    if (op_imm_type == 1'b1 || load_type == 1'b1 || jalr_type == 1'b1)
      immediate_type = I_TYPE_IMMEDIATE;
    else if (store_type == 1'b1)
      immediate_type = S_TYPE_IMMEDIATE;
    else if (branch_type == 1'b1)
      immediate_type = B_TYPE_IMMEDIATE;
    else if (jal_type == 1'b1)
      immediate_type = J_TYPE_IMMEDIATE;
    else if (lui_type == 1'b1 || auipc_type == 1'b1)
      immediate_type = U_TYPE_IMMEDIATE;
    else if (csrxxx == 1'b1)
      immediate_type = CSR_TYPE_IMMEDIATE;
    else
      immediate_type = I_TYPE_IMMEDIATE;
  end
    
  //-----------------------------------------------------------------------------------------------//
  // Immediate generation                                                                          //
  //-----------------------------------------------------------------------------------------------//
   
  assign sign_extension = {
    20 {instruction[31]}
  };

  assign i_type_immediate = {
    sign_extension,
    instruction[31:20]
  };

  assign s_type_immediate = {
    sign_extension,
    instruction[31:25],
    instruction[11:7 ]
  };

  assign b_type_immediate = {
    sign_extension,
    instruction[7],
    instruction[30:25],
    instruction[11:8],
    1'b0
  };

  assign u_type_immediate = {
    instruction[31:12],
    12'h000
  };

  assign j_type_immediate = {
    sign_extension[11:0],
    instruction[19:12],
    instruction[20],
    instruction[30:21],
    1'b0
  };

  assign csr_type_immediate = {
    27'b0,
    instruction[19:15]
  };
  
  always @(*) begin : immediate_mux
    case (immediate_type) 
      I_TYPE_IMMEDIATE:
        immediate = i_type_immediate;
      S_TYPE_IMMEDIATE:
        immediate = s_type_immediate;
      B_TYPE_IMMEDIATE:
        immediate = b_type_immediate;
      U_TYPE_IMMEDIATE:
        immediate = u_type_immediate;
      J_TYPE_IMMEDIATE:
        immediate = j_type_immediate;
      CSR_TYPE_IMMEDIATE:
        immediate = csr_type_immediate;
      default:
        immediate = i_type_immediate;
    endcase
  end
    
  //-----------------------------------------------------------------------------------------------//
  // Take branch decision                                                                          //
  //-----------------------------------------------------------------------------------------------//
    
  assign is_branch =
    branch_type & !illegal_branch;

  assign is_jump =
    jal_type | (jalr_type & !illegal_jalr);
    
  assign is_equal =
    rs1_data == rs2_data;

  assign is_not_equal =
    !is_equal;

  assign is_less_than_unsigned =
    rs1_data < rs2_data;
    
  assign is_less_than =
    rs1_data[31] ^ rs2_data[31] ?
    rs1_data[31] :
    is_less_than_unsigned;

  assign is_greater_or_equal_than =
    !is_less_than;  

  assign is_greater_or_equal_than_unsigned =
    !is_less_than_unsigned;

  always @* begin : branch_condition_satisfied_mux
    case (instruction_funct3)
      FUNCT3_BEQ:
        branch_condition_satisfied =
          is_equal;
      FUNCT3_BNE:
        branch_condition_satisfied =
          is_not_equal;
      FUNCT3_BLT:
        branch_condition_satisfied =
          is_less_than;
      FUNCT3_BGE:
        branch_condition_satisfied =
          is_greater_or_equal_than;
      FUNCT3_BLTU:
        branch_condition_satisfied =
          is_less_than_unsigned;
      FUNCT3_BGEU:
        branch_condition_satisfied =
          is_greater_or_equal_than_unsigned;
      default:
        branch_condition_satisfied =
          1'b0;
      endcase
  end
  
  assign take_branch =
    (is_jump == 1'b1) ?
    1'b1 :
      (is_branch == 1'b1) ?
      branch_condition_satisfied :
      1'b0;

  //-----------------------------------------------------------------------------------------------//
  // Integer File implementation                                                                   //
  //-----------------------------------------------------------------------------------------------//

  assign integer_file_write_enable =
    integer_file_write_request_stage3 & !flush_pipeline;

  integer i;
  always @(posedge clock) begin
    if (reset)
      for (i = 1; i < 32; i = i + 1) integer_file[i] <= 32'b0;
    else if (clock_enable & integer_file_write_enable)
      integer_file[instruction_rd_address_stage3] <= writeback_multiplexer_output;
  end

  assign rs1_mux =
    instruction_rs1_address == instruction_rd_address_stage3 & integer_file_write_enable ?
    writeback_multiplexer_output :
    integer_file[instruction_rs1_address];

  assign rs2_mux =
    instruction_rs2_address == instruction_rd_address_stage3 & integer_file_write_enable ?
    writeback_multiplexer_output :
    integer_file[instruction_rs2_address];

  assign rs1_data =
    instruction_rs1_address == 5'b00000 ?
    32'h00000000 :
    rs1_mux;
  
  assign rs2_data =
    instruction_rs2_address == 5'b00000 ?
    32'h00000000 :
    rs2_mux;

  //---------------------------------------------------------------------------------------------//
  // M-mode logic and hart control                                                               //
  //---------------------------------------------------------------------------------------------//

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
    else if (clock_enable)
      current_state <= next_state;
  end

  always @* begin : program_counter_source_mux
    case (current_state)
      STATE_RESET:
        program_counter_source = PC_BOOT;
      STATE_OPERATING:
        program_counter_source = PC_NEXT;
      STATE_TRAP_TAKEN:
        program_counter_source = PC_TRAP;
      STATE_TRAP_RETURN:
        program_counter_source = PC_EPC;
      default:
        program_counter_source = PC_NEXT;
    endcase
  end

  assign irq_external_ack =
    (current_state      == STATE_TRAP_TAKEN) &&
    (mcause_cause_code  == 4'b1011);
  
  assign irq_timer_ack =
    (current_state      == STATE_TRAP_TAKEN) &&
    (mcause_cause_code  == 4'b0111);

  assign irq_software_ack =
    (current_state      == STATE_TRAP_TAKEN) &&
    (mcause_cause_code  == 4'b0011);

  //---------------------------------------------------------------------------------------------//
  // Control and Status Registers implementation                                                 //
  //---------------------------------------------------------------------------------------------//

  assign csr_data_mask =
    csr_operation_stage3[2] == 1'b1 ?
    {27'b0, immediate_stage3[4:0]} :
    rs1_data_stage3;

  always @* begin : csr_write_data_mux
    case (csr_operation_stage3[1:0])
      CSR_RWX:
        csr_write_data = csr_data_mask;
      CSR_RSX:
        csr_write_data = csr_data_out |  csr_data_mask;
      CSR_RCX:
        csr_write_data = csr_data_out & ~csr_data_mask;
      default:
        csr_write_data = csr_data_out;
    endcase
  end

  always @* begin : csr_data_out_mux
    case (instruction_csr_address_stage3)
      MARCHID:       csr_data_out = 32'h00000018; // RISC-V Steel microarchitecture ID
      MIMPID:        csr_data_out = 32'h00000005; // Version 5 
      CYCLE:         csr_data_out = mcycle    [31:0 ];
      CYCLEH:        csr_data_out = mcycle    [63:32];
      TIME:          csr_data_out = utime     [31:0 ];
      TIMEH:         csr_data_out = utime     [63:32];
      INSTRET:       csr_data_out = minstret  [31:0 ];
      INSTRETH:      csr_data_out = minstret  [63:32];
      MSTATUS:       csr_data_out = mstatus;
      MSTATUSH:      csr_data_out = 32'h00000000;
      MISA:          csr_data_out = 32'h40000100; // RV32I base ISA only
      MIE:           csr_data_out = mie;
      MTVEC:         csr_data_out = mtvec;
      MSCRATCH:      csr_data_out = mscratch;
      MEPC:          csr_data_out = mepc;
      MCAUSE:        csr_data_out = mcause;
      MTVAL:         csr_data_out = mtval;
      MIP:           csr_data_out = mip;
      MCYCLE:        csr_data_out = mcycle    [31:0 ];
      MCYCLEH:       csr_data_out = mcycle    [63:32];
      MINSTRET:      csr_data_out = minstret  [31:0 ];
      MINSTRETH:     csr_data_out = minstret  [63:32];
      default:       csr_data_out = 32'h00000000;
    endcase
  end

  assign csr_file_write_enable =
    csr_file_write_request_stage3 & !flush_pipeline;

  assign misaligned_instruction_address =
    take_branch & next_address[1];

  //---------------------------------------------------------------------------------------------//
  // mstatus : M-mode Status register                                                            //
  //---------------------------------------------------------------------------------------------//

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
    else if (clock_enable) begin
      if(current_state == STATE_TRAP_RETURN) begin
        mstatus_mie   <= mstatus_mpie;
        mstatus_mpie  <= 1'b1;
      end
      else if(current_state == STATE_TRAP_TAKEN) begin
        mstatus_mpie  <= mstatus_mie;
        mstatus_mie   <= 1'b0;
      end
      else if(current_state == STATE_OPERATING && instruction_csr_address_stage3 == MSTATUS && csr_file_write_enable) begin
        mstatus_mie   <= csr_write_data[3];
        mstatus_mpie  <= csr_write_data[7];
      end    
    end
  end

  //---------------------------------------------------------------------------------------------//
  // mie : M-mode Interrupt Enable register                                                      //
  //---------------------------------------------------------------------------------------------//

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
    else if(clock_enable & instruction_csr_address_stage3 == MIE && csr_file_write_enable) begin            
      mie_meie <= csr_write_data[11];
      mie_mtie <= csr_write_data[7];
      mie_msie <= csr_write_data[3];
    end
  end
  
  //---------------------------------------------------------------------------------------------//
  // mip : M-mode Interrupt Pending                                                              //
  //---------------------------------------------------------------------------------------------//

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
    else if (clock_enable) begin
      mip_meip <= irq_external;
      mip_mtip <= irq_timer;
      mip_msip <= irq_software;
    end
  end
  
  //---------------------------------------------------------------------------------------------//
  // mepc : M-mode Exception Program Counter register                                            //
  //---------------------------------------------------------------------------------------------//

  assign exception_program_counter =
    mepc;

  always @(posedge clock) begin : mepc_implementation
    if(reset)
      mepc <= 32'b0;
    else if (clock_enable) begin
      if(current_state == STATE_TRAP_TAKEN)
        mepc <= program_counter_stage3;
      else if(current_state == STATE_OPERATING && instruction_csr_address_stage3 == MEPC && csr_file_write_enable)
        mepc <= {csr_write_data[31:2], 2'b00};
    end    
  end
  
  //---------------------------------------------------------------------------------------------//
  // mscratch : M-mode Scratch register                                                          //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if(reset)
      mscratch <= 32'b0;
    else if(clock_enable & instruction_csr_address_stage3 == MSCRATCH && csr_file_write_enable)
      mscratch <= csr_write_data;
  end
  
  //---------------------------------------------------------------------------------------------//
  // mcycle : M-mode Cycle Counter register                                                      //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin : mcycle_implementation
    if (reset)
      mcycle <= 64'b0;
    else begin 
      if (clock_enable & instruction_csr_address_stage3 == MCYCLE && csr_file_write_enable)
        mcycle <= {mcycle[63:32], csr_write_data} + 1;
      else if (clock_enable & instruction_csr_address_stage3 == MCYCLEH && csr_file_write_enable)
        mcycle <= {csr_write_data, mcycle[31:0]} + 1;
      else
        mcycle <= mcycle + 1;      
    end
  end
  
  //---------------------------------------------------------------------------------------------//
  // minstret : M-mode Instruction Retired Counter register                                      //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin : minstret_implementation
    if (reset)
      minstret  <= 64'b0;
    else if (clock_enable) begin 
      if (instruction_csr_address_stage3 == MINSTRET && csr_file_write_enable) begin
        if (current_state == STATE_OPERATING)
          minstret <= {minstret[63:32], csr_write_data} + 1;
        else
          minstret <= {minstret[63:32], csr_write_data};
      end
      else if (instruction_csr_address_stage3 == MINSTRETH && csr_file_write_enable) begin
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
  
  //---------------------------------------------------------------------------------------------//
  // utime : Time register (Read-only shadow of mtime)                                           //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin : utime_csr_implementation
    utime <= real_time;
  end
  
  //---------------------------------------------------------------------------------------------//
  // mcause : M-mode Trap Cause register                                                         //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin : mcause_implementation
    if(reset) 
      mcause <= 32'h00000000;
    else if (clock_enable) begin
      if(current_state == STATE_TRAP_TAKEN)
        mcause <= {mcause_interrupt_flag, 27'b0, mcause_cause_code};
      else if(current_state == STATE_OPERATING && instruction_csr_address_stage3 == MCAUSE && csr_file_write_enable) 
        mcause <= csr_write_data;
    end
  end

  always @(posedge clock) begin : trap_cause_implementation
    if(reset) begin
      mcause_cause_code       <= 4'b0;
      mcause_interrupt_flag   <= 1'b0;
    end
    if(clock_enable & current_state == STATE_OPERATING) begin 
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
  
  //---------------------------------------------------------------------------------------------//
  // mtval : M-mode Trap Value                                                                   //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if (reset)
      misaligned_address_exception <= 1'b0;
    else if (clock_enable)
      misaligned_address_exception <= misaligned_load | misaligned_store | misaligned_instruction_address;
  end

  always @(posedge clock) begin : mtval_implementation
    if(reset) 
      mtval <= 32'h00000000;
    else if (clock_enable) begin
      if(current_state == STATE_TRAP_TAKEN) begin
        if(misaligned_address_exception)
          mtval <= target_address_adder_stage3;
        else
          mtval <= 32'h00000000;
      end
      else if(current_state == STATE_OPERATING && instruction_csr_address_stage3 == MTVAL && csr_file_write_enable) 
        mtval <= csr_write_data;
    end
  end
  
  //---------------------------------------------------------------------------------------------//
  // mtvec : M-mode Trap Vector Address register                                                 //
  //---------------------------------------------------------------------------------------------//
 
  assign base_address_offset =
    mcause_cause_code << 2;

  assign trap_address = 
    mtvec[1:0] == 2'b01 && mcause_interrupt_flag ?
    {mtvec[31:2], 2'b00} + base_address_offset :
    {mtvec[31:2], 2'b00};

  always @(posedge clock) begin : mtvec_implementation
    if(reset)
      mtvec <= 32'b0;
    else if(clock_enable & instruction_csr_address_stage3 == MTVEC && csr_file_write_enable)
      mtvec <= {csr_write_data[31:2], 1'b0, csr_write_data[0]};
  end

  //---------------------------------------------------------------------------------------------//
  // Pipelining registers from stage 2 => 3                                                      //
  //---------------------------------------------------------------------------------------------//

  always @(posedge clock) begin
    if (reset) begin
      instruction_rd_address_stage3     <= 5'b00000;
      instruction_csr_address_stage3    <= 12'b000000000000;
      rs1_data_stage3                   <= 32'h00000000;
      rs2_data_stage3                   <= 32'h00000000;
      program_counter_stage3            <= BOOT_ADDRESS;
      program_counter_plus_4_stage3     <= 32'h00000000;
      target_address_adder_stage3       <= 32'h00000000;
      alu_operation_code_stage3         <= 4'b0000;
      load_size_stage3                  <= 2'b00;
      load_unsigned_stage3              <= 1'b0;
      alu_2nd_operand_source_stage3     <= 1'b0;
      csr_file_write_request_stage3      <= 1'b0;
      integer_file_write_request_stage3  <= 1'b0;
      writeback_mux_selector_stage3     <= WB_ALU;
      csr_operation_stage3              <= 3'b000;
      immediate_stage3                  <= 32'h00000000;
    end
    else if (clock_enable) begin
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
      csr_file_write_request_stage3     <= csr_file_write_request;
      integer_file_write_request_stage3 <= integer_file_write_request;
      writeback_mux_selector_stage3     <= writeback_mux_selector;
      csr_operation_stage3              <= csr_operation;
      immediate_stage3                  <= immediate;
    end
  end    

  //---------------------------------------------------------------------------------------------//
  // Integer register file writeback selection                                                   //
  //---------------------------------------------------------------------------------------------//

  always @* begin
    case (writeback_mux_selector_stage3)
      WB_ALU:          writeback_multiplexer_output = alu_output;
      WB_LOAD_UNIT:    writeback_multiplexer_output = load_data;
      WB_UPPER_IMM:    writeback_multiplexer_output = immediate_stage3;
      WB_TARGET_ADDER: writeback_multiplexer_output = target_address_adder_stage3;
      WB_CSR:          writeback_multiplexer_output = csr_data_out;
      WB_PC_PLUS_4:    writeback_multiplexer_output = program_counter_plus_4_stage3;
      default:         writeback_multiplexer_output = alu_output;
    endcase
  end

  //-----------------------------------------------------------------------------------------------//
  // Load data logic                                                                               //
  //-----------------------------------------------------------------------------------------------//
    
  always @* begin : load_size_mux
    case (load_size_stage3)
      LOAD_SIZE_BYTE:
        load_data = {byte_data_upper_bits, load_byte_data};
      LOAD_SIZE_HALF:
        load_data = {half_data_upper_bits, load_half_data};
      LOAD_SIZE_WORD:
        load_data = data_in;
      default:
        load_data = data_in;
    endcase
  end
    
  always @* begin : load_byte_data_mux
    case (target_address_adder_stage3[1:0])    
      2'b00:
        load_byte_data = data_in[7:0];
      2'b01:
        load_byte_data = data_in[15:8];
      2'b10:
        load_byte_data = data_in[23:16];
      2'b11:
        load_byte_data = data_in[31:24];
    endcase
  end
    
  always @* begin : load_half_data_mux
    case (target_address_adder_stage3[1])
      1'b0:
        load_half_data = data_in[15:0];
      1'b1:
        load_half_data = data_in[31:16];
    endcase
  end
    
  assign byte_data_upper_bits =
    load_unsigned_stage3 == 1'b1 ?
    24'b0 :
    {24{load_byte_data[7]}};
  
  assign half_data_upper_bits =
    load_unsigned_stage3 == 1'b1 ?
    16'b0 :
    {16{load_half_data[15]}};
    
  //-----------------------------------------------------------------------------------------------//
  // Arithmetic and Logic Unit                                                                     //
  //-----------------------------------------------------------------------------------------------//
  
  assign alu_2nd_operand =
    alu_2nd_operand_source_stage3 ?
    rs2_data_stage3 :
    immediate_stage3;

  assign minus_second_operand = 
    - alu_2nd_operand;

  assign adder_second_operand_mux = 
    alu_operation_code_stage3[3] == 1'b1 ?
    minus_second_operand : 
    alu_2nd_operand;

  assign alu_sra_result = 
    $signed(rs1_data_stage3) >>> alu_2nd_operand[4:0];

  assign alu_srl_result = 
    rs1_data_stage3 >> alu_2nd_operand[4:0];

  assign shift_right_mux = 
    alu_operation_code_stage3[3] == 1'b1 ?
    alu_sra_result : 
    alu_srl_result;

  assign alu_sltu_result = 
    rs1_data_stage3 < alu_2nd_operand;

  assign alu_slt_result =
    rs1_data_stage3[31] ^ alu_2nd_operand[31] ?
    rs1_data_stage3[31] :
    alu_sltu_result;

  always @* begin : operation_result_mux
    case (alu_operation_code_stage3[2:0])
      FUNCT3_ADD:
        alu_output =
          rs1_data_stage3 + adder_second_operand_mux;
      FUNCT3_SRL:
        alu_output =
          shift_right_mux;
      FUNCT3_OR: 
        alu_output = 
          rs1_data_stage3 | alu_2nd_operand;
      FUNCT3_AND: 
        alu_output = 
          rs1_data_stage3 & alu_2nd_operand;            
      FUNCT3_XOR: 
        alu_output = 
          rs1_data_stage3 ^ alu_2nd_operand;
      FUNCT3_SLT: 
        alu_output = 
          {31'b0, alu_slt_result};
      FUNCT3_SLTU: 
        alu_output = 
          {31'b0, alu_sltu_result};
      FUNCT3_SLL: 
        alu_output = 
          rs1_data_stage3 << alu_2nd_operand[4:0];
    endcase
  end
    
endmodule