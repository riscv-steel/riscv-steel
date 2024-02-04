# ----------------------------------------------------------------------------
# Copyright (c) 2020-2024 RISC-V Steel contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

RVSTEEL_ROOT   ?=../../../../
FIRMWARE       ?= $(RVSTEEL_ROOT)/demos/examples/hello_world/software/build/hello_world.hex

VERILATOR_OPTS ?= -f vargs.vc --trace-fst -cc --exe --build --trace \
                  soc_sim.v vcfg.vlt main.cpp argparse.cpp \
                  ram_init.cpp \
                  -o soc_sim

RUN_CMD= \
  @obj_dir/soc_sim --log-level=DEBUG --log-out=dump/soc_sim.log \
  --ram-init-h32=$(FIRMWARE) --out-wave=dump/wave.fst --freq-ns=20

default:
	$(VERILATOR) $(VERILATOR_OPTS)

run:
	@mkdir -p dump
	@$(RUN_CMD)

clean:
	-rm -rf obj_dir *.log *.dump *.vpd core dump
