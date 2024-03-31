// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

.global rvsteel_boot
.section ".init.rvsteel_boot"
.option norvc;

rvsteel_boot:
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la sp, __stack_top
  la t0, rvsteel_trap_vector
  csrw mtvec, t0

#ifdef STARTUP_DATA_ROM
  la a0, __data_target_start
  la a2, __data_target_end
  sub a2, a2, a0
  li a1, __data_source_start
  call memcpy
#endif

#ifdef NO_STARTUP_FILES
  call main
#else
  call _start
#endif
  j .