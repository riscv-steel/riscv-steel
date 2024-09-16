module rvsteel_mcu_wrapper (
  
  input   wire          clock       ,
  input   wire          reset       ,
  input   wire          halt        ,

  // UART
  // Remove it if your application does not use the UART.
  input   wire          uart_rx     ,
  output  wire          uart_tx     ,

  // General Purpose I/O
  // Remove it if your application does not use the GPIO.
  input   wire  [3:0]   gpio_input  ,
  output  wire  [3:0]   gpio_oe     ,
  output  wire  [3:0]   gpio_output ,

  // Serial Peripheral Interface (SPI)
  // Remove it if your application does not use the SPI controller.
  output  wire          sclk        ,
  output  wire          pico        ,
  input   wire          poci        ,
  output  wire  [0:0]   cs
  
  );

  reg reset_debounced;
  always @(posedge clock) reset_debounced <= reset;

  reg halt_debounced;
  always @(posedge clock) halt_debounced <= halt;

  rvsteel_mcu #(

    // Change to the frequency (in Hertz) of your FPGA board's clock
    .CLOCK_FREQUENCY          (50000000                   ),
    // Change to the absolute path to the .hex memory initialization file
    .MEMORY_INIT_FILE         ("/path/to/myapp.hex"       ),    
    // Set here the size you want for the memory
    .MEMORY_SIZE              (8192                       ),
    // Set here the UART baud rate
    .UART_BAUD_RATE           (9600                       ),
    // Leave it as it is, unless you explicitly changed the boot address
    .BOOT_ADDRESS             (32'h00000000               ),
    // Width of the gpio_* ports
    .GPIO_WIDTH               (1                          ),
    // Width of the cs port
    .SPI_NUM_CHIP_SELECT      (1                          ))
    
    rvsteel_mcu_instance      (
    
    .clock                    (clock                      ),
    .reset                    (reset_debounced            ),
    .halt                     (halt_debounced             ),
    .uart_rx                  (uart_rx                    ),
    .uart_tx                  (uart_tx                    ),
    .gpio_input               (gpio_input                 ),
    .gpio_oe                  (gpio_oe                    ),
    .gpio_output              (gpio_output                ),
    .sclk                     (sclk                       ),
    .pico                     (pico                       ),
    .poci                     (poci                       ),
    .cs                       (cs                         ));

endmodule