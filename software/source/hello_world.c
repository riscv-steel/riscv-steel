// The header file below adds boot code and provides
// an API to configure the UART and interrupts
#include "rvsteel.h"

// Function prototype for the interrupt handler
void handle_uart_interrupt();

// Hello World program
int main()
{
  // Send Hello World! message over the UART
  rvsteel_uart_send_string("RISC-V Steel Hello World Project!\nType something and press enter:\n");
  // Set the interrupt handler
  rvsteel_set_interrupt_handler(&handle_uart_interrupt);
  // At boot all interrupt types are disable by default, so they need to be enabled
  rvsteel_enable_all_interrupt_types();
  // Keep the core idle while waiting for an interrupt.
  rvsteel_wait_for_interrupt();
}

// This is the interrupt handler. The UART triggers an interrupt everytime a character
// is received. This handler processes the received character.
void handle_uart_interrupt()
{
  // Read the character received
  char received_character = rvsteel_uart_get_char();
  // If enter key is pressed ask for more input
  if (received_character == '\r')
    rvsteel_uart_send_string("\nType something else and press enter: ");
  // Echo back only printable characters (ASCII 0x20 to 0x7f)
  else if (received_character >= 32 || received_character < 127)
    rvsteel_uart_send_char(received_character);
}