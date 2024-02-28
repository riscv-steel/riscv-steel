MAKEFLAGS += --no-print-directory

ifndef TOOLCHAIN_PREFIX
  TOOLCHAIN_PREFIX=/opt/riscv/bin/riscv32-unknown-elf-
endif

all: debug

debug:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX} ..
	@make -C build

release:
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Debug -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX} ..
	@make -C build

clean:
	@rm -rf build
	@echo "Build directory deleted."

.PHONY: clean debug release