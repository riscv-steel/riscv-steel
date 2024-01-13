


ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif


LINT = ../lint



default:
	$(VERILATOR) -f $(LINT)/vargs.vc --trace -cc --exe --build --trace sys_bus.v $(LINT)/vcfg.vlt main.cpp -o sys_bus



clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core
