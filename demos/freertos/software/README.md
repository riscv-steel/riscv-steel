## How to build

Run `make` (with no arguments) to list all available targets.

### Building for Arty A7

For `debug` build:

```console
make arty_debug TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```

For `release` build:

```console
make arty_release TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```

You can omit `TOOLCHAIN_PREFIX` if you have added the RISC-V GNU Toolchain binaries to your `PATH`.

### Building for Cmod A7

For `debug` build:

```console
make cmod_debug TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```

For `release` build:

```console
make cmod_release TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```

You can omit `TOOLCHAIN_PREFIX` if you have added the RISC-V GNU Toolchain binaries to your `PATH`.