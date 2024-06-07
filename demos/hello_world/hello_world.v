module hello_world (

  input wire clock,
  input wire reset,
  output wire uart_tx
  
  );
  
  reg reset_debounced;
  always @(posedge clock) reset_debounced <= reset;

  rvsteel_mcu #(
  
    .CLOCK_FREQUENCY          (50000000                   ),
    .UART_BAUD_RATE           (9600                       ),
    .MEMORY_INIT_FILE         ("/path/to/hello_world.hex" )
  
  ) rvsteel_mcu_instance (
    .clock                    (clock                      ),
    .reset                    (reset_debounced            ),
    .halt                     (1'b0                       ),
    .uart_rx                  (/* unused */               ),
    .uart_tx                  (uart_tx                    ),
    .gpio_input               (1'b0                       ),
    .gpio_oe                  (/* unused */               ),
    .gpio_output              (/* unused */               ),
    .sclk                     (/* unused */               ),
    .pico                     (/* unused */               ),
    .poci                     (1'b0                       ),
    .cs                       (/* unused */               ),
  );

endmodule