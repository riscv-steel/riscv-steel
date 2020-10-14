# Getting started

To start using Steel, follow these steps:

1. Import all files inside the **rtl** directory into your project
2. Instantiate the core into a Verilog/SystemVerilog module (an instantiation template is provided below)
3. Connect Steel to a clock source, a reset signal and memory. There is an interface to fetch instructions and another to read/write data, so we recommend a dual-port memory

There are also interfaces to request for interrupts and to update the time register. The signals of these interfaces must be hardwired to zero if unused.

```verilog
steel_top #(

    // You must provide a 32-bit value. If omitted the boot address is set to 0x00000000
    // ---------------------------------------------------------------------------------

    .BOOT_ADDRESS() 
                  
    ) core (    
    
    // Clock source and reset
    // ---------------------------------------------------------------------------------
    
    .CLK(),         // System clock (input, required, 1-bit)
    .RESET(),       // System reset (input, required, 1-bit, synchronous, active high)

    // Instruction fetch interface
    // ---------------------------------------------------------------------------------
    .I_ADDR(),      // Instruction address (output, 32-bit)
    .INSTR(),       // Instruction data (input, required, 32-bit)
    
    // Data read/write interface
    // ---------------------------------------------------------------------------------

    .D_ADDR(),      // Data address (output, 32-bit)    
    .DATA_IN(),     // Data read from memory (input, required, 32-bit)
    .DATA_OUT(),    // Data to write into memory (output, 32-bit)
    .WR_REQ(),      // Write enable (output, 1-bit)
    .WR_MASK(),     // Write byte mask (output, 4-bit)
    
    // Interrupt request interface (hardwire to zero if unused)
    // ---------------------------------------------------------------------------------
    
    .E_IRQ(),       // External interrupt request (optional, active high, 1-bit)
    .T_IRQ(),       // Timer interrupt request (optional, active high, 1-bit)
    .S_IRQ()        // Software interrupt request (optional, active high, 1-bit)

    // Time register update interface (hardwire to zero if unused)
    // ---------------------------------------------------------------------------------

    .REAL_TIME(),   // Value read from a real-time counter (optional, 64-bit)
    
);
```

Read the section [I/O signals](steelio.md) for more information about the signals above.
