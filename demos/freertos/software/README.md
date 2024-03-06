## How to build

For `debug` build:

```console
cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -DTOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
cmake --build build
```

For `release` build:

```console
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DTOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
cmake --build build
```

Or quickly:

```console
make debug TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```
