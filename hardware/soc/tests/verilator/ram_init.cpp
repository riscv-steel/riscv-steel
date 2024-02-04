// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "ram_init.h"

#include <fstream>
#include "log.h"

void ram_init_h32(const char *path, uint32_t words, DutRamWrite write)
{
  std::ifstream file;

  file.open(path, std::ios::in);

  if (!file.is_open())
  {
    Log::error("Error file opening: %s", path);
    std::exit(EXIT_FAILURE);
  }

  Log::info("Ram words %u", words);

  std::string line;
  size_t load_address = 0x00000000;

  // First initialize the RAM
  for (size_t i = 0; i < words; i++)
  {
    write(i, 0xdeadbeef);
  }

  // Then load the memory init file
  while (std::getline(file, line))
  {
    char *token = strtok((char *)line.c_str(), " \n");
    while (token != NULL)
    {
      std::string token_str = std::string(token);
      if (token_str[0] == '@') // update load address
      {
        load_address = std::stoul(token_str.substr(1), nullptr, 16);
        token = strtok(NULL, " \n");
      }
      else
      {
        uint32_t data = std::stoul(token_str, nullptr, 16);

        if (load_address > words)
        {
          Log::error("Out of range load address ram: 0x%x", load_address);
          std::exit(EXIT_FAILURE);
        }

        write(load_address, data);
        token = strtok(NULL, " \n");
        load_address++;
      }
    }
  }

  Log::info("Ok init ram h32");
  file.close();
}

void ram_init_bin(const char *path, uint32_t words, DutRamWrite write)
{
  std::ifstream file;

  file.open(path, std::ios::binary);

  if (!file.is_open())
  {
    Log::error("Error file opening: %s", path);
    std::exit(EXIT_FAILURE);
  }

  Log::info("Ram words %u", words);

  // First initialize the RAM
  for (size_t i = 0; i < words; i++)
  {
    write(i, 0xdeadbeef);
  }

  char buffer[4];
  size_t load_address = 0;

  while (not file.eof())
  {
    file.read(buffer, 4);

    uint32_t data = 0;
    size_t count = file.gcount();

    if (count == 0)
    {
      break;
    }

    if (count == 4)
    {
      data  = (buffer[3] & 0xff) << 24;
      data |= (buffer[2] & 0xff) << 16;
      data |= (buffer[1] & 0xff) << 8;
      data |= (buffer[0] & 0xff);
    }
    else
    {
      uint32_t mod = count % 4;
      for (size_t i = mod; i != 0; i--)
      {
          data |= (buffer[i-1] & 0xff);
          data <<= 8;
      }
    }

    if (load_address > words)
    {
      Log::error("Out of range load address ram: 0x%x", load_address);
      std::exit(EXIT_FAILURE);
    }

    write(load_address++, data);
  }

  Log::info("Ok init ram bin");
  file.close();
}
