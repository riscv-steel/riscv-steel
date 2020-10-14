riscv32-unknown-elf-objcopy -O binary $1 $1.bin
od -t x4 -v -An -w1 $1.bin > $1.dump
cut -c2- $1.dump > $1.hex
rm $1.bin $1.dump
