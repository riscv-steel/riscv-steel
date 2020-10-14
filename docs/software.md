# Compiling software for Steel

The [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain) provides the Newlib cross-compiler, which can be used to compile software for Steel. To configure the compiler for Steel and install it follow these steps:

**1 - Clone the toolchain repo and all its submodules:**
```
$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
```
**2 - Install the prerequisites, according to your OS:**

On Ubuntu:
```
$ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```
On Fedora/CentOS/RHEL OS:
```
$ sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```
On Arch Linux:
```
$ pacman -Syyu autoconf automake curl python3 mpc mpfr gmp gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib expat
```
On OS X:
```
$ brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat
```
**3 - Configure the installation for Steel (the toolchain will be installed in the path /opt/riscv):**
```
$ cd riscv-gnu-toolchain
$ ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
```
**4 - Make the compiler:**
```
$ make
```

<h2>Compiling your program</h2>

A program can be compiled to run on Steel with the following command (assuming you have installed the toolchain in the path `/opt/riscv`):
```
$ cd /opt/riscv/bin
$ riscv32-unknown-elf-gcc --with-arch=rv32i --with-abi=ilp32 myprogram.c -o myprogram
```
The compiler will output an ELF file named **myprogram**. The flags `--with-arch=rv32i` and `--with-abi=ilp32` are optional if you have configured the compiler following the instructions in the section above.

To relocate the code to start at a specific address you can use the flag `-Ttext`. For example:
```
$ cd /opt/riscv/bin
$ riscv32-unknown-elf-gcc --with-arch=rv32i --with-abi=ilp32 -Ttext 0x00000000 myprogram.c -o myprogram
```

> **Tip:** If you are using an FPGA and your system's RAM is an array of memory, you may need to transform your program (which is an ELF file) into an .hex file. By doing this, you can use the .hex file with Verilog's **$readmemh** function to fill the memory array. To generate an .hex file from your compiled program, execute the following commands:
```
$ cd /opt/riscv/bin
$ riscv32-unknown-elf-objcopy -O binary myprogram myprogram.bin
$ od -t x4 -v -An -w1 myprogram.bin > myprogram.dump
$ cut -c2- myprogram.dump > myprogram.hex
$ rm myprogram.bin myprogram.dump
```
> The **util** directory has a script called **elf2hex** that transforms an ELF into an .hex file. See the contents of the file **soc/ram.v** to learn how to build a RAM memory using Verilog arrays.
