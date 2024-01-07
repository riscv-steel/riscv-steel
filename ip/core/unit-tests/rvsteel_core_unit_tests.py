import os
import sys
import argparse
import subprocess
from pathlib import Path


class scolor:
    NORMAL  = '\033[0m'
    PASS    = '\033[32m'
    SKIP    = '\033[33m'
    FAIL    = '\033[31m'


prg_index = 0
ref_index = 1
run_index = 2


unit_test = [
    ["programs/add-01.hex",             "references/add-01.reference.hex",              True,   ],
    ["programs/addi-01.hex",            "references/addi-01.reference.hex",             True,   ],
    ["programs/and-01.hex",             "references/and-01.reference.hex",              True,   ],
    ["programs/andi-01.hex",            "references/andi-01.reference.hex",             True,   ],
    ["programs/auipc-01.hex",           "references/auipc-01.reference.hex",            True,   ],
    ["programs/beq-01.hex",             "references/beq-01.reference.hex",              True,   ],
    ["programs/bge-01.hex",             "references/bge-01.reference.hex",              True,   ],
    ["programs/bgeu-01.hex",            "references/bgeu-01.reference.hex",             True,   ],
    ["programs/blt-01.hex",             "references/blt-01.reference.hex",              True,   ],
    ["programs/bltu-01.hex",            "references/bltu-01.reference.hex",             True,   ],
    ["programs/bne-01.hex",             "references/bne-01.reference.hex",              True,   ],
    ["programs/ebreak.hex",             "references/ebreak.reference.hex",              True,   ],
    ["programs/ecall.hex",              "references/ecall.reference.hex",               True,   ],
    ["programs/fence-01.hex",           "references/fence-01.reference.hex",            True,   ],
    ["programs/jal-01.hex",             "references/jal-01.reference.hex",              True,   ],
    ["programs/jalr-01.hex",            "references/jalr-01.reference.hex",             True,   ],
    ["programs/lb-align-01.hex",        "references/lb-align-01.reference.hex",         True,   ],
    ["programs/lbu-align-01.hex",       "references/lbu-align-01.reference.hex",        True,   ],
    ["programs/lh-align-01.hex",        "references/lh-align-01.reference.hex",         True,   ],
    ["programs/lhu-align-01.hex",       "references/lhu-align-01.reference.hex",        True,   ],
    ["programs/lui-01.hex",             "references/lui-01.reference.hex",              True,   ],
    ["programs/lw-align-01.hex",        "references/lw-align-01.reference.hex",         True,   ],
    ["programs/misalign-lh-01.hex",     "references/misalign-lh-01.reference.hex",      True,   ],
    ["programs/misalign-lhu-01.hex",    "references/misalign-lhu-01.reference.hex",     True,   ],
    ["programs/misalign-lw-01.hex",     "references/misalign-lw-01.reference.hex",      True,   ],
    ["programs/misalign-sh-01.hex",     "references/misalign-sh-01.reference.hex",      True,   ],
    ["programs/misalign-sw-01.hex",     "references/misalign-sw-01.reference.hex",      True,   ],
    ["programs/or-01.hex",              "references/or-01.reference.hex",               True,   ],
    ["programs/ori-01.hex",             "references/ori-01.reference.hex",              True,   ],
    ["programs/sb-align-01.hex",        "references/sb-align-01.reference.hex",         True,   ],
    ["programs/sh-align-01.hex",        "references/sh-align-01.reference.hex",         True,   ],
    ["programs/sll-01.hex",             "references/sll-01.reference.hex",              True,   ],
    ["programs/slli-01.hex",            "references/slli-01.reference.hex",             True,   ],
    ["programs/slt-01.hex",             "references/slt-01.reference.hex",              True,   ],
    ["programs/slti-01.hex",            "references/slti-01.reference.hex",             True,   ],
    ["programs/sltiu-01.hex",           "references/sltiu-01.reference.hex",            True,   ],
    ["programs/sltu-01.hex",            "references/sltu-01.reference.hex",             True,   ],
    ["programs/sra-01.hex",             "references/sra-01.reference.hex",              True,   ],
    ["programs/srai-01.hex",            "references/srai-01.reference.hex",             True,   ],
    ["programs/srl-01.hex",             "references/srl-01.reference.hex",              True,   ],
    ["programs/srli-01.hex",            "references/srli-01.reference.hex",             True,   ],
    ["programs/sub-01.hex",             "references/sub-01.reference.hex",              True,   ],
    ["programs/sw-align-01.hex",        "references/sw-align-01.reference.hex",         True,   ],
    ["programs/xor-01.hex",             "references/xor-01.reference.hex",              True,   ],
    ["programs/xori-01.hex",            "references/xori-01.reference.hex",             True,   ],
]


