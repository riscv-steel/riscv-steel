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
    ["../unit-tests/programs/add-01.hex",             "../unit-tests/references/add-01.reference.hex",              True,   ],
    ["../unit-tests/programs/addi-01.hex",            "../unit-tests/references/addi-01.reference.hex",             True,   ],
    ["../unit-tests/programs/and-01.hex",             "../unit-tests/references/and-01.reference.hex",              True,   ],
    ["../unit-tests/programs/andi-01.hex",            "../unit-tests/references/andi-01.reference.hex",             True,   ],
    ["../unit-tests/programs/auipc-01.hex",           "../unit-tests/references/auipc-01.reference.hex",            True,   ],
    ["../unit-tests/programs/beq-01.hex",             "../unit-tests/references/beq-01.reference.hex",              True,   ],
    ["../unit-tests/programs/bge-01.hex",             "../unit-tests/references/bge-01.reference.hex",              True,   ],
    ["../unit-tests/programs/bgeu-01.hex",            "../unit-tests/references/bgeu-01.reference.hex",             True,   ],
    ["../unit-tests/programs/blt-01.hex",             "../unit-tests/references/blt-01.reference.hex",              True,   ],
    ["../unit-tests/programs/bltu-01.hex",            "../unit-tests/references/bltu-01.reference.hex",             True,   ],
    ["../unit-tests/programs/bne-01.hex",             "../unit-tests/references/bne-01.reference.hex",              True,   ],
    ["../unit-tests/programs/ebreak.hex",             "../unit-tests/references/ebreak.reference.hex",              True,   ],
    ["../unit-tests/programs/ecall.hex",              "../unit-tests/references/ecall.reference.hex",               True,   ],
    ["../unit-tests/programs/fence-01.hex",           "../unit-tests/references/fence-01.reference.hex",            True,   ],
    ["../unit-tests/programs/jal-01.hex",             "../unit-tests/references/jal-01.reference.hex",              True,   ],
    ["../unit-tests/programs/jalr-01.hex",            "../unit-tests/references/jalr-01.reference.hex",             True,   ],
    ["../unit-tests/programs/lb-align-01.hex",        "../unit-tests/references/lb-align-01.reference.hex",         True,   ],
    ["../unit-tests/programs/lbu-align-01.hex",       "../unit-tests/references/lbu-align-01.reference.hex",        True,   ],
    ["../unit-tests/programs/lh-align-01.hex",        "../unit-tests/references/lh-align-01.reference.hex",         True,   ],
    ["../unit-tests/programs/lhu-align-01.hex",       "../unit-tests/references/lhu-align-01.reference.hex",        True,   ],
    ["../unit-tests/programs/lui-01.hex",             "../unit-tests/references/lui-01.reference.hex",              True,   ],
    ["../unit-tests/programs/lw-align-01.hex",        "../unit-tests/references/lw-align-01.reference.hex",         True,   ],
    ["../unit-tests/programs/misalign-lh-01.hex",     "../unit-tests/references/misalign-lh-01.reference.hex",      True,   ],
    ["../unit-tests/programs/misalign-lhu-01.hex",    "../unit-tests/references/misalign-lhu-01.reference.hex",     True,   ],
    ["../unit-tests/programs/misalign-lw-01.hex",     "../unit-tests/references/misalign-lw-01.reference.hex",      True,   ],
    ["../unit-tests/programs/misalign-sh-01.hex",     "../unit-tests/references/misalign-sh-01.reference.hex",      True,   ],
    ["../unit-tests/programs/misalign-sw-01.hex",     "../unit-tests/references/misalign-sw-01.reference.hex",      True,   ],
    ["../unit-tests/programs/or-01.hex",              "../unit-tests/references/or-01.reference.hex",               True,   ],
    ["../unit-tests/programs/ori-01.hex",             "../unit-tests/references/ori-01.reference.hex",              True,   ],
    ["../unit-tests/programs/sb-align-01.hex",        "../unit-tests/references/sb-align-01.reference.hex",         True,   ],
    ["../unit-tests/programs/sh-align-01.hex",        "../unit-tests/references/sh-align-01.reference.hex",         True,   ],
    ["../unit-tests/programs/sll-01.hex",             "../unit-tests/references/sll-01.reference.hex",              True,   ],
    ["../unit-tests/programs/slli-01.hex",            "../unit-tests/references/slli-01.reference.hex",             True,   ],
    ["../unit-tests/programs/slt-01.hex",             "../unit-tests/references/slt-01.reference.hex",              True,   ],
    ["../unit-tests/programs/slti-01.hex",            "../unit-tests/references/slti-01.reference.hex",             True,   ],
    ["../unit-tests/programs/sltiu-01.hex",           "../unit-tests/references/sltiu-01.reference.hex",            True,   ],
    ["../unit-tests/programs/sltu-01.hex",            "../unit-tests/references/sltu-01.reference.hex",             True,   ],
    ["../unit-tests/programs/sra-01.hex",             "../unit-tests/references/sra-01.reference.hex",              True,   ],
    ["../unit-tests/programs/srai-01.hex",            "../unit-tests/references/srai-01.reference.hex",             True,   ],
    ["../unit-tests/programs/srl-01.hex",             "../unit-tests/references/srl-01.reference.hex",              True,   ],
    ["../unit-tests/programs/srli-01.hex",            "../unit-tests/references/srli-01.reference.hex",             True,   ],
    ["../unit-tests/programs/sub-01.hex",             "../unit-tests/references/sub-01.reference.hex",              True,   ],
    ["../unit-tests/programs/sw-align-01.hex",        "../unit-tests/references/sw-align-01.reference.hex",         True,   ],
    ["../unit-tests/programs/xor-01.hex",             "../unit-tests/references/xor-01.reference.hex",              True,   ],
    ["../unit-tests/programs/xori-01.hex",            "../unit-tests/references/xori-01.reference.hex",             True,   ],
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


