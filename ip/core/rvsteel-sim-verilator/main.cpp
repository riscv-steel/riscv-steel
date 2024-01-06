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

#include "Vrvsteel_sim_verilator.h"
#include "Vrvsteel_sim_verilator___024root.h"
#include "argparse.h"



using Dut = Vrvsteel_sim_verilator;
using Trace = VerilatedVcdC;



vluint64_t vtime = 0;
vluint64_t clock_cycles = 10;
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
    if (trace->isOpen()) {
        trace->dump(vtime);
        trace->close();
    }
}



static bool clk()
{
    static vluint64_t interval = 0;

    if (vtime == interval) {
        dut->clock_i ^= 1;
        interval = vtime + clock_cycles;
        return true;
    }

    return true;
}



static uint32_t eval(vluint64_t value=1)
{
    uint32_t num_clk = 0;

    while (value--) {
        if (clk()) {
            num_clk++;
        }
        dut->eval();
        trace->dump(vtime++);
    }

    return num_clk;
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

    if (!file.is_open()) {
        std::cout << "Error file opening error: " << path << std::endl;
        std::exit(EXIT_SUCCESS);
    }

    std::string line;

    // In words
    size_t ram_size = dut->rootp->rvsteel_sim_verilator__DOT__MEMORY_SIZE / 4;

    for (int i = 0; i < ram_size; i++) {
        if (std::getline(file, line)) {
            uint32_t data = std::stoul(line, nullptr, 16);
            dut->rootp->rvsteel_sim_verilator__DOT__ram_instance__DOT__ram[i] = data;
        } else {
            break;
        }
    }

    std::cout << "Ok init ram h32" << std::endl;
    file.close();
}



void ram_dump_h32(const char *path, uint32_t offset, uint32_t size)
{
    std::ofstream file;
    file.open(path, std::ios::out | std::ios::trunc);

    if (!file.is_open()) {
        std::cout << "Error file opening error: " << path << std::endl;
        std::exit(EXIT_SUCCESS);
    }

    char buff[256];

    // In words
    offset /= 4;
    size /= 4;

    for (int i = 0; i < size; i++) {
        uint32_t data = dut->rootp->rvsteel_sim_verilator__DOT__ram_instance__DOT__ram[offset+i];
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
    return (dut->rootp->rvsteel_sim_verilator__DOT__rw_address == addr) &&
            dut->rootp->rvsteel_sim_verilator__DOT__write_request &&
            dut->rootp->rvsteel_sim_verilator__DOT__write_data;
}



bool is_host_out(uint32_t addr)
{
    static bool is_pos_edg = false;

    bool is_write = (addr != 0x0) &&
                    (not is_pos_edg and dut->rootp->rvsteel_sim_verilator__DOT__write_request) &&
                    (dut->rootp->rvsteel_sim_verilator__DOT__rw_address == addr) &&
                     dut->rootp->rvsteel_sim_verilator__DOT__write_request &&
                     dut->rootp->rvsteel_sim_verilator__DOT__write_data;

    is_pos_edg = dut->rootp->rvsteel_sim_verilator__DOT__write_request;

    return is_write;
}


static uint32_t get_signature(uint32_t addr)
{
    return dut->rootp->rvsteel_sim_verilator__DOT__ram_instance__DOT__ram[addr];
}



int main(int argc, char *argv[])
{
    signal(SIGINT, exit_app);
    signal(SIGKILL, exit_app);

    Args args = parser(argc, argv);

    if (args.out_wave_path) {
        open_trace(args.out_wave_path);
    }

    dut_reset();

    if (args.ram_init_h32) {
        ram_init_h32(args.ram_init_h32);
    }

    uint32_t cycles = 0;

    while (true) {
        // --cycles
        if (args.number_cycles) {
            if (cycles >= args.number_cycles) {
                std::cout << "Exit: end cycles: " << cycles << std::endl;
                close_trace();
                std::exit(EXIT_SUCCESS);
            }
        }

        // --wr-addr
        if (is_finished(args.wr_addr)) {
            std::cout << "Exit: wr-addr, cycles: " << cycles << std::endl;

            // The beginning and end of signature are stored at
            uint32_t start_addr = get_signature(2047);
            uint32_t stop_addr = get_signature(2046);
            uint32_t size = stop_addr-start_addr;

            std::cout << "Signature size: " << size << std::endl;

            if (args.ram_dump_h32) {
                ram_dump_h32(args.ram_dump_h32, start_addr, size);
            }

            close_trace();
            std::exit(EXIT_SUCCESS);
        }

        // --host-out
        if (is_host_out(args.host_out)) {
            std::cout << (char)dut->rootp->rvsteel_sim_verilator__DOT__write_data;
        }

        cycles += eval();
    }
}
