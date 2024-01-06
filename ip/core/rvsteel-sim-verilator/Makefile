# Project Name:  RISC-V Steel System-on-Chip - Core simulation in Verilator
# Project Repo:  github.com/riscv-steel/riscv-steel
# 
# Copyright (C) Alexander Markov - github.com/AlexxMarkov
# SPDX-License-Identifier: MIT



ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif



default:
	$(VERILATOR) -f vargs.vc -cc --exe --build --trace --Wall --default-language "1364-2001" rvsteel_sim_verilator.v vcfg.vlt main.cpp argparse.cpp



clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core
