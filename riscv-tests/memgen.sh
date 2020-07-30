shopt -s extglob
getfiles="ls rv32ui!(*.dump|*.hex)"
filenames=`$getfiles`
for eachfile in $filenames
do
	riscv32-unknown-elf-ld $eachfile -Ttext 0x00000000 -Tdata 0x00002000 -o $eachfile.v2
	riscv32-unknown-elf-elf2hex --bit-width 32 --input $eachfile.v2 > $eachfile.mem 
	#riscv32-unknown-elf-objdump -d $eachfile.v2 | tail -n +8 | head -n -1 | cut -c 7-14 > $eachfile.mem
	rm $eachfile.v2
done
