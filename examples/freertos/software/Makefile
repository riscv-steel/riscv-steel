# ----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

MAKEFLAGS += --no-print-directory

ifdef TOOLCHAIN_PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
endif

ifdef PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX="${PREFIX}/bin/riscv32-unknown-elf-"
endif

all: debug

check_usage:
ifndef CLOCK_FREQUENCY
	$(info Usage:     make [debug|release] CLOCK_FREQUENCY=<freq_in_hertz>)
	$(info Example:   make debug CLOCK_FREQUENCY=50000000)
	$(info ---)
	$(info The FreeRTOS example contains timing functionality that needs to know the clock frequency to work properly.)
	$(info ---)
	$(error Exiting due to errors)
endif

debug: check_usage
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=${CLOCK_FREQUENCY} ..
	$(MAKE) -C build

release: check_usage
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX_FLAG} -DCLOCK_FREQUENCY=${CLOCK_FREQUENCY} ..
	$(MAKE) -C build

clean:
	@rm -rf build dump
	@echo "Build directory deleted."

.PHONY: check_usage debug release clean
