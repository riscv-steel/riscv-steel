# Adding a new device

???+ info

    The new device needs to implement the [Memory Interface](core-reference.md#memory-interface) requirements. Check it out for more information.

The bus multiplexer module is originally written to accomodate 2 subordinate devices, but more can be added. The Verilog code to add new devices to the system was left as comments in the source code of **`bus-mux.v`** and **`rvsteel-soc.v`**. You only need to uncomment the code.

For example, to add a third device to the system, open **`bus-mux.v`** and search for the following code:

``` systemverilog
module bus_mux #(

  parameter DEVICE0_START_ADDRESS = 32'h00000000,
  parameter DEVICE0_FINAL_ADDRESS = 32'h7fffffff,
  parameter DEVICE1_START_ADDRESS = 32'h80000000,
  parameter DEVICE1_FINAL_ADDRESS = 32'hffffffff

  /* Uncomment to add new devices

  Read RISC-V Steel SoC Reference Guide for more information:
  https://riscv-steel.github.io/riscv-steel/soc-reference/#adding-a-new-device

  parameter DEVICE2_START_ADDRESS = 32'hdeadbeef,
  parameter DEVICE2_FINAL_ADDRESS = 32'hdeadbeef,
  
  parameter DEVICE3_START_ADDRESS = 32'hdeadbeef,
  parameter DEVICE3_FINAL_ADDRESS = 32'hdeadbeef
  
  */

  )
```

To add a third device, put the `DEVICE2_*` parameters out of the comment section and assign a memory region for the new device:

``` systemverilog
module bus_mux #(

  parameter DEVICE0_START_ADDRESS = 32'h00000000,
  parameter DEVICE0_FINAL_ADDRESS = 32'h7fffffff,
  parameter DEVICE1_START_ADDRESS = 32'h80000000,
  parameter DEVICE1_FINAL_ADDRESS = 32'hffffffff,
  parameter DEVICE2_START_ADDRESS = 32'hAbCdEfAb, // example
  parameter DEVICE2_FINAL_ADDRESS = 32'hFaBcDeFa  // example

  /* Uncomment to add new devices

  Read RISC-V Steel SoC Reference Guide for more information:
  https://riscv-steel.github.io/riscv-steel/soc-reference/#adding-a-new-device  
  
  parameter DEVICE3_START_ADDRESS = 32'hdeadbeef,
  parameter DEVICE3_FINAL_ADDRESS = 32'hdeadbeef
  
  */

  )
```

All code that needs to be uncommented is in the following format:
``` systemverilog
  /* Uncomment to add new devices

  ... code ...

  */
```

After uncommenting the required code (both in **`bus-mux.v`** and **`rvsteel-soc.v`**), instantiate the new device in **`rvsteel-soc.v`**:

``` systemverilog

  mydevice
  mydevice_instance (

    ... device signals ...

    .mydevice_address           (device2_mem_address           ),
    .mydevice_read_data         (device2_mem_read_data         ),
    .mydevice_read_request      (device2_mem_read_request      ),
    .mydevice_read_request_ack  (device2_mem_read_request_ack  ),
    .mydevice_write_data        (device2_mem_write_data        ),
    .mydevice_write_request     (device2_mem_write_request     ),
    .mydevice_write_request_ack (device2_mem_write_request_ack )

  );

```

</br>
</br>
</br>
</br>
</br>