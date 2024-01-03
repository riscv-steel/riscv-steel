# Configure your project by setting the variables below
# -------------------------------------------------------------------------------------------------

# Name of the program to be created
PROGRAM_NAME      ?= main
# Memory size (must be set to the same value of the MEMORY_SIZE parameter of rvsteel_soc module)
MEMORY_SIZE       ?= 8192
# Path to RISC-V Steel API
RVSTEEL_API_DIR   ?= ../rvsteel-api
# The full path to RISC-V GNU Toolchain binaries in this machine + RISC-V binaries prefix
RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-

# Other variables (do not edit)
# -------------------------------------------------------------------------------------------------

# Compiler binary
RISCV_GCC         ?= ${RISCV_PREFIX}gcc
# Object dump binary
RISCV_OBJDUMP     ?= ${RISCV_PREFIX}objdump
# Object copy binary
RISCV_OBJCOPY     ?= ${RISCV_PREFIX}objcopy
# Path to linker script
LINKER_SCRIPT     = linker-script.ld
# Generated ELF name
ELF_NAME          = $(PROGRAM_NAME).elf
# Generated object dump file name
OBJDUMP_NAME      = $(PROGRAM_NAME).objdump
# Generated hexdump file name
HEXDUMP_NAME      = $(PROGRAM_NAME).hex
# List with source file names
SRC_FILES         := $(wildcard *.c)
# List with object file names
OBJ_FILES         := $(patsubst %.c,build/obj/%.o,$(SRC_FILES))

# Compiler options:
# --------------------------------------------------------------------------------------------
# -march=rv32izicsr           RISC-V extensions present in RISC-V Steel (RV32I and Zicsr)
# -mabi=ilp32                 ABI used (32-bit with soft floating point)
# -nostartfiles               Do not link with standard startup code
# -nostdlib                   Do not link with standard libraries
# -nolibc                     Do not link with the standard C library
# -nodefaultlibs              Do not link with default libs
# -mstrict-align              Do not generate unaligned addresses
# -O2                         Set optimization level to 2
COMPILER_OPTIONS  ?=  -march=rv32izicsr -mabi=ilp32 -nostartfiles -nostdlib \
                      -nolibc -nodefaultlibs -mstrict-align -O2             \

# Basic checks: test whether the API and the required binaries are available
# --------------------------------------------------------------------------------------------

ifeq (,$(wildcard $(RVSTEEL_API_DIR)/rvsteel-api.h))
  $(error Could not find RISC-V Steel API files in '$(RVSTEEL_API_DIR)'. Please fix the \
          RVSTEEL_API_DIR variable in the Makefile)
endif

# Octal dump (od) is needed for hexdump generation
ifeq (, $(shell which od))
  $(error Could not find 'od' (octal dump) executable. It can be installed on Ubuntu    	\
          by running 'sudo apt-get install coreutils')
endif

# Test whether it can find GCC binary
ifeq (, $(shell which ${RISCV_GCC}))
  $(error Could not find RISC-V GCC binary at '${RISCV_GCC}'. Please change RISCV_PREFIX  \
          in the Makefile)
endif

# Test whether it can find objdump binary
ifeq (, $(shell which ${RISCV_OBJDUMP}))
  $(error Could not find RISC-V objdump binary at '${RISCV_OBJDUMP}'. Please change       \
          RISCV_PREFIX in the Makefile)
endif

# Test whether it can find objcopy binary
ifeq (, $(shell which ${RISCV_OBJCOPY}))
  $(error Could not find RISC-V objcopy binary at '${RISCV_OBJCOPY}'. Please change       \
          RISCV_PREFIX in the Makefile)
endif

# Targets
# --------------------------------------------------------------------------------------------

all: mkdir-build rvsteel-api $(OBJ_FILES)
	@echo -n "Linking ${ELF_NAME}"
	@$(RISCV_GCC) -T ${LINKER_SCRIPT} ${COMPILER_OPTIONS} \
                   $(OBJ_FILES) build/obj/rvsteel-api.o -o build/${ELF_NAME}
	@echo ": ok."
	@${RISCV_OBJDUMP} -D build/${ELF_NAME} > build/${OBJDUMP_NAME}
	@${RISCV_OBJCOPY} build/${ELF_NAME} -O binary build/__temp1__.bin --pad-to=$(MEMORY_SIZE) --gap-fill=0x00
	@od -t x4 -v -An -w4 build/__temp1__.bin > build/__temp2__.hex
	@cut -c2- build/__temp2__.hex > build/${HEXDUMP_NAME}
	@rm -rf build/__temp1__.bin build/__temp2__.hex build/obj
	@echo "\nGenerated files:"
	@echo "-- ELF executable   : build/${ELF_NAME}"
	@echo "-- Disassembly      : build/${OBJDUMP_NAME}"
	@echo "-- Memory init file : build/${HEXDUMP_NAME}"
	@echo "\nThe memory size is set to $(MEMORY_SIZE) bytes.\n"

mkdir-build:
	@echo ""
	@mkdir -p build/
	@mkdir -p build/obj/

rvsteel-api: $(RVSTEEL_API_DIR)/rvsteel-api.c
	@echo -n "Building RISC-V Steel API"
	@$(RISCV_GCC) -I ${RVSTEEL_API_DIR} ${COMPILER_OPTIONS} \
                -D MEMORY_SIZE=\"$(MEMORY_SIZE)\" -c -o build/obj/rvsteel-api.o $(RVSTEEL_API_DIR)/rvsteel-api.c
	@echo ": ok."

build/obj/%.o: %.c
	@echo -n "Making $(notdir $@)"
	@$(RISCV_GCC) -I ${RVSTEEL_API_DIR} ${COMPILER_OPTIONS} -c -o $@ $<
	@echo ": ok."

clean:
	@rm -rf build/
	@echo "Build directory (./build) removed."