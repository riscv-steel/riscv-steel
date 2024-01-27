cd [file normalize [file dirname [info script]]]
create_project hello-world-cmod-a7 ./hello-world-cmod-a7 -part xc7a35tcpg236-1 -force
set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ./hello-world-cmod-a7-constraints.xdc }
add_files -norecurse { ./hello-world-cmod-a7.v ../../ip/core/rvsteel_core.v ../../ip/soc/ram_memory.v ../../ip/soc/rvsteel_soc.v ../../ip/soc/system_bus.v ../../ip/soc/uart.v ../software/build/hello-world.hex }
set_property file_type {Memory Initialization Files} [get_files ../software/build/hello-world.hex]