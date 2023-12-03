// RISC-V Steel API
#include "r5-api.h"

// This function is set as the interrupt handler in main()
void process_received_character()
{
  char received_character = r5_uart_receive_char();
  if (received_character == '\r')
    r5_uart_send_string("\nType something else and press enter: ");
  else if (received_character < 127)
    r5_uart_send_char(received_character);
}

// A Hello World program
int main()
{
  r5_uart_send_string(
      "\nRISC-V Steel SoC"
      "\n----------------"
      "\n\nHello World!"
      "\n\nType something and press enter: "
      "\n");
  r5_irq_set_interrupt_handler(process_received_character);
  r5_irq_enable_all();
  r5_wait_for_interrupt();
}