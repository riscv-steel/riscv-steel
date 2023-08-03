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

Project Name:  RISC-V Steel Core / Hello World example
Project Repo:  github.com/riscv-steel/riscv-steel-core
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    hello_world
 
**************************************************************************************************/

module hello_world (

  input   wire clock,
  input   wire reset,
  input   wire uart_rx,
  output  wire uart_tx

  );
  
  reg         internal_clock;
  wire        irq_external;
  wire        irq_external_ack;

  // RISC-V Steel Core (instruction interface) <=> RAM (device #0, port #0)
  wire [31:0] bus_instruction_address;
  wire        bus_instruction_request;
  wire [31:0] bus_instruction_in;
  wire        bus_instruction_request_ack;

  // RISC-V Steel Core (data interface) <=> Memory Mapper
  wire [31:0] bus_data_rw_address;
  wire        bus_data_rw_address_valid;
  wire [31:0] bus_data_wdata;
  wire [31:0] bus_data_rdata;
  wire [3:0 ] bus_data_write_strobe;
  wire        bus_data_write_request;
  wire        bus_data_rw_valid;
  
  // Memory Mapper <=> RAM (device #0, port #1)
  wire [31:0] device0_rw_address;
  wire        device0_rw_address_valid;
  wire [31:0] device0_wdata;
  wire [31:0] device0_rdata;
  wire [3:0 ] device0_write_strobe;
  wire        device0_write_request;
  wire        device0_rw_valid;
  
  // Memory Mapper <=> UART (device #1)
  wire [31:0] device1_rw_address;
  wire        device1_rw_address_valid;
  wire [31:0] device1_wdata;
  wire [31:0] device1_rdata;
  wire [3:0 ] device1_write_strobe;
  wire        device1_write_request;
  wire        device1_rw_valid;

  always @(posedge clock)
    internal_clock <= !internal_clock;

  riscv_steel_core
  riscv_steel_core_instance (

    // Basic system signals
    .clock                        (internal_clock                     ),
    .reset_n                      (!reset                             ),

    // Instruction fetch interface
    .instruction_address          (bus_instruction_address            ),
    .instruction_request          (bus_instruction_request            ),
    .instruction_in               (bus_instruction_in                 ),
    .instruction_request_ack      (bus_instruction_request_ack        ),

    // Data fetch/write interface
    .data_rw_address              (bus_data_rw_address                ),
    .data_rw_address_valid        (bus_data_rw_address_valid          ),
    .data_out                     (bus_data_wdata                     ),
    .data_write_request           (bus_data_write_request             ),
    .data_write_strobe            (bus_data_write_strobe              ),
    .data_in                      (bus_data_rdata                     ),
    .data_rw_valid                (bus_data_rw_valid                  ),

    // Interrupt signals (hardwire inputs to zero if unused)
    .irq_external                 (irq_external                       ),
    .irq_external_ack             (irq_external_ack                   ),
    .irq_timer                    (0), // unused
    .irq_timer_ack                (),  // unused
    .irq_software                 (0), // unused
    .irq_software_ack             (),  // unused

    // Real Time Counter (hardwire to zero if unused)
    .real_time                    (0)  // unused

  );
  
  memory_mapper
  memory_mapper_instance        (
  
    .clock                      (internal_clock             ),

    // Connected to RISC-V Steel
    .bus_data_rdata             (bus_data_rdata             ),
    .bus_data_rw_address        (bus_data_rw_address        ),
    .bus_data_rw_address_valid  (bus_data_rw_address_valid  ),
    .bus_data_wdata             (bus_data_wdata             ),  
    .bus_data_write_strobe      (bus_data_write_strobe      ),
    .bus_data_write_request     (bus_data_write_request     ),
    .bus_data_rw_valid          (bus_data_rw_valid          ),
    
    // Connected to Device 0 => Memory
    .device0_rdata              (device0_rdata              ),
    .device0_rw_address         (device0_rw_address         ),
    .device0_rw_address_valid   (device0_rw_address_valid   ),
    .device0_wdata              (device0_wdata              ),  
    .device0_write_strobe       (device0_write_strobe       ),
    .device0_write_request      (device0_write_request      ),
    .device0_rw_valid           (device0_rw_valid           ),
    
    // Connected to Device 1 => UART
    .device1_rdata              (device1_rdata              ),
    .device1_rw_address         (device1_rw_address         ),
    .device1_rw_address_valid   (device1_rw_address_valid   ),
    .device1_wdata              (device1_wdata              ),
    .device1_write_strobe       (device1_write_strobe       ),
    .device1_write_request      (device1_write_request      ),
    .device1_rw_valid           (device1_rw_valid           )

  );
  
  dual_port_ram
  dual_port_ram_instance    (
    .clock                  (internal_clock                     ),
    .resetn                 (!reset                             ),
    .port0_address          (bus_instruction_address[13:0]      ),
    .port0_address_valid    (bus_instruction_request            ),
    .port0_data_out         (bus_instruction_in                 ),
    .port0_data_out_valid   (bus_instruction_request_ack        ),
    .port1_address          (device0_rw_address[13:0]           ),
    .port1_address_valid    (device0_rw_address_valid           ),
    .port1_data_out         (device0_rdata                      ),
    .port1_rw_valid         (device0_rw_valid                   ),
    .port1_data_in          (device0_wdata                      ),
    .port1_write_strobe     (device0_write_strobe               ),
    .port1_write_enable     (device0_write_request              )
  );

  uart
  uart_instance             (
    .clock                  (internal_clock                 ),
    .resetn                 (!reset                         ),
    .uart_rw_address        (device1_rw_address             ),
    .uart_rw_address_valid  (device1_rw_address_valid       ),
    .uart_wdata             (device1_wdata[7:0]             ),
    .uart_write_request     (device1_write_request          ),
    .uart_rdata             (device1_rdata                  ),
    .uart_rw_valid          (device1_rw_valid               ),
    .uart_tx                (uart_tx                        ),
    .uart_rx                (uart_rx                        ),
    .uart_irq               (irq_external                   ),
    .uart_irq_ack           (irq_external_ack               )
  );

