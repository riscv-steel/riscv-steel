# -----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.15)

if(DEFINED STARTUP_DATA_ROM)
  add_compile_definitions(STARTUP_DATA_ROM=1)
endif()

if(DEFINED NO_STARTUP_FILES)
  add_compile_definitions(NO_STARTUP_FILES=1)
endif()

set(SOURCES
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/boot.S
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/trap_vector.S
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/trap_handlers.c
)

set(HEADERS
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/csr.h
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/globals.h
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/gpio.h
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/mtimer.h
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/libsteel.h
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/spi.h
  ${CMAKE_CURRENT_LIST_DIR}/libsteel/uart.h
)

add_library(steel STATIC ${SOURCES} ${HEADERS})

target_compile_options(steel
  PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -mstrict-align
    -march=${APP_ARCH}
    -mabi=${APP_ABI}
    -ffreestanding
    -ffunction-sections
    -fdata-sections
)

target_include_directories(steel
  PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/libsteel/
)
