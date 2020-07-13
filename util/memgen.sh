filename=$(basename -- "$1")
filename="${filename%.*}"
riscv32-unknown-elf-as -mno-arch-attr -march=rv32i -mabi=ilp32 $1 -o $filename.o
riscv32-unknown-elf-objcopy -O binary $filename.o $filename.prog
od --endian=big --endian=little -An -t x4 $filename.prog > $filename.mem
cut -c2- < $filename.mem > $filename.txt
tr ' ' '\n' < $filename.txt > $filename.hex
rm $filename.o $filename.prog $filename.txt $filename.mem
cat $filename.hex