endmodule

module memory_mapper (

  input   wire       clock,

  // Bus connected to RISC-V Steel
  output  reg  [31:0] bus_data_rdata,
  input   wire [31:0] bus_data_rw_address,
  input   wire        bus_data_rw_address_valid,
  input   wire [31:0] bus_data_wdata,  
  input   wire [3:0 ] bus_data_write_strobe,
  input   wire        bus_data_write_request,
  output  reg         bus_data_rw_valid,
  
  // Connected to Device 0 => Memory
  input   wire [31:0] device0_rdata,
  output  reg  [31:0] device0_rw_address,
  output  reg         device0_rw_address_valid,
  output  reg  [31:0] device0_wdata,  
  output  reg  [3:0 ] device0_write_strobe,
  output  reg         device0_write_request,
  input   wire        device0_rw_valid,
  
  // Connected to Device 1 => UART
  input   wire [31:0] device1_rdata,
  output  reg  [31:0] device1_rw_address,
  output  reg         device1_rw_address_valid,
  output  reg  [31:0] device1_wdata,
  output  reg  [3:0 ] device1_write_strobe,
  output  reg         device1_write_request,
  input   wire        device1_rw_valid

  );
  
  reg [31:0] prev_bus_data_rw_address;
  
  always @(posedge clock)
    prev_bus_data_rw_address <= bus_data_rw_address;
  
  always @* begin
    if (prev_bus_data_rw_address < 32'h00010000 || prev_bus_data_rw_address > 32'h0001ffff) begin
      bus_data_rdata <= device0_rdata;
      bus_data_rw_valid <= device0_rw_valid;
    end
    else begin
      bus_data_rdata <= device1_rdata;
      bus_data_rw_valid <= device1_rw_valid;
    end
  end
  
  always @* begin
    if (bus_data_rw_address < 32'h00010000 || bus_data_rw_address > 32'h0001ffff) begin
      device0_rw_address        <= bus_data_rw_address;
      device0_rw_address_valid  <= bus_data_rw_address_valid;
      device0_wdata             <= bus_data_wdata;
      device0_write_strobe      <= bus_data_write_strobe;
      device0_write_request     <= bus_data_write_request;
    end
    else begin
      device0_rw_address        <= 32'h00000000;
      device0_rw_address_valid  <= 1'b0;
      device0_wdata             <= 32'h00000000;
      device0_write_strobe      <= 4'h0;
      device0_write_request     <= 1'b0;
    end
  end
  
  always @* begin
    if (bus_data_rw_address >= 32'h00010000 && bus_data_rw_address <= 32'h0001ffff) begin
      device1_rw_address        <= bus_data_rw_address;
      device1_rw_address_valid  <= bus_data_rw_address_valid;
      device1_wdata             <= bus_data_wdata;
      device1_write_strobe      <= bus_data_write_strobe;
      device1_write_request     <= bus_data_write_request;
    end
    else begin
      device1_rw_address        <= 32'h00000000;
      device1_rw_address_valid  <= 1'b0;
      device1_wdata             <= 32'h00000000;
      device1_write_strobe      <= 4'h0;
      device1_write_request     <= 1'b0;
    end
  end

