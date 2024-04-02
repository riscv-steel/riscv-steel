// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module freertos_arty_a7 (

  input   wire clock,
  input   wire reset,
  input   wire halt,
  input   wire uart_rx,
  output  wire uart_tx,
  output  wire gpio0,
  output  wire gpio1

  );

  // Divides the 100MHz board block by 2
  reg clock_50mhz;
  initial clock_50mhz = 1'b0;
  always @(posedge clock) clock_50mhz <= !clock_50mhz;

  // Buttons debouncing
  reg reset_debounced;
  reg halt_debounced;
  always @(posedge clock_50mhz) begin
    reset_debounced <= reset;
    halt_debounced <= halt;
  end

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (12000000               ),
    .UART_BAUD_RATE           (9600                   ),
    .MEMORY_SIZE              (131072                 ),
    .MEMORY_INIT_FILE         ("freertos_demo.hex"    ),
    .BOOT_ADDRESS             (32'h00000000           ),
    .GPIO_WIDTH               (2                      )

  ) rvsteel_soc_instance (

    .clock                    (clock_50mhz            ),
    .reset                    (reset_debounced        ),
    .halt                     (halt_debounced         ),
    .uart_rx                  (uart_rx                ),
    .uart_tx                  (uart_tx                ),
    .gpio_input               (1'b0                   ),
    .gpio_oe                  (), // unused
    .gpio_output              ({gpio1,gpio0}          ),
    .sclk                     (), // unused
    .pico                     (), // unused
    .poci                     (1'b0                   ),
    .cs                       ()  // unused

  );

endmodule