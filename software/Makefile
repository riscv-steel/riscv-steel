MAKEFLAGS += --no-print-directory

ifndef RISCV_PREFIX
  RISCV_PREFIX=/opt/riscv/bin/riscv32-unknown-elf-
endif

RISCV_GCC=${RISCV_PREFIX}gcc

# Test whether it can find GCC binary
ifeq (, $(shell which ${RISCV_GCC}))
  $(error Could not find RISC-V GCC binary at '${RISCV_GCC}'. Please change RISCV_PREFIX  \
          in the Makefile)
endif

all: debug

debug:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug -DTOOLCHAIN_PREFIX=/opt/riscv/bin/riscv32-unknown-elf- ..
	@make -C build

release:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug -DTOOLCHAIN_PREFIX=/opt/riscv/bin/riscv32-unknown-elf- ..
	@make -C build

clean:
	@rm -rf build
	@echo "Build directory deleted."

.PHONY: clean debug release