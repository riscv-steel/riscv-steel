// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef ARGPARSE_H
#define ARGPARSE_H

#include <cstdint>
#include <cstddef>

enum verbosity
{
  QUIET,
  VERBOSE
};

struct Args
{
  char *out_wave_path{nullptr};
  char *ram_init_h32{nullptr};
  char *ram_dump_h32{nullptr};
  uint32_t max_cycles{500000};
  uint32_t wr_addr{0x00001000};
  uint32_t host_out{0x00000000};
};

Args parser(int argc, char *argv[]);

#endif // ARGPARSE_H
