/*
Project Name:  RISC-V Steel System-on-Chip - Core simulation in Verilator
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/

#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <signal.h>

#include <verilated_vcd_c.h>
#include <verilated_fst_c.h>

#include "Vunit_tests.h"
#include "Vunit_tests___024root.h"
#include "argparse.h"

using Dut = Vunit_tests;
using Trace = VerilatedFstC;

vluint64_t trace_time = 0;
vluint64_t clk_cur_cycles = 0;
vluint64_t clk_half_cycles = 2;
Dut *dut = new Dut;
Trace *trace = new Trace;

static void open_trace(const char *out_wave_path)
{
  Verilated::traceEverOn(true);
  dut->trace(trace, 99);
  trace->set_time_resolution("1ns");
  trace->set_time_unit("1ns");
  trace->open(out_wave_path);
}

static void close_trace()
{
  if (trace->isOpen())
  {
    trace->dump(trace_time);
    trace->close();
  }
}

static void clk()
{
  static vluint64_t interval = 0;

  if (trace_time >= interval)
  {
    dut->clock_i ^= 1;
    interval = trace_time + clk_half_cycles;
    clk_cur_cycles += dut->clock_i & 0x1;
  }
}

static void eval(vluint64_t cycles_cnt = 1)
{
  while (cycles_cnt--)
  {
    clk();
    dut->eval();
    trace->dump(trace_time++);
  }
}

static void dut_reset()
{
  dut->reset_i = 1;
  eval(100);
  dut->reset_i = 0;
  dut->halt_i = 0;
}

void exit_app(int sig)
{
  (void)sig;
  close_trace();
  std::cout << "Exit." << std::endl;
  std::exit(EXIT_SUCCESS);
}

void ram_init_h32(const char *path)
{
  std::ifstream file;

  file.open(path, std::ios::in);

  if (!file.is_open())
  {
    std::cout << "Error file opening: " << path << std::endl;
    std::exit(EXIT_FAILURE);
  }

  std::string line;

  // In words
  size_t ram_size = dut->rootp->unit_tests__DOT__MEMORY_SIZE / 4;

  for (int i = 0; i < ram_size; i++)
  {
    if (std::getline(file, line))
    {
      uint32_t data = std::stoul(line, nullptr, 16);
      dut->rootp->unit_tests__DOT__ram_instance__DOT__ram[i] = data;
    }
    else
    {
      dut->rootp->unit_tests__DOT__ram_instance__DOT__ram[i] = 0xdeadbeef;
    }
  }

  std::cout << "Ok init ram h32" << std::endl;
  file.close();
}

void ram_dump_h32(const char *path, uint32_t offset, uint32_t size)
{
  std::ofstream file;
  file.open(path, std::ios::out | std::ios::trunc);

  if (!file.is_open())
  {
    std::cout << "Error file opening: " << path << std::endl;
    std::exit(EXIT_FAILURE);
  }

  char buff[32];

  // In words
  offset /= 4;
  size /= 4;

  for (int i = 0; i < size; i++)
  {
    uint32_t data = dut->rootp->unit_tests__DOT__ram_instance__DOT__ram[offset + i];
    snprintf(buff, sizeof(buff), "%08" PRIx32, (const uint32_t)data);
    file << buff << '\n';
  }

  std::cout << "Ok dump ram h32" << std::endl;
  file.close();
}

bool is_finished(uint32_t addr)
{
  // After each clock cycle it tests whether the test program finished its execution
  // This event is signaled by writing 1 to the address 0x00001000
  return (dut->rootp->unit_tests__DOT__rw_address == addr) &&
         dut->rootp->unit_tests__DOT__write_request &&
         dut->rootp->unit_tests__DOT__write_data == 0x00000001;
}

bool is_host_out(uint32_t addr)
{
  static bool is_pos_edg = false;

  bool is_write = (addr != 0x0) &&
                  (not is_pos_edg and dut->rootp->unit_tests__DOT__write_request) &&
                  (dut->rootp->unit_tests__DOT__rw_address == addr) &&
                  dut->rootp->unit_tests__DOT__write_request &&
                  dut->rootp->unit_tests__DOT__write_data;

  is_pos_edg = dut->rootp->unit_tests__DOT__write_request;

  return is_write;
}

static uint32_t get_signature(uint32_t addr)
{
  return dut->rootp->unit_tests__DOT__ram_instance__DOT__ram[addr];
}

int main(int argc, char *argv[])
{
  signal(SIGINT, exit_app);
  signal(SIGKILL, exit_app);

  Args args = parser(argc, argv);

  if (args.out_wave_path)
  {
    open_trace(args.out_wave_path);
  }

  dut_reset();

  if (args.ram_init_h32)
  {
    ram_init_h32(args.ram_init_h32);
  }

  while (true)
  {
    eval();

    // --cycles
    if (args.max_cycles)
    {
      if (clk_cur_cycles >= args.max_cycles)
      {
        std::cout << "Exit: end cycles" << std::endl;
        close_trace();
        std::exit(EXIT_SUCCESS);
      }
    }

    // --wr-addr
    if (is_finished(args.wr_addr))
    {
      std::cout << "Exit: wr-addr" << std::endl;

      // The beginning and end of signature are stored at
      uint32_t start_addr = get_signature(2047);
      uint32_t stop_addr = get_signature(2046);
      uint32_t size = stop_addr - start_addr;

      std::cout << "Signature size: " << size << std::endl;

      if (args.ram_dump_h32 and (size >= 4))
      {
        ram_dump_h32(args.ram_dump_h32, start_addr, size);
      }

      close_trace();
      std::exit(EXIT_SUCCESS);
    }

    // --host-out
    if (is_host_out(args.host_out))
    {
      std::cout << (char)dut->rootp->unit_tests__DOT__write_data;
    }
  }
}
