#include <string.h>

// FUNCTION DECLARATIONS
void uart_send_string(const char* str);
void uart_send_char(const char c);
void my_interrupt_handler();

// ADDRESS MAP
char* UART_TX_ADDRESS = (char*)0x00010000;
char* UART_RX_ADDRESS_DATA = (char*)0x00020000;
char* UART_RX_ADDRESS_READY = (char*)0x00020004;

// GLOBAL VARIABLES
char buffer[100];
char cbuf[2];
int count = 0;
int set = 0;
void (*int_handler)() = 0x00000000;

void set_interrupt_handler_routine(void (*my_handler)())
{
  set = 1;
  int_handler = my_handler;
  asm ("auipc t1, 0x0");
  asm ("addi t1, t1, 12");
  asm ("csrw mtvec, t1");
  if(set == 0)
  {
    (*int_handler)();
    asm ("mret");
  }
  else
  {
    set = 0;
  }
}

int main()
{

  set_interrupt_handler_routine(my_interrupt_handler);

  uart_send_string("\n\rHello World, Steel!\n\r\n\rType something and press enter: ");
  buffer[0] = '\0';    
  cbuf[1] = '\0';
  
  // Enables all kinds of interrupts
  asm ("li t6, 0xFFFFFFFF");
  asm ("csrw mstatus, t6");
  asm ("csrw mie, t6");
  
  // Busy wait
  for(;;);
  
}

void my_interrupt_handler()
{
  
  // Read data from UART receiver and put it in READY state again
  volatile int read = (*UART_RX_ADDRESS_DATA);
  (*UART_RX_ADDRESS_READY) = 1;
      
  // Enter key was pressed
  if(read == 0x0D)
  {
      
    // Show the typed message on screen
    uart_send_string("\n\rYou typed: ");
    uart_send_string(buffer);
    uart_send_string("\n\r\n\rType something and press enter: ");
        
    // Cleans the buffer
    count = 0;
    buffer[0] = '\0';
    cbuf[1] = '\0';
        
  }
      
  // Adds the typed character to the buffer
  else
  {      
       
    char c = read;
    cbuf[0] = c;
    if(count < 99)
    {
      char* bf = strcat(buffer,cbuf);
      count++;
    }
    uart_send_char(c);
        
  }
  
  // Return from the interrupt
  asm ("mret");
  
}

void uart_send_string(const char* str)
{
  for(int i = 0; i < strlen(str); i++)
  {
    while((*UART_TX_ADDRESS) != 1);
    (*UART_TX_ADDRESS) = str[i];
  }
}

void uart_send_char(const char c)
{
  while((*UART_TX_ADDRESS) != 1);
  (*UART_TX_ADDRESS) = c;
}
