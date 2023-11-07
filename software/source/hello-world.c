// RISC-V Steel API
#include "rvsteel.h"

// This function is set as the interrupt handler in main()
void process_received_character()
{
  char received_character = rvsteel_uart_get_char();
  if (received_character == '\r')
    rvsteel_uart_send_string("\nType something else and press enter: ");
  else if (received_character < 127)
    rvsteel_uart_send_char(received_character);
}

// A Hello World program
int main()
{
  rvsteel_uart_send_string(
      "\nRISC-V Steel SoC"
      "\n----------------"
      "\n\nHello World!"
      "\n\nType something and press enter: "
      "\n");
  rvsteel_set_interrupt_handler(&process_received_character);
  rvsteel_enable_all_interrupt_types();
  rvsteel_wait_for_interrupt();
}