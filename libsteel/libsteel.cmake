# -----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.15)

set(LIBSTEEL_BOOT           ${CMAKE_CURRENT_LIST_DIR}/rvsteel_boot.S)
set(LIBSTEEL_LINKER_SCRIPT  ${CMAKE_CURRENT_LIST_DIR}/rvsteel_link.ld)

add_library(libsteel INTERFACE)

target_include_directories(libsteel
  INTERFACE
     ${CMAKE_CURRENT_LIST_DIR}
)
