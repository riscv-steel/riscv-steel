#!/bin/bash
cd "$(dirname "$0")"
verilator --cc --exe --build -j $(nproc) rvsteel_core_unit_tests_verilator.v rvsteel_core_unit_tests_verilator.cpp -I../../../ip/core/ -I../../../ip/soc/ --Mdir verilated --prefix run
exec ./verilated/run