#include "rvsteel-api.h"

// A minimal Hello World program
int main()
{
  uart_send_string("Hello World!");
  busy_wait();
}