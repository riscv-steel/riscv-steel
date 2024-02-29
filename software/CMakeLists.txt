# -----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# -----------------------------------------------------------------------------

# Minimal CMake version required
cmake_minimum_required(VERSION 3.15)

# Name of the executable to be generated
set(APP_NAME "myapp")

# Frequency of the clock signal (needed for FreeRTOS)
set(CPU_FREQUENCY 50000000UL)

# Path to the folder with RISC-V Steel header files
set(RVSTEEL_INC_DIR ${CMAKE_SOURCE_DIR}/include/)

# RISC-V ISA features present in RISC-V Steel
set(APP_ARCH rv32izicsr)

# Application Binary Interface in use: 32-bit Generic ELF, Soft Floating-Point
set(APP_ABI ilp32)

# C++ standard in use
set(CMAKE_CXX_STANDARD 11)

# C++ optimization level
set(CMAKE_CXX_FLAGS "-O2")

# C standard in use
set(CMAKE_C_STANDARD 11)

# C optimization level
set(CMAKE_C_FLAGS "-O2")

# Path to RISC-V Steel linker script
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/link.ld)

# Cross-Compiling for a generic microcontroller
set(CMAKE_SYSTEM_NAME Generic)

# Tell CMake not to try to link executables during its checks
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# The suffix for executables on this platform.
set(CMAKE_EXECUTABLE_SUFFIX ".elf")

# Get more verbose output from Makefile builds
set(CMAKE_VERBOSE_MAKEFILE OFF)

# Give TOOLCHAIN_PREFIX a default value if its definition is missing
if(NOT DEFINED TOOLCHAIN_PREFIX)
  message(STATUS "[INFO] TOOLCHAIN_PREFIX set to default value: riscv32-unknown-elf-")
  set(TOOLCHAIN_PREFIX riscv32-unknown-elf-)
endif()

# RISC-V Assembler
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)

# RISC-V C Compiler
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)

# RISC-V C++ Compiler
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)

# RISC-V Object Copy
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)

# RISC-V Object Dump
set(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump)

# Find GCC
find_program(PATH_CMAKE_C_COMPILER
  ${CMAKE_C_COMPILER}
  PATHS ENV PATH
  REQUIRED
)

# Print whether GCC was found
if(NOT PATH_CMAKE_C_COMPILER)
  message(FATAL_ERROR "[ERROR] Could not find CMAKE_C_COMPILER: " ${PATH_CMAKE_C_COMPILER})
else()
  message(STATUS "[INFO] Compiling with GCC: " ${PATH_CMAKE_C_COMPILER})
endif()

# Create the project and set languages used
project(${APP_NAME} LANGUAGES C CXX ASM)

# Set compiler definitions
add_compile_definitions(CPU_FREQUENCY=${CPU_FREQUENCY})

# Set GCC flags
add_compile_options(
  # Enables all the warnings about constructions that some users consider questionable
  -Wall
  # Enables some extra warning flags that are not enabled by -Wall
  -Wextra
  # Issue all the warnings demanded by strict ISO C and ISO C++
  -Wpedantic
  # Do not generate unaligned memory accesses (RISC-V Steel does not support unaligned accesses)
  -mstrict-align
  # Specify the supported RISC-V features present in RISC-V Steel
  -march=${APP_ARCH}
  # Specify the Application Binary Interface supported by RISC-V Steel
  -mabi=${APP_ABI}
  # Tells GCC that this project does not run on top of an operating system
  -ffreestanding
)

# Set GNU ld flags
add_link_options(
  # Specify the linker script for RISC-V Steel
  -T ${LINKER_SCRIPT}
  # Do not link with libraries linked by default such as libc
  -nodefaultlibs
  # Do not link standard startup code since it is not needed for bare-metal (freestanding) software
  -nostartfiles
  # Enable garbage colletion (removal of sections never used)
  -Wl,--gc-sections
  # Generate a Map file with linking information
  -Wl,-Map=${APP_NAME}.map
  # Do not generate unaligned memory accesses (RISC-V Steel does not support it)
  -mstrict-align
  # Specify the supported RISC-V features present in RISC-V Steel
  -march=${APP_ARCH}
  # Specify the Application Binary Interface supported by RISC-V Steel
  -mabi=${APP_ABI}
)

# Source files
set(SOURCES
  ${CMAKE_SOURCE_DIR}/boot/startup_reset.S
  ${CMAKE_SOURCE_DIR}/boot/startup_init.c
  ${CMAKE_SOURCE_DIR}/main.cpp
)

# Instruct the compiler where to find RISC-V Steel header files
include_directories(
  ${RVSTEEL_INC_DIR}
)

# The executable
add_executable(${APP_NAME}.elf ${SOURCES})

# Set dependency on linker script
set_target_properties(${APP_NAME}.elf PROPERTIES
  LINK_DEPENDS "${LINKER_SCRIPT}"
)

# Set additional files that needs to be removed when cleaning
set_property(TARGET ${APP_NAME}.elf
  APPEND PROPERTY ADDITIONAL_CLEAN_FILES
  ${APP_NAME}.bin
  ${APP_NAME}.hex
  ${APP_NAME}.objdump
  ${APP_NAME}.map
)

# Generate Memory Init File (.hex) and disassembly after build
add_custom_command(TARGET ${APP_NAME}.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary      ${APP_NAME}.elf ${APP_NAME}.bin
  COMMAND ${CMAKE_OBJCOPY} -O verilog     ${APP_NAME}.elf --verilog-data-width=4 ${APP_NAME}.hex
  COMMAND ${CMAKE_OBJDUMP} -D             ${APP_NAME}.elf > ${APP_NAME}.objdump
)