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
	$(VERILATOR) -f vargs.vc --trace-fst -cc --exe --build --trace unit_tests.v vcfg.vlt main.cpp argparse.cpp -o unit_tests



clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core
