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

Top Module:    riscv_steel_core_axi_wrapper
 
**************************************************************************************************/

module riscv_steel_core_axi_wrapper #(
  
  parameter BOOT_ADDRESS = 32'h00000000

  ) (

  // Global system signals

  input   wire          clock,
  input   wire          reset_n,

  // Interrupt signals (hardwire inputs to zero if unused)

  input  wire           irq_external,
  output wire           irq_external_ack,
  input  wire           irq_timer,
  output wire           irq_timer_ack,
  input  wire           irq_software,  
  output wire           irq_software_ack,

  // Real Time Counter (hardwire to zero if unused)

  input  wire   [63:0]  real_time,

  // AXI4-Lite Master Interface

  input   wire          axi_awready,
  output  wire          axi_awvalid,
  output  wire  [31:0]  axi_awaddr,
  output  wire  [2:0 ]  axi_awprot,

  input   wire          axi_arready,
  output  wire          axi_arvalid,
  output  wire  [31:0]  axi_araddr,
  output  wire  [2:0 ]  axi_arprot,

  input   wire          axi_wready,
  output  wire          axi_wvalid,
  output  wire  [31:0]  axi_wdata,
  output  wire  [3:0 ]  axi_wstrb,

  output  wire          axi_bready,
  input   wire          axi_bvalid,
  input   wire  [1:0]   axi_bresp,

  output  wire          axi_rready,
  input   wire          axi_rvalid,
  input   wire  [31:0]  axi_rdata,
  input   wire  [1:0 ]  axi_rresp

);

  //-----------------------------------------------------------------------------------------------//
  // Wires and regs                                                                                //
  //-----------------------------------------------------------------------------------------------//

  reg           axi_read_address_ack;
  wire          axi_read_response_pending;
  wire          axi_read_transaction_completed;
  reg           axi_write_address_ack;  
  reg           axi_write_data_ack;
  wire          axi_write_transaction_completed;
  reg   [31:0]  data_in;
  wire  [31:0]  data_out;
  reg           data_r_valid;
  wire          data_read_request;
  wire  [31:0]  data_rw_address;
  wire          data_rw_address_valid;
  wire          data_rw_valid;
  reg           data_w_valid;
  wire          data_write_request;
  wire  [3:0 ]  data_write_strobe;
  reg           double_read_request_started;
  wire  [31:0]  instruction_address;
  wire          instruction_address_valid;
  wire  [31:0]  instruction_in;
  wire          instruction_in_valid;
  wire          load_completed;
  wire          load_pending;
  reg           reset;
  wire          write_pending;

  always @(posedge clock) reset <= !reset_n;

  //-----------------------------------------------------------------------------------------------//
  // Read interface signals                                                                        //
  //-----------------------------------------------------------------------------------------------//

  assign axi_araddr =
    instruction_address_valid & data_read_request & !load_completed ?
    data_rw_address :
    instruction_address;
  
  assign axi_arprot =
    instruction_address_valid & data_read_request & !load_completed ?
    3'b000 :
    3'b100;

  assign axi_arvalid =
    reset_n & !reset & !axi_read_response_pending;

  assign axi_rready =
    reset_n & !reset & axi_read_address_ack;

  //-----------------------------------------------------------------------------------------------//
  // Write interface signals                                                                       //
  //-----------------------------------------------------------------------------------------------//

  assign axi_awvalid =
    reset_n & !reset & data_rw_address_valid & data_write_request & !(axi_write_address_ack | data_w_valid);

  assign axi_awaddr =
    data_rw_address;

  assign axi_awprot =
    3'b000;

  assign axi_wvalid =
    reset_n & !reset & data_rw_address_valid & data_write_request & !(axi_write_data_ack | data_w_valid);

  assign axi_wdata =
    data_out;

  assign axi_wstrb =
    data_write_strobe;

  assign axi_bready =
    reset_n & !reset;
  
  //-----------------------------------------------------------------------------------------------//
  // Read interface internals                                                                      //
  //-----------------------------------------------------------------------------------------------//
  
  assign data_read_request =
    data_rw_address_valid & !data_write_request;
  
  assign load_pending =
    double_read_request_started & !data_r_valid;

  assign load_completed =
    data_r_valid | (double_read_request_started & data_read_request & axi_read_transaction_completed);
  
  always @(posedge clock) begin
    if (reset)
      axi_read_address_ack <= 1'b0;
    else if (axi_arvalid & axi_arready)
      axi_read_address_ack <= 1'b1;
    else if (axi_read_transaction_completed)
      axi_read_address_ack <= 1'b0;
    else
      axi_read_address_ack <= axi_read_address_ack;
  end

  always @(posedge clock) begin
    if (reset)
      double_read_request_started <= 1'b0;
    else if (!double_read_request_started & instruction_address_valid & data_read_request)
      double_read_request_started <= 1'b1;
    else if (double_read_request_started & data_r_valid)
      double_read_request_started <= 1'b0;
    else
      double_read_request_started <= double_read_request_started;
  end  

  //-----------------------------------------------------------------------------------------------//
  // Write interface internals                                                                     //
  //-----------------------------------------------------------------------------------------------//

  assign axi_write_transaction_completed =
    axi_bvalid & axi_bready & (axi_bresp == 2'b00);

  always @(posedge clock) begin
    if (reset)
      axi_write_address_ack <= 1'b0;
    else if (axi_awvalid & axi_awready)
      axi_write_address_ack <= 1'b1;
    else if (axi_write_transaction_completed)
      axi_write_address_ack <= 1'b0;
    else
      axi_write_address_ack <= axi_write_address_ack;
  end

  always @(posedge clock) begin
    if (reset)
      axi_write_data_ack <= 1'b0;
    else if (axi_awvalid & axi_awready)
      axi_write_data_ack <= 1'b1;
    else if (axi_write_transaction_completed)
      axi_write_data_ack <= 1'b0;
    else
      axi_write_data_ack <= axi_write_data_ack;
  end  

  //-----------------------------------------------------------------------------------------------//
  // RISC-V Steel Native Interface <=> AXI4-Lite translation                                       //
  //-----------------------------------------------------------------------------------------------//

  assign instruction_in =
    axi_rdata;

  assign instruction_in_valid =
    !load_pending & axi_read_transaction_completed & !(data_write_request & !data_w_valid);

  assign data_rw_valid =
    data_write_request ? data_w_valid : data_r_valid;

  assign axi_read_response_pending =
    axi_read_address_ack & !axi_read_transaction_completed;

  assign axi_read_transaction_completed =
    axi_rvalid & axi_rready & (axi_rresp == 2'b00);

  always @(posedge clock) begin
    if (reset | (data_w_valid & instruction_in_valid))
      data_w_valid <= 1'b0;
    else if (axi_write_address_ack & axi_write_data_ack & axi_write_transaction_completed) 
      data_w_valid <= 1'b1;
    else
      data_w_valid <= data_w_valid;
  end

  always @(posedge clock) begin
    if (reset | (data_r_valid & instruction_in_valid)) begin
      data_in <= 32'h00000000;
      data_r_valid <= 1'b0;
    end
    else if (double_read_request_started & data_read_request & axi_read_transaction_completed) begin
      data_in <= axi_rdata;
      data_r_valid <= 1'b1;
    end
    else begin
      data_in <= data_in;
      data_r_valid <= data_r_valid;
    end
  end

  //-----------------------------------------------------------------------------------------------//
  // RISC-V Steel instantitation                                                                   //
  //-----------------------------------------------------------------------------------------------//

  riscv_steel_core #(
    
    .BOOT_ADDRESS               (BOOT_ADDRESS               )

  ) riscv_steel_core_instance (

    // Basic system signals
    .clock                      (clock                      ),
    .reset_n                    (reset_n                    ),

    // Instruction fetch interface
    .instruction_address        (instruction_address        ),
    .instruction_address_valid  (instruction_address_valid  ),
    .instruction_in             (instruction_in             ),
    .instruction_in_valid       (instruction_in_valid       ),
      
    // Data read/write interface
    .data_rw_address            (data_rw_address            ),
    .data_rw_address_valid      (data_rw_address_valid      ),
    .data_out                   (data_out                   ),
    .data_write_request         (data_write_request         ),
    .data_write_strobe          (data_write_strobe          ),
    .data_in                    (data_in                    ),
    .data_rw_valid              (data_rw_valid              ),
    
    // Interrupt signals (inputs hardwired to zero because they're not needed now)
    .irq_external               (irq_external               ),
    .irq_timer                  (irq_timer                  ),
    .irq_software               (irq_software               ),
    .irq_external_ack           (irq_external_ack           ),
    .irq_timer_ack              (irq_timer_ack              ),
    .irq_software_ack           (irq_software_ack           ),

    // Real Time Counter (hardwired to zero because they're not needed too)
    .real_time                  (real_time                  )

  );

endmodule