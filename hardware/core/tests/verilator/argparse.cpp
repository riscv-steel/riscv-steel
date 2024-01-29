/*
Project Name:  RISC-V Steel System-on-Chip - Core simulation in Verilator
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/

#include "argparse.h"

#include <stdlib.h>
#include <iostream>
#include <getopt.h>

const char *help_str =
    "Use: app_name.run [options]\n"
    "Options:\n"
    "--out-wave=<name>      Output file *.vcd (defaul: none - off)\n\n"
    "--ram-init-h32=<name>  Input init ram file in h32 format (defaul: none - off)\n"
    "                       Example: --ram-init-h32=my_program.hex\n\n"

    "--ram-dump-h32=<name>  Output dump ram file in h32 format (defaul: none - off)\n"
    "Note:                  If the file is not specified then the dump are not created.\n\n"
    "\n\n"

    "The end of the program is:\n"
    "--cycles=<num>         Exit after processor cycles complete (defaul: 500000)\n"
    "                       Example: --cycles=10000\n\n"
    //    "--ecall            Exit if there is an instruction ecall\n"
    "--wr-addr=<addr>       Exit if there is an entry at the specified address (defaul: 0x00001000)\n"
    "                       Example: --wr-addr=0x00001000)\n\n"

    "--host-out=<addr>      Message output detection address (defaul: 0x00000000 - off)\n"
    "                       Example: --host-out=0x00000000\n"
    "Note:                  Must not be 0x0\n\n"

    "\n\n"
    "Example:\n"
    "unit_tests --ram-init-h32=add-01.hex --ram-dump-h32=add-01-dump.hex"
    "unit_tests --out-wave=wave.vcd --ram-init-h32=add-01.hex --ram-dump-h32=add-01-dump.hex"
    "unit_tests --ram-init-h32=main.hex --host-out=0x4";

enum opts
{
  cmd_help = 0,

  cmd_out_wave,
  cmd_ram_init_h32,
  cmd_ram_dump_h32,
  cmd_cycles,
  //    cmd_ecall,
  cmd_wr_addr,
  cmd_dump_h32,
  cmd_host_out,
};

static constexpr option long_opts[] =
    {
        {"help", no_argument, NULL, opts::cmd_help},
        {"out-wave", required_argument, NULL, opts::cmd_out_wave},
        {"ram-init-h32", required_argument, NULL, opts::cmd_ram_init_h32},
        {"ram-dump-h32", required_argument, NULL, opts::cmd_ram_dump_h32},
        {"cycles", required_argument, NULL, opts::cmd_cycles},
        //        { "ecall",          no_argument,        NULL, opts::cmd_ecall               },
        {"wr-addr", required_argument, NULL, opts::cmd_wr_addr},
        {"host-out", required_argument, NULL, opts::cmd_host_out},
        {NULL, no_argument, NULL, 0}};

static size_t get_int_arg(const char *arg)
{
  char *p;
  return strtoull(arg, &p, 0);
}

Args parser(int argc, char *argv[])
{
  Args args;
  int opt;

  while ((opt = getopt_long(argc, argv, "", long_opts, NULL)) != -1)
  {
    switch (opt)
    {
    case opts::cmd_help:
      std::cout << help_str;
      std::exit(EXIT_SUCCESS);

    case opts::cmd_out_wave:
      args.out_wave_path = optarg;
      std::cout << "Wave out: " << optarg << std::endl;
      break;

    case opts::cmd_ram_init_h32:
      args.ram_init_h32 = optarg;
      std::cout << "Input init ram file: " << optarg << std::endl;
      break;

    case opts::cmd_ram_dump_h32:
      args.ram_dump_h32 = optarg;
      std::cout << "Output dump ram file: " << optarg << std::endl;
      break;

    case opts::cmd_cycles:
      args.max_cycles = get_int_arg(optarg);
      std::cout << "Max cycles: " << args.max_cycles << std::endl;
      break;

    case opts::cmd_wr_addr:
      args.wr_addr = get_int_arg(optarg);
      std::cout << "Write address: 0x" << std::hex << args.wr_addr << std::endl;
      break;

    case opts::cmd_host_out:
      args.host_out = get_int_arg(optarg);
      std::cout << "Host out: 0x" << std::hex << args.host_out << std::endl;
      break;

    default:
      std::cout << "Please call for help: --help\n\n";
      std::exit(EXIT_SUCCESS);
    }
  }

  return args;
}
