# MCU Simulations

## How do I run the simulation?

### Using Verilator

To run the simulation using Verilator do:

```bash
cd verilator
make # build MCU verilator
make run RUN_FLAGS="--log-level=QUIET" # running the simulation
```

For the available options run:

```bash
make run RUN_FLAGS="--help"
```

> Verilator version 5.0 or higher is required.
