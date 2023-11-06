module top (

  input   wire clock,
  input   wire reset,
  input   wire uart_rx,
  output  wire uart_tx

  );

  rvsteel_soc #(

    .CLOCK_FREQUENCY          (27000000           ),
    .UART_BAUD_RATE           (9600               ),
    .MEMORY_SIZE              (4096               ),
    .MEMORY_INIT_FILE         ("hello-world.mem"  ),
    .FILL_UNUSED_MEMORY_WITH  (32'hdeadbeef       ),
    .BOOT_ADDRESS             (32'h00000000       )

  ) rvsteel_soc_instance (
    
    .clock                    (clock        ),
    .reset                    (reset              ),
    .uart_rx                  (uart_rx            ),
    .uart_tx                  (uart_tx            )

  );

endmodule