def print_status(clr: scolor, text: str):
    if clr == scolor.NORMAL:
        print(f'{clr}{text}')

    if clr == scolor.PASS:
        print(f'{scolor.NORMAL}TEST {clr}PASS {scolor.NORMAL}: {text}')

    if clr == scolor.SKIP:
        print(f'{scolor.NORMAL}TEST {clr}SKIP {scolor.NORMAL}: {text}')

    if clr == scolor.FAIL:
        print(f'{scolor.NORMAL}TEST {clr}FAIL {scolor.NORMAL}: {text}')


def check_file(path: str):
    if not os.path.isfile(path):
        print_status(scolor.NORMAL, f'No such file or directory: {path}')
        return False
    return True


def run_sim(prog: str, sim: str, dump: str, log: str):
    args = [f'{sim}',
            f'--ram-init-h32={prog}',
            f'--ram-dump-h32={dump}',
            f'--cycles={500000}',
            f'--wr-addr={0x00001000}']

    with open(log, 'w') as fd:
        subprocess.run(args, stdout=fd)


def compare_dump(ref: str, dut: str):
    with open(ref, mode='r', encoding='utf-8') as ref_file:
        with open(dut, mode='r', encoding='utf-8') as dut_file:
            line = 0
            while True:
                line += 1

                str_ref = ref_file.readline()
                str_dut = dut_file.readline()

                if not str_ref or not str_dut:
                    return (True, line, 0, 0)

                int_ref = int(str_ref, 16)
                int_dut = int(str_dut, 16)

                if int_ref != int_dut:
                    return (False, line, int_ref, int_dut)


def main(argv=None):
    sim_path = '../rvsteel-sim-verilator/obj_dir/rvsteel_sim_verilator'
    sim_dump_dir = 'dump'

    if not check_file(sim_path):
        print_status(scolor.NORMAL, f'Please build file: {sim_path}')

    if not os.path.exists(sim_dump_dir):
        os.makedirs(sim_dump_dir)

    passed = 0
    skipped = 0
    failed = 0

    for item in unit_test:
        prog_name = item[prg_index]

        if not check_file(prog_name):
            continue

        if not item[run_index]:
            skipped += 1
            print_status(scolor.SKIP, prog_name)
            continue

        sim_dump_path = f'{sim_dump_dir}/{Path(prog_name).stem}.dump.hex'
        sim_log_path = f'{sim_dump_dir}/{Path(prog_name).stem}.log'
        run_sim(prog=item[prg_index], sim=sim_path, dump=sim_dump_path, log=sim_log_path)

        if not check_file(item[ref_index]):
            continue

        if not check_file(sim_dump_path):
            continue

        result, line, ref, dut = compare_dump(ref=item[ref_index], dut=sim_dump_path)

        if not result:
            failed +=1
            print_status(scolor.FAIL, prog_name)
            print_status(scolor.NORMAL, f'-- Signature at line {line} differs from golden reference.')
            print_status(scolor.NORMAL, f'-- Signature: {hex(dut)}. Golden reference: {hex(ref)}')
        else:
            passed += 1
            print_status(scolor.PASS, prog_name)

    print_status(scolor.NORMAL, f'Total: passed {passed}, skipped {skipped}, failed {failed}')


if __name__ == "__main__":
    main()



