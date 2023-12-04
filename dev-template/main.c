#include "r5-api.h"

// A minimal Hello World program
int main()
{
  r5_uart_send_string("Hello World!");
  r5_busy_wait();
}