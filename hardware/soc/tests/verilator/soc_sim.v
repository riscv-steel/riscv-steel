// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module soc_sim #
(

) (

  input   wire clock,
  input   wire reset,
  input   wire halt,
  input   wire uart_rx,
  output  wire uart_tx

);

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (50000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (32768              ),
    .MEMORY_INIT_FILE         (""                 ),
    .BOOT_ADDRESS             (32'h00000000       )

  ) rvsteel_soc_instance (

    .clock                    (clock              ),
    .reset                    (reset              ),
    .halt                     (halt               ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            )

  );

endmodule
