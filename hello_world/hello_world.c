// System boot
asm (
  ".section .boot;                     "  // Defines the boot section
  "boot:                               "
  "  la sp, 0x00004000;                "  // The stack pointer must always point to the last memory position
  "  la t0, interrupt_handler;         "  // Set mtvec CSR to the address of the interrupt handler
  "  csrw mtvec, t0;                   "  
  "  j _start;                         "  // Jump to program start
);

// Interrupt handler
// Calls process_received_character() and return from M-mode
asm (
  "interrupt_handler:"
  "  call process_received_character;"
  "  mret;"
);

// Addresses to TX/RX data over the UART
int* uart_tx_address = (int*) 0x00010000;
int* uart_rx_address = (int*) 0x00010004;

// Sends a single character over the UART transmitter
void uart_tx_char(char c)
{
  while((*uart_tx_address) != 1); // Waits the UART TX to be ready
  (*uart_tx_address) = c;         // Send the character
}

// Sends a string over the UART transmitter
void uart_tx_string(char* str)
{  
  while (*(str) != '\0')
  {
    uart_tx_char(*(str));
    str++;
  }
}

// Return the character received over the UART
char uart_rx_char()
{
  return (*uart_rx_address);
}

/* If Enter key is pressed, prints "You pressed Enter key".
 * Otherwise simply echoes back the received character (if it is printable) */
void process_received_character()
{
  char received_character = uart_rx_char();
  if (received_character == '\r')
    uart_tx_string("\nYou pressed Enter key.\n");
  else if (received_character >= 32 || received_character < 127) 
    uart_tx_char(received_character);
}

int main()
{
  // Send Hello World! message
  uart_tx_string("\n\nRISC-V Steel Core Project\n\nHello World!\n\nType anything or press enter:\n");
  // Enable interrupts
  asm (
    "li t0, 0xffffffff;"
    "csrw mstatus, t0;"
    "csrw mie, t0;"
  );
  // Enter into an infinite loop (wait for interrupt)
  for(;;);
}