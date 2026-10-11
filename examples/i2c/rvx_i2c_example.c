// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// RVX setup configuration (adjust clock frequency if needed)
const RvxSetup rvx_setup = {.clock_frequency = 12000000U, .trap_handler = RVX_DEFAULT_TRAP_HANDLER};

// Pointer to I2C0 controller register block.
RvxI2c *const i2c0 = RVX_I2C0_BASE;

// Pointer to UART0 controller register block.
RvxUart *const uart0 = RVX_UART0_BASE;

// Custom utility to print a byte in hexadecimal format
void print_byte(const uint8_t read_data);

void main(void)
{
  // RVX initialization
  rvx_init(&rvx_setup);

  // Initialize UART at 9600 baud (12000000 / 1250 = 9600)
  rvx_uart_set_clock_divider(uart0, 1250U);

  // Print welcome message
  rvx_uart_print(uart0, "RVX I2C Example Project\n\n");
  rvx_uart_print(uart0, "This example reads the ID from BME280 - Temperature Sensor\n");

  // Set I2C clock frequency to 100 kHz (12000000 / 120 = 100000)
  rvx_i2c_set_clock_divider(i2c0, 120U);

  const uint8_t bme280_peripheral_address = 0b1110110;
  const uint8_t bme280_id_reg_address = 0xD0;
  uint8_t bme280_id_value = 0;

  rvx_uart_print(uart0, "\nReading BME280 ID register over I2C...\n");
  rvx_i2c_write_read(i2c0, bme280_peripheral_address, &bme280_id_reg_address, 1, &bme280_id_value, 1);

  // Print BME280 ID
  print_byte(bme280_id_value);
}

void print_byte(const uint8_t read_data)
{
  uint8_t high_nibble = (read_data >> 4) & 0x0F;
  uint8_t low_nibble = read_data & 0x0F;
  char str_val[5];
  str_val[0] = '0';
  str_val[1] = 'x';
  str_val[2] = high_nibble < 10 ? high_nibble + '0' : high_nibble - 10 + 'a';
  str_val[3] = low_nibble < 10 ? low_nibble + '0' : low_nibble - 10 + 'a';
  str_val[4] = '\0';
  rvx_uart_print(uart0, "\nRead value: ");
  rvx_uart_print(uart0, str_val);
  rvx_uart_print(uart0, "\n");
}