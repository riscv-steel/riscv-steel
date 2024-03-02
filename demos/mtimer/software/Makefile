# ----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

MAKEFLAGS += --no-print-directory

RUN_FLAGS  = "
RUN_FLAGS += --log-level=DEBUG
RUN_FLAGS += --ram-init-h32=$$PWD/build/example_mtimer.hex
RUN_FLAGS += --out-wave=$$PWD/dump/wave.fst
RUN_FLAGS += --cycles=1000000
RUN_FLAGS += "

ifdef TOOLCHAIN_PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
endif

all: debug

debug:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} ..
	$(MAKE) -C build

release:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX_FLAG} ..
	$(MAKE) -C build

run_sim: all
	@mkdir -p dump
	$(MAKE) -C ../../../hardware/soc/tests/verilator/ run RUN_FLAGS=$(RUN_FLAGS)

clean:
	@rm -rf build dump
	@echo "Build directory deleted."

.PHONY: clean debug release
