# Configuration

Steel has only one configuration parameter, the boot address, which is the address of the first instruction the core will fetch after reset. It is defined when instantiating Steel (read the section [Getting Started](getting.md)). If you omit this parameter at instantiation, the boot address will be set to its default value, **32'h00000000**.
