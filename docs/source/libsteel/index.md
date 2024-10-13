# LibSteel Documentation

## Introduction

LibSteel is a lightweight, header-only software library that provides a convenient API for controlling RISC-V Steel, making it easy to develop new software applications for it.

To integrate LibSteel into your project, simply include the `libsteel.h` header file in your application’s source code, as demonstrated in the example below:

=== "myapp.c"

    ```c
    #include "libsteel.h"

    void main(void)
    {
        // your app source code here
    }
    ```

## Compiling with LibSteel

#### Using the template projects

The provided [template projects](../userguide.md#building-the-application) are based on __CMake__ and are preconfigured to include LibSteel. If your application is based on one of these templates, follow the compilation instructions outlined in the [User Guide](../userguide.md).

#### Starting from scratch

If you are developing a new application from scratch, you will need to specify the path to the LibSteel header files when compiling with the RISC-V GCC compiler, using the `-I` option:

```bash
# Obtain LibSteel header files
git clone https://github.com/riscv-steel/libsteel /my/copy/of/libsteel

# Compile the application with RISC-V GCC
riscv32-unknown-elf-gcc myapp.c -I /my/copy/of/libsteel
```

</br>
</br>