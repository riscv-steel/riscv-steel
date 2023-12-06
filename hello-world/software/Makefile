# Variables
# --------------------------------------------------------------------------------------------

# Name of the program to be created
PROGRAM_NAME      ?= hello-world
# Memory size (must be set to the same value of the MEMORY_SIZE parameter of RISC-V Steel SoC)
MEMORY_SIZE       ?= 8192
# Path to RISC-V Steel API
R5_API            ?= ../../r5-api
# The full path to RISC-V GNU Toolchain in this machine + RISC-V binaries prefix
RISCV_PREFIX      ?= /opt/riscv/bin/riscv32-unknown-elf-
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

# Basic checks: test whether the API and the required binaries are available
# --------------------------------------------------------------------------------------------

ifeq (,$(wildcard $(R5_API)/r5-api.h))
  $(error Could not find the RISC-V Steel API files in '$(R5_API)'. Please fix the R5_API \
          variable in the Makefile)
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

all: mkdir-build r5-api $(OBJ_FILES)
	@echo -n "Linking ${ELF_NAME}"
	@$(RISCV_GCC) -T ${LINKER_SCRIPT} ${COMPILER_OPTIONS} \
                   $(OBJ_FILES) build/obj/r5-api.o -o build/${ELF_NAME}
	@echo ": ok."
	@${RISCV_OBJDUMP} -D build/${ELF_NAME} > build/${OBJDUMP_NAME}
	@${RISCV_OBJCOPY} build/${ELF_NAME} -O binary build/__temp1__.bin --pad-to=$(MEMORY_SIZE) --gap-fill=0x00
	@od -t x4 -v -An -w4 build/__temp1__.bin > build/__temp2__.hex
	@cut -c2- build/__temp2__.hex > build/${HEXDUMP_NAME}
	@rm -f build/__temp1__.bin build/__temp2__.hex	
	@echo "\nGenerated files:"
	@echo "-- ELF executable   : build/${ELF_NAME}"
	@echo "-- Disassembly      : build/${OBJDUMP_NAME}"
	@echo "-- Memory init file : build/${HEXDUMP_NAME}"
	@echo "\nThe memory size is set to $(MEMORY_SIZE) bytes.\n"

mkdir-build:
	@echo ""
	@mkdir -p build/
	@mkdir -p build/obj/

r5-api: $(R5_API)/r5-api.c
	@echo -n "Building R5 API"
	@$(RISCV_GCC) -I ${R5_API} ${COMPILER_OPTIONS} \
                -D MEMORY_SIZE=\"$(MEMORY_SIZE)\" -c -o build/obj/r5-api.o $(R5_API)/r5-api.c
	@echo ": ok."

build/obj/%.o: %.c
	@echo -n "Making $(notdir $@)"
	@$(RISCV_GCC) -I ${R5_API} ${COMPILER_OPTIONS} -c -o $@ $<
	@echo ": ok."

clean:
	@rm -rf build/
	@echo "Build directory (./build) removed."