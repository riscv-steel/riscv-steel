set_property PACKAGE_PIN E3 [get_ports CLK]							
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports CLK]

set_property PACKAGE_PIN U9 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]

set_property PACKAGE_PIN D4 [get_ports UART_TX]						
set_property IOSTANDARD LVCMOS33 [get_ports UART_TX]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
