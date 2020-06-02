riscv32-unknown-elf-as -mno-arch-attr -march=rv32i -mabi=ilp32 $1.s -o $1.o
riscv32-unknown-elf-objcopy -O binary $1.o $1.prog
od --endian=big -An --endian=little -t x4 $1.prog > $1.mem
riscv32-unknown-elf-objdump -D $1.o
cat $1.mem
rm $1.o $1.prog
