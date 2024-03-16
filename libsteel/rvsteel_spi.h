#ifndef __RVSTEEL_SPI__
#define __RVSTEEL_SPI__

#include "rvsteel_globals.h"

// Struct providing access to RISC-V Steel SPI Device registers
typedef struct
{
  volatile uint32_t CPOL;        // Clock Polarity (CPOL) register.            Address offset: 0x00.
  volatile uint32_t CPHA;        // Clock Phase (CPHA) register.               Address offset: 0x04.
  volatile uint32_t CHIP_SELECT; // Chip Select (CHIP_SELECT) register.        Address offset: 0x08.
  volatile uint32_t CLOCK_CONF;  // Clock Configuration (CLOCK_CONF) register. Address offset: 0x0c.
  volatile uint32_t WDATA;       // Write Data (WDATA) register.               Address offset: 0x10.
  volatile uint32_t RDATA;       // Read Data (RDATA) register.                Address offset: 0x14.
  volatile uint32_t BUSY;        // Busy register.                             Address offset: 0x18.
} SpiDevice;

/**
 * @brief Set the clock polarity of the SPI Controller. An attempt to set CPOL to a value other than
 * 0 or 1 is gracefully ignored (no errors are given).
 *
 * @param spi Pointer to the SpiDevice.
 * @param cpol The new clock polarity. Legal values are either 0 or 1.
 */
inline void spi_set_cpol(SpiDevice *spi, const uint8_t cpol)
{
  if (cpol <= 1)
    spi->CPOL = cpol;
}

/**
 * @brief Set the clock phase of the SPI Controller. An attempt to set CPHA to a value other than 0
 * or 1 is gracefully ignored (no errors are given).
 *
 * @param spi Pointer to the SpiDevice.
 * @param cpha The new clock phase. Legal values are either 0 or 1.
 */
inline void spi_set_cpha(SpiDevice *spi, const uint8_t cpha)
{
  spi->CPHA = cpha;
}

/**
 * @brief Read the clock polarity (CPOL) register of the SPI Controller.
 *
 * @param spi Pointer to the SpiDevice.
 * @return 0
 * @return 1
 */
inline uint32_t spi_get_cpol(SpiDevice *spi)
{
  return spi->CPOL;
}

/**
 * @brief Read the clock phase (CPHA) register of the SPI Controller.
 *
 * @param spi Pointer to the SpiDevice.
 * @return 0
 * @return 1
 */
inline uint32_t spi_get_cpha(SpiDevice *spi)
{
  return spi->CPHA;
}

/**
 * @brief Select an SPI peripheral by deasserting the Chip Select (CHIP_SELECT) line connected to
 * it. An attempt to select a non-existent SPI peripheral is gracefully ignored (no errors are
 * given).
 *
 * @param spi Pointer to the SpiDevice.
 * @param peripheral_id The ID of the SPI peripheral to select. Note that peripheral IDs start at 0.
 */
inline void spi_select(SpiDevice *spi, const uint8_t peripheral_id)
{
  spi->CHIP_SELECT = peripheral_id;
}

/**
 * @brief Deselect SPI peripherals by asserting all Chip Select (CHIP_SELECT) lines.
 *
 * @param spi Pointer to the SpiDevice.
 */
inline void spi_deselect(SpiDevice *spi)
{
  spi->CHIP_SELECT = 0xffffffff;
}

/**
 * @brief Return the ID of the SPI peripheral currently selected, or `0xff` if no peripheral is
 * selected.
 *
 * @param spi Pointer to the SpiDevice.
 * @return uint8_t
 */
inline uint8_t spi_get_cs(SpiDevice *spi)
{
  return spi->CHIP_SELECT;
}

/**
 * @brief Check whether the SPI controller is ready to read/write data.
 *
 * @param spi Pointer to the SpiDevice.
 */
inline bool spi_is_ready(SpiDevice *spi)
{
  return spi->BUSY == 0;
}

/**
 * @brief Wait until the SPI controller is ready to read/write data.
 *
 * @param spi Pointer to the SpiDevice.
 */
inline void spi_wait_ready(SpiDevice *spi)
{
  while (!spi_is_ready(spi))
    ;
}

/**
 * @brief Set the frequency of the SCLK pin of the SPI Controller. The frequency of the SCLK pin is
 * equal to the frequency of the `clock` pin divided by a factor of `2*(conf + 1)`, where
 * `conf` is the value provided in the `conf` argument.
 *
 * The maximum frequency of SCLK is half the frequency of the system `clock` pin, equivalent to
 * `conf = 0`. The minimum frequency is 1/512, equivalent to `conf = 255`.
 *
 * @param spi Pointer to the SpiDevice.
 * @param conf Configuration value for the SCLK pin. The frequency of the `clock` pin is divided by
 * a factor equal to `2*(conf + 1)`.
 */
inline void spi_set_clock(SpiDevice *spi, const uint8_t conf)
{
  spi->CLOCK_CONF = conf;
}

/**
 * @brief Read the configuration of the clock register (CLOCK_CONF). Based on the return value of
 * this function, the frequency of the SCLK pin can be calculated as: `SCLKf = clockf / (2 * (conf +
 * 1))`, where `conf` is the value returned.
 *
 * @param spi Pointer to the SpiDevice.
 * @return uint8_t
 */
inline uint8_t spi_get_clock(SpiDevice *spi)
{
  return spi->CLOCK_CONF;
}

/**
 * @brief Send a byte to the selected SPI peripheral and awaits until the transfer is complete. The
 * value received over the POCI pin is ignored.
 *
 * @param spi Pointer to the SpiDevice.
 * @param wdata The byte to be sent.
 */
inline void spi_write(SpiDevice *spi, const uint8_t wdata)
{
  spi->WDATA = wdata;
  spi_wait_ready(spi);
}

/**
 * @brief Send a byte to the selected SPI peripheral and awaits until the transfer is complete. The
 * value received over the POCI pin during the transfer is returned..
 *
 * @param spi Pointer to the SpiDevice.
 * @param wdata The byte to be sent.
 */
inline uint8_t spi_transfer(SpiDevice *spi, const uint8_t wdata)
{
  spi->WDATA = wdata;
  spi_wait_ready(spi);
  return spi->RDATA;
}

#endif