/*
Project Name:  RISC-V Steel System-on-Chip - Core simulation in Verilator
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/



#ifndef ARGPARSE_H
#define ARGPARSE_H


#include <cstdint>
#include <cstddef>



struct Args {
    char *out_wave_path{nullptr};
    char *ram_init_h32{nullptr};
    char *ram_dump_h32{nullptr};
    uint32_t number_cycles{500000};
    uint32_t wr_addr{0x00001000};
    uint32_t host_out{0x00000000};
};



Args parser(int argc, char *argv[]);



#endif // ARGPARSE_H
