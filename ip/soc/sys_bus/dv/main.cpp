/*
Project Name:  RISC-V Steel System-on-Chip - System Bus
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/

#include <verilated_vcd_c.h>

#include "obj_dir/Vsys_bus.h"
#include "stest.h"

using Dut = Vsys_bus;
using Trace = VerilatedVcdC;

vluint64_t trace_time = 0;
vluint64_t clk_cur_cycles = 0;
vluint64_t clk_half_cycles = 2;
Dut *dut = new Dut;
Trace *trace = new Trace;

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
    eval(8);
    dut->reset_i = 0;
    eval(8);
}

static void dut_def_init()
{
    dut->addr_base[0] = 0x00000000;
    dut->addr_base[1] = 0x10000000;
    dut->addr_base[2] = 0x20000000;

    dut->addr_mask[0] = ~0xFFFF; // 64K
    dut->addr_mask[1] = ~0xFFF; // 4K
    dut->addr_mask[2] = ~0xFF; // 256B

    dut->host_read_request_i = 0;
    dut->host_write_request_i = 0;
    dut->device_read_response_i = 0;
    dut->device_write_response_i = 0;

    eval(4);
}

TEST(open_trace)
{
    Verilated::traceEverOn(true);
    dut->trace(trace, 99);
    trace->set_time_resolution("1ns");
    trace->set_time_unit("1ns");
    trace->open("obj_dir/sys_bus.vcd");

    TEST_PASS(NULL);
}

TEST(close_trace)
{
    if (trace->isOpen())
    {
        trace->dump(trace_time);
        trace->close();
    }
    TEST_PASS(NULL);
}

TEST(test_invalid_access_read)
{
    dut_reset();
    dut_def_init();

    // dev 0
    dut->host_rw_address_i = 0x00010000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_read_request_i = 0x1;
    eval(4);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);

    dut->host_read_request_i = 0x0;
    eval(7);



    // dev 1
    dut->host_rw_address_i = 0x10001000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_read_request_i = 0x1;
    eval(4);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);

    dut->host_read_request_i = 0x0;
    eval(7);


    // dev 2
    dut->host_rw_address_i = 0x20000100;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_read_request_i = 0x1;
    eval(4);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);

    dut->host_read_request_i = 0x0;
    eval(7);

    TEST_PASS(NULL);
}

TEST(test_invalid_access_write)
{
    dut_reset();
    dut_def_init();

    // dev 0
    dut->host_rw_address_i = 0x00010000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x1;
    eval(4);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 1);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x0;
    eval(7);



    // dev 1
    dut->host_rw_address_i = 0x10001000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x1;
    eval(4);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 1);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x0;
    eval(7);


    // dev 2
    dut->host_rw_address_i = 0x20000100;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x1;
    eval(4);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 1);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x0;
    eval(7);

    TEST_PASS(NULL);
}

TEST(test_valid_access_read)
{
    dut_reset();
    dut_def_init();

    // dev 0
    dut->host_rw_address_i = 0x00000000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_read_request_i = 0x1;
    eval(4);

    dut->device_read_response_i = 0x1;
    eval(1);

    dut->host_read_request_i = 0x0;
    eval(1);
    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);
    eval(1);

    dut->device_read_response_i = 0x0;
    eval(3);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(9);


    // dev 1
    dut->host_rw_address_i = 0x10000000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_read_request_i = 0x1;
    eval(4);

    dut->device_read_response_i = 0x2;
    eval(1);

    dut->host_read_request_i = 0x0;
    eval(1);
    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);
    eval(1);

    dut->device_read_response_i = 0x0;
    eval(3);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(9);


    // dev 2
    dut->host_rw_address_i = 0x20000000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_read_request_i = 0x1;
    eval(4);

    dut->device_read_response_i = 0x4;
    eval(1);

    dut->host_read_request_i = 0x0;
    eval(1);
    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);
    eval(1);

    dut->device_read_response_i = 0x0;
    eval(3);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(9);

    TEST_PASS(NULL);
}

TEST(test_valid_access_write)
{
    dut_reset();
    dut_def_init();

    // dev 0
    dut->host_rw_address_i = 0x00000000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x1;
    eval(4);

    dut->device_write_response_i = 0x1;
    eval(1);

    dut->host_write_request_i = 0x0;
    eval(1);
    TEST_ASSERT((dut->host_write_response_o & 0x1) == 1);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(1);

    dut->device_write_response_i = 0x0;
    eval(3);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(9);


    // dev 1
    dut->host_rw_address_i = 0x10000000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x1;
    eval(4);

    dut->device_write_response_i = 0x2;
    eval(1);

    dut->host_write_request_i = 0x0;
    eval(1);
    TEST_ASSERT((dut->host_write_response_o & 0x1) == 1);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(1);

    dut->device_write_response_i = 0x0;
    eval(3);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(9);


    // dev 2
    dut->host_rw_address_i = 0x20000000;
    eval(5);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);

    dut->host_write_request_i = 0x1;
    eval(4);

    dut->device_write_response_i = 0x4;
    eval(1);

    dut->host_write_request_i = 0x0;
    eval(1);
    TEST_ASSERT((dut->host_write_response_o & 0x1) == 1);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(1);

    dut->device_write_response_i = 0x0;
    eval(3);

    TEST_ASSERT((dut->host_write_response_o & 0x1) == 0);
    TEST_ASSERT((dut->host_read_response_o & 0x1) == 0);
    eval(9);

    TEST_PASS(NULL);
}

TEST(test_valid_access_read_range)
{
    dut_reset();
    dut_def_init();


    // dev 2
    dut->host_rw_address_i = 0x20000000;
    dut->host_read_request_i = 0x1;
    eval(5);
    dut->device_read_response_i = 0x4;
    eval(3);

    for (int i = 0; i < 256; i++) {
        dut->host_rw_address_i = 0x20000000 + i;
        eval(4);
        TEST_ASSERT((dut->host_read_response_o & 0x1) == 1);
    }

    eval(8);

    TEST_PASS(NULL);
}

stest_func tests[] =
{
    open_trace,
    test_invalid_access_read,
    test_invalid_access_write,
    test_valid_access_read,
    test_valid_access_write,
    test_valid_access_read_range,
    close_trace,
};

MAIN_TESTS(tests)