def run_sim(sim_path: str, prog_dir: str, prog_name: str, dump_dir: str, wave: bool):
    args = [f'{sim_path}',
            f'--ram-init-h32={prog_dir}/{prog_name}',
            f'--ram-dump-h32={dump_dir}/{prog_name}',
            f'--cycles={500000}',
            f'--wr-addr={0x00001000}']

    if wave:
        args.append(f'--out-wave={dump_dir}/{prog_name}.fst')

    with open(f'{dump_dir}/{prog_name}.log', 'w') as fd:
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
    if argv is None:
        argv = sys.argv[1:]

    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--sim',
                        type=str,
                        default='obj_dir/unit_tests',
                        help='Path to the simulator')

    parser.add_argument('--dump',
                        type=str,
                        default='dump',
                        help='Dump directory')

    parser.add_argument('--wave',
                        action='store_true',
                        help='Enable gen wave *.fst')

    args = parser.parse_args(argv)

    if not check_file(args.sim):
        print_status(scolor.NORMAL, f'Please build file: {args.sim}')
        return

    if not os.path.exists(args.dump):
        os.makedirs(args.dump)

    passed = 0
    skipped = 0
    failed = 0

    for item in unit_test:
        prog_path = item[prg_index]
        ref_path = item[ref_index]
        is_run = item[run_index]

        if not check_file(prog_path):
            continue

        if not is_run:
            skipped += 1
            print_status(scolor.SKIP, prog_path)
            continue

        prog_dir = Path(prog_path).parent
        prog_name = Path(prog_path).name
        dump_path = f'{args.dump}/{prog_name}'
        run_sim(sim_path=args.sim,
                prog_dir=prog_dir,
                prog_name=prog_name,
                dump_dir=args.dump,
                wave=args.wave)

        if not check_file(ref_path):
            continue

        if not check_file(dump_path):
            continue

        result, line, ref, dut = compare_dump(ref=ref_path, dut=dump_path)

        if not result:
            failed +=1
            print_status(scolor.FAIL, prog_path)
            print_status(scolor.NORMAL, f'-- Signature at line {line} differs from golden reference.')
            print_status(scolor.NORMAL, f'-- Signature: {hex(dut)}. Golden reference: {hex(ref)}')
        else:
            passed += 1
            print_status(scolor.PASS, prog_path)

    print_status(scolor.NORMAL, f'Total: passed {passed}, skipped {skipped}, failed {failed}')

    if passed == len(unit_test):
      print("------------------------------------------------------------------------------------------")
      print("RISC-V Steel Processor Core IP passed ALL unit tests from RISC-V Architectural Test")
      print("------------------------------------------------------------------------------------------")


if __name__ == "__main__":
    main()
