# Template Project for Software Development

This folder is intended to be used as a template for new software projects. It contains RISC-V Steel header files, boot code, linking scripts and an example source file that can be used as the starting point for development. Please check our [Software Guide](https://riscv-steel.github.io/riscv-steel/softwareguide/) for detailed information on software development for RISC-V Steel.

## Dependencies

To be able to build this project you need the [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain). Instructions on how to install it can be found in the [Software Guide](https://riscv-steel.github.io/riscv-steel/softwareguide/).

## How to build

For a `debug` build:

```console
make debug TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```

For a `release` build:

```console
make release TOOLCHAIN_PREFIX=/path/to/riscv/binaries/riscv32-unknown-elf-
```

You can omit `TOOLCHAIN_PREFIX` if you have added the RISC-V binaries to your `PATH`.
