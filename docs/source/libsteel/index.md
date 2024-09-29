# LibSteel Documentation

## Introduction

LibSteel is a header-only software library providing an API for controlling RISC-V Steel, making it easy to develop new software applications for it.

To use LibSteel you only need to include a single header file, `libsteel.h`, in the source code of your application. For example:

=== "myapp.c"

    ```c
    #include "libsteel.h"

    void main(void)
    {
        // your app source code here
    }
    ```

## Compiling with LibSteel

#### Template projects

The [template projects](../userguide.md#building-the-application) are based on CMake and are already configured to include LibSteel. If you start a new application from them, just compile the application as instructed in the [User Guide](../userguide.md), i.e. running `make`.

#### From scratch

In case you started a new application from scratch, you need to provide the path to LibSteel header files to RISC-V GCC using the `-I` switch. For example:

```bash
# Obtain LibSteel header files
git clone https://github.com/riscv-steel/libsteel /my/copy/of/libsteel

# Compile the application with RISC-V GCC
riscv32-unknown-elf-gcc myapp.c -I /my/copy/of/libsteel
```

</br>
</br>