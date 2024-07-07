# Software Guide

<h2>Introduction</h2>

Developing software for RISC-V Steel requires the [RISC-V GNU Toolchain](https://github.com/riscv/riscv-gnu-toolchain), a suite of compilers and software development tools for the RISC-V architecture.

Follow the steps below to download, install and configure the RISC-V GNU Toolchain for RISC-V Steel:

### 1. Download the RISC-V GNU Toolchain

```
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
```

### 2. Install dependencies

=== "Ubuntu"

    ```
    sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev
    ```

=== "Fedora/CentOS/RHEL OS"

    ```
    sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel libslirp-devel
    ```

=== "Arch Linux"

    ```
    sudo pacman -Syyu autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat libslirp
    ```

=== "OS X"

    ```
    brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat texinfo flock libslirp
    ```

### 3. Configure it for RISC-V Steel

```
cd riscv-gnu-toolchain
./configure --with-arch=rv32izicsr --with-abi=ilp32 --prefix=/opt/riscv
```

### 4. Compile and install

```
make -j $(nproc)
```

</br>
</br>