# System bus

The `rtl/sys_bus.v` module allows you to connect a different number of slave devices to one host.

### Instantiation template

Below is a template for connecting one `ram` device to the host.

In the example, the local parameter `NUM_DEVICE` sets the number of devices connected to the bus, and the parameter `D_RAM` is the device index (example the conditional ram).

The base address of the device is specified in `addr_base`, and the maximum addressable space is specified by the mask `addr_mask`.

```verilog
localparam NUM_DEVICE   = 'd1;
localparam D_RAM        = 'd0;

// Host
wire    [31:0]  rw_address      ;
wire    [31:0]  read_data       ;
wire            read_request    ;
wire            read_response   ;
wire    [31:0]  write_data      ;
wire    [3:0 ]  write_strobe    ;
wire            write_request   ;
wire            write_response  ;

// Device
wire    [NUM_DEVICE*32-1:0] device_rw_address       ;
wire    [NUM_DEVICE*32-1:0] device_read_data        ;
wire    [NUM_DEVICE-1:0]    device_read_request     ;
wire    [NUM_DEVICE-1:0]    device_read_response    ;
wire    [NUM_DEVICE*32-1:0] device_write_data       ;
wire    [NUM_DEVICE*4-1:0]  device_write_strobe     ;
wire    [NUM_DEVICE-1:0]    device_write_request    ;
wire    [NUM_DEVICE-1:0]    device_write_response   ;

// Base and mask
wire    [NUM_DEVICE*32-1:0] addr_base               ;
wire    [NUM_DEVICE*32-1:0] addr_mask               ;

// 8192 KB
assign addr_base[32*D_RAM +: 32]    =  32'h0000_0000;
assign addr_mask[32*D_RAM +: 32]    = ~32'h7F_FFFF;

sys_bus #
(
    .NUM_DEVICE(NUM_DEVICE)
)
sys_bus_impl
(
    .clock_i(clock_i),
    .reset_i(reset_i),

    // Host
    .host_rw_address_i          (rw_address             ),
    .host_read_data_o           (read_data              ),
    .host_read_request_i        (read_request           ),
    .host_read_response_o       (read_response          ),
    .host_write_data_i          (write_data             ),
    .host_write_strobe_i        (write_strobe           ),
    .host_write_request_i       (write_request          ),
    .host_write_response_o      (write_response         ),

    // Devices
    .device_rw_address_o        (device_rw_address      ),
    .device_read_data_i         (device_read_data       ),
    .device_read_request_o      (device_read_request    ),
    .device_read_response_i     (device_read_response   ),
    .device_write_data_o        (device_write_data      ),
    .device_write_strobe_o      (device_write_strobe    ),
    .device_write_request_o     (device_write_request   ),
    .device_write_response_i    (device_write_response  ),

    // Devices address base and mask
    .addr_base                  (addr_base              ),
    .addr_mask                  (addr_mask              )
);

ram ram_instance
(
    ...
    .rw_address     (device_rw_address      [32*D_RAM +: 32]    ),
    .read_data      (device_read_data       [32*D_RAM +: 32]    ),
    .read_request   (device_read_request    [D_RAM]             ),
    .read_response  (device_read_response   [D_RAM]             ),
    .write_data     (device_write_data      [32*D_RAM +: 32]    ),
    .write_strobe   (device_write_strobe    [4*D_RAM +: 4]      ),
    .write_request  (device_write_request   [D_RAM]             ),
    .write_response (device_write_response  [D_RAM]             )
);

```