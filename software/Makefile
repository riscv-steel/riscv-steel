# The full path to RISC-V GNU Toolchain in this machine + RISC-V binaries prefix
RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-
# Compiler binary
RISCV_GCC         ?= ${RISCV_PREFIX}gcc
# Object dump binary
RISCV_OBJDUMP     ?= ${RISCV_PREFIX}objdump
# Object copy binary
RISCV_OBJCOPY     ?= ${RISCV_PREFIX}objcopy
# Path to linker script
LINKER_SCRIPT     = etc/link.ld
# Generated ELF name
ELF_NAME          = hello-world.elf
# Generated object dump file name
OBJDUMP_NAME      = hello-world.objdump
# Generated hexdump file name
HEXDUMP_NAME      = hello-world.hex

# Compiler options:
# --------------------------------------------------------------------------------------------
# -march=rv32izicsr           RISC-V extensions present in RISC-V Steel Core (RV32I and Zicsr)
# -mabi=ilp32                 ABI used (32-bit with soft floating point)
# -nostartfiles               Do not link with standard startup code
# -nostdlib                   Do not link with standard libraries
# -nolibc                     Do not link with the standard C library
# -nodefaultlibs              Do not link with default libs
# -mstrict-align              Do not generate unaligned addresses
# -O2                         Set optimization level to 2
COMPILER_OPTIONS  ?=  -march=rv32izicsr -mabi=ilp32 -nostartfiles -nostdlib \
                      -nolibc -nodefaultlibs -mstrict-align -O2             \

# Octal dump (od) is needed for hexdump generation
ifeq (, $(shell which od))
  $(error "No 'od' (octal dump) in your PATH. It can be installed on Ubuntu with 'sudo apt-get install coreutils'")
endif

# Test whether it can find GCC binary
ifeq (, $(shell which ${RISCV_GCC}))
  $(error "Could not find RISC-V GCC binary at '${RISCV_GCC}'. Please change RISCV_PREFIX in the Makefile.'")
endif

# Test whether it can find objdump binary
ifeq (, $(shell which ${RISCV_OBJDUMP}))
  $(error "Could not find RISC-V objdump binary at '${RISCV_OBJDUMP}'. Please change RISCV_PREFIX in the Makefile.'")
endif

# Test whether it can find objcopy binary
ifeq (, $(shell which ${RISCV_OBJCOPY}))
  $(error "Could not find RISC-V objcopy binary at '${RISCV_OBJCOPY}'. Please change RISCV_PREFIX in the Makefile.'")
endif


all:
	@mkdir -p build/
	@echo "Build directory (./build) created."
	@$(RISCV_GCC) -T ${LINKER_SCRIPT} ${COMPILER_OPTIONS} -Iinclude/ source/hello-world.c -o build/${ELF_NAME}
	@${RISCV_OBJDUMP} -D build/${ELF_NAME} > build/${OBJDUMP_NAME}
	@${RISCV_OBJCOPY} build/${ELF_NAME} -O binary build/__temp1__.bin --pad-to=0x00002000 --gap-fill=0x00
	@od -t x4 -v -An -w4 build/__temp1__.bin > build/__temp2__.hex
	@cut -c2- build/__temp2__.hex > build/${HEXDUMP_NAME}
	@rm -f build/__temp1__.bin build/__temp2__.hex
	@echo "Generated files:"
	@echo "-- ELF executable : build/${ELF_NAME}"
	@echo "-- Disassembly    : build/${OBJDUMP_NAME}"
	@echo "-- Hexdump        : build/${HEXDUMP_NAME} (use it for memory initialization)"

clean:
	@rm -rf build/
	@echo "Build directory (./build) and its content removed."