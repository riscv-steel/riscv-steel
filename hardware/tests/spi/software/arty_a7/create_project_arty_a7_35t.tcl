cd [file normalize [file dirname [info script]]]
set memory_init_files {../build/unit_tests.hex}
create_project vivado_project ./vivado_project -part xc7a35ticsg324-1L -force
set_property simulator_language Verilog [current_project]
add_files -fileset constrs_1 -norecurse { ./unit_tests_constraints.xdc }
add_files -norecurse $memory_init_files
add_files -norecurse {./unit_tests.v ../../../../rvsteel_core.v ../../../../rvsteel.v ../../../../rvsteel_uart.v ../../../../rvsteel_ram.v ../../../../rvsteel_spi.v ../../../../rvsteel_bus.v ../../../../rvsteel_gpio.v ../../../../rvsteel_mtimer.v }
set_property file_type {Memory Initialization Files} [get_files $memory_init_files]
set_msg_config -suppress -id {Synth 8-7080}
set_msg_config -suppress -id {Power 33-332}
set_msg_config -suppress -id {Pwropt 34-321}
set_msg_config -suppress -id {Synth 8-6841}
set_msg_config -suppress -id {Netlist 29-101}
set_msg_config -suppress -id {Device 21-9320} 
set_msg_config -suppress -id {Device 21-2174}