endmodule

module dual_port_ram (

  input   wire clock,
  input   wire resetn,

  // Port 0 is read-only (used for instruction fetch)
  input   wire [13:0] port0_address,  // 14-bit addresses = 16 KB memory
  input   wire        port0_address_valid,
  output  reg  [31:0] port0_data_out,
  output  reg         port0_data_out_valid,

  // Port 1 is read/write capable
  input   wire [13:0] port1_address,  // 14-bit addresses = 16 KB memory
  input   wire        port1_address_valid,
  output  reg  [31:0] port1_data_out,
  output  reg         port1_rw_valid,
  input   wire [31:0] port1_data_in,
  input   wire [3:0 ] port1_write_strobe,
  input   wire        port1_write_enable

  );

  // We will make the RAM word-addressed
  reg [31:0] ram [0:4095];

  // Loads the program into the RAM
  initial $readmemh("hello-world.mem", ram);

  // Because we made the RAM word-addressed, we need to shift the last two bits
  wire [11:0] instruction_address = port0_address >> 2;
  wire [11:0] data_address        = port1_address >> 2;
  
  // The code below will be synthesized to a Block RAM
  always @(posedge clock) begin 
    if (port1_write_enable == 1'b1) begin
      if(port1_write_strobe[0]) ram[data_address][7:0  ] <= port1_data_in[7:0  ];
      if(port1_write_strobe[1]) ram[data_address][15:8 ] <= port1_data_in[15:8 ];
      if(port1_write_strobe[2]) ram[data_address][23:16] <= port1_data_in[23:16];
      if(port1_write_strobe[3]) ram[data_address][31:24] <= port1_data_in[31:24];
    end
  end

  // Instruction / data fetch
  always @(posedge clock) begin
    if (!resetn) begin
      port0_data_out <= 32'h00000000;
      port1_data_out <= 32'h00000000;
      port0_data_out_valid <= 1'b0;
      port1_rw_valid <= 1'b0;
    end
    else begin
      port0_data_out <= ram[instruction_address];
      port1_data_out <= ram[data_address];
      port0_data_out_valid <= port0_address_valid;
      port1_rw_valid <= port1_address_valid;
    end
  end

endmodule

module uart #(

  parameter clock_freq = 50000000,
  parameter baud_rate  = 9600

  )(

  input   wire        clock,
  input   wire        resetn,
  input   wire [31:0] uart_rw_address,
  input   wire        uart_rw_address_valid,
  input   wire [7:0 ] uart_wdata,
  input   wire        uart_write_request,
  input   wire        uart_rx,
  output  wire        uart_tx,
  output  reg  [31:0] uart_rdata,  
  output  reg         uart_rw_valid,
  output  reg         uart_irq,
  input   wire        uart_irq_ack
    
  );

  localparam cycles_per_baud = clock_freq / baud_rate;
  
  reg [$clog2(cycles_per_baud):0] tx_cycle_counter = 0;
  reg [$clog2(cycles_per_baud):0] rx_cycle_counter = 0;
  reg [3:0] tx_bit_counter;
  reg [3:0] rx_bit_counter;
  reg [9:0] tx_register;
  reg [7:0] rx_register;
  reg [7:0] rx_data;
  reg       rx_active;
  
  assign uart_tx = tx_register[0];
  
  always @(posedge clock) begin
    if (!resetn) begin
      tx_cycle_counter <= 0;
      tx_register <= 10'b1111111111;
      tx_bit_counter <= 0;
    end
    else if (tx_bit_counter == 0 &&
             uart_rw_address == 32'h00010000 &&
             uart_write_request == 1'b1) begin
      tx_cycle_counter <= 0;
      tx_register <= {1'b1, uart_wdata, 1'b0};
      tx_bit_counter <= 10;
    end
    else begin
      if (tx_cycle_counter < cycles_per_baud) begin
        tx_cycle_counter <= tx_cycle_counter + 1;
        tx_register <= tx_register;
        tx_bit_counter <= tx_bit_counter;
      end
      else begin
        tx_cycle_counter <= 0;
        tx_register <= {1'b1, tx_register[9:1]};
        tx_bit_counter <= tx_bit_counter > 0 ? tx_bit_counter - 1 : 0;
      end
    end
  end
  
  always @(posedge clock) begin
    if (!resetn) begin
      rx_cycle_counter <= 0;
      rx_register <= 8'h00;
      rx_data <= 8'h00;
      rx_bit_counter <= 0;
      uart_irq <= 1'b0;
      rx_active <= 1'b0;
    end
    else if (uart_irq == 1'b1) begin
      if (uart_rw_address == 32'h00010004 || uart_irq_ack == 1'b1) begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b0;
        rx_active <= 1'b0;
      end
      else begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b1;
        rx_active <= 1'b0;
      end
    end
    else if (rx_bit_counter == 0 && rx_active == 1'b0) begin
      if (uart_rx == 1'b1) begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b0;
        rx_active <= 1'b0;
      end
      else if (uart_rx == 1'b0) begin
        if (rx_cycle_counter < cycles_per_baud / 2) begin
          rx_cycle_counter <= rx_cycle_counter + 1;
          rx_register <= 8'h00;
          rx_data <= rx_data;
          rx_bit_counter <= 0;
          uart_irq <= 1'b0;
          rx_active <= 1'b0;
        end
        else begin
          rx_cycle_counter <= 0;
          rx_register <= 8'h00;
          rx_data <= rx_data;
          rx_bit_counter <= 8;
          uart_irq <= 1'b0;
          rx_active <= 1'b1;
        end
      end
    end
    else begin      
      if (rx_cycle_counter < cycles_per_baud) begin
        rx_cycle_counter <= rx_cycle_counter + 1;
        rx_register <= rx_register;
        rx_data <= rx_data;
        rx_bit_counter <= rx_bit_counter;
        uart_irq <= 1'b0;
        rx_active <= 1'b1;
      end
      else begin
        rx_cycle_counter <= 0;
        rx_register <= {uart_rx, rx_register[7:1]};
        rx_data <= (rx_bit_counter == 0) ? rx_register : rx_data;
        rx_bit_counter <= rx_bit_counter > 0 ? rx_bit_counter - 1 : 0;
        uart_irq <= (rx_bit_counter == 0) ? 1'b1 : 1'b0;
        rx_active <= 1'b1;
      end
    end
  end
  
  always @(posedge clock) begin
    if (!resetn) 
      uart_rdata <= 32'h00000000;
    else if (uart_rw_address == 32'h00010000)
      uart_rdata <= {31'b0, tx_bit_counter == 0};
    else if (uart_rw_address == 32'h00010004)
      uart_rdata <= {24'b0, rx_data};
    else
      uart_rdata <= 32'h00000000;
  end

  always @(posedge clock) begin
    if (!resetn)
      uart_rw_valid <= 1'b0;
    else
      uart_rw_valid <= uart_rw_address_valid;
  end
  
endmodule
