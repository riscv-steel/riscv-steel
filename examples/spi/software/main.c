// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define UART_CONTROLLER_ADDR (UartController *)0x80000000
#define SPI_CONTROLLER_ADDR (SpiController *)0x80030000

void print_readout_value(const uint8_t rdata)
{
  uint8_t val = rdata;
  char str_val[4] = "xxx\0";
  for (int i = 1; i <= 3; i++)
  {
    str_val[3 - i] = (uint8_t)((val % 10UL) + '0');
    val /= 10;
  }
  str_val[3] = '\0';
  uart_write_string(UART_CONTROLLER_ADDR, "Read out value: ");
  uart_write_string(UART_CONTROLLER_ADDR, str_val);
  uart_write_string(UART_CONTROLLER_ADDR, "\n");
}

// UART interrupt signal is connected to Fast IRQ #0
__NAKED void fast0_irq_handler(void)
{
  spi_wait_ready(SPI_CONTROLLER_ADDR);
  spi_select(SPI_CONTROLLER_ADDR, 0);
  spi_write(SPI_CONTROLLER_ADDR, 0x9f);
  volatile uint8_t read_val = spi_transfer(SPI_CONTROLLER_ADDR, 0x00);
  spi_deselect(SPI_CONTROLLER_ADDR);
  if (uart_read(UART_CONTROLLER_ADDR) == '\n') // Enter key
  {
    print_readout_value(read_val);
    uart_write_string(UART_CONTROLLER_ADDR, "Manufacturer: ");
    if (read_val == 0x01)
      uart_write_string(UART_CONTROLLER_ADDR, "Infineon\n");
    else if (read_val == 0xC2)
      uart_write_string(UART_CONTROLLER_ADDR, "Macronix\n");
    else if (read_val == 0x20)
      uart_write_string(UART_CONTROLLER_ADDR, "Micron\n");
    else
      uart_write_string(UART_CONTROLLER_ADDR, "Unknown\n");
  }
  __ASM_VOLATILE("mret");
}

void main(void)
{
  uart_write_string(UART_CONTROLLER_ADDR, "RISC-V Steel - SPI demo");
  uart_write_string(UART_CONTROLLER_ADDR,
                    "\n\nPress Enter to read the SPI Flash Manufacturer ID.\n");
  // Enable UART interrupts
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
  csr_global_enable_irq();
  // Configure the controller
  spi_set_mode(SPI_CONTROLLER_ADDR, SPI_MODE0_CPOL0_CPHA0);
  // Wait for interrupts
  while (1)
    ;
}
