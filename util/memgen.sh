filename=$(basename -- "$1")
filename="${filename%.*}"
riscv32-unknown-elf-gcc $filename.c -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Ttext 0x00000000 -e main -o $filename
riscv32-unknown-elf-objdump -D $filename > $filename.dump.txt
riscv32-unknown-elf-elf2hex --bit-width 32 --input $filename --output $filename.mem
