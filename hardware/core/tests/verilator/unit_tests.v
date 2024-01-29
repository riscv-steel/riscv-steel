/*
Project Name:  RISC-V Steel System-on-Chip - Core simulation in Verilator
Project Repo:  github.com/riscv-steel/riscv-steel

Copyright (C) Alexander Markov - github.com/AlexxMarkov
SPDX-License-Identifier: MIT
*/



module unit_tests #
(
    // Memory size in bytes
    parameter MEMORY_SIZE   = 2097152          ,
    parameter BOOT_ADDRESS  = 32'h00000000
)
(
    input   clock_i ,
    input   reset_i ,
    input   halt_i
);




wire   [31:0]  rw_address;
wire   [31:0]  read_data;
wire           read_request;
wire           read_response;
wire   [31:0]  write_data;
wire   [3:0 ]  write_strobe;
wire           write_request;
wire           write_response;



rvsteel_core #
(
    .BOOT_ADDRESS           (BOOT_ADDRESS   )
)
dut0
(
    // Global signals

    .clock                  (clock_i        ),
    .reset                  (reset_i        ),
    .halt                   (halt_i         ),

    // IO interface

    .rw_address             (rw_address     ),
    .read_data              (read_data      ),
    .read_request           (read_request   ),
    .read_response          (read_response  ),
    .write_data             (write_data     ),
    .write_strobe           (write_strobe   ),
    .write_request          (write_request  ),
    .write_response         (write_response ),

    // Interrupt signals (hardwire inputs to zero if unused)

    .irq_external           (1'b0),
    .irq_timer              (1'b0),
    .irq_software           (1'b0),

    // verilator lint_off PINCONNECTEMPTY
    .irq_external_response  (),
    .irq_timer_response     (),
    .irq_software_response  (),
    // verilator lint_on PINCONNECTEMPTY

    // Real Time Clock (hardwire to zero if unused)

    .real_time_clock        (64'b0)
);



rvsteel_ram #
(
    .MEMORY_SIZE            (MEMORY_SIZE    )
    // .MEMORY_INIT_FILE       ("../unit-tests/programs/add-01.hex")
)
rvsteel_ram_instance
(

    // Global signals

    .clock                  (clock_i        ),
    .reset                  (reset_i        ),

    // IO interface

    .rw_address             (rw_address     ),
    .read_data              (read_data      ),
    .read_request           (read_request   ),
    .read_response          (read_response  ),
    .write_data             (write_data     ),
    .write_strobe           (write_strobe   ),
    .write_request          (write_request  ),
    .write_response         (write_response )
);



endmodule
