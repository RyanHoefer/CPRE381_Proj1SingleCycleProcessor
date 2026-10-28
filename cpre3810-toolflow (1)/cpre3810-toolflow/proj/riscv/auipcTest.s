.text
.globl main

main:
    auipc x1, 0x00000     # x1 = P, address of this instruction
    auipc x2, 0x00001     # x2 = P + 4 + 4096
    auipc x3, 0xFFFFF     # x3 = P + 8 - 4096

    sub   x4, x2, x1
    sub   x5, x3, x1

    # Expected:
    # x4 = 0x00001004
    # x5 = 0xFFFFF008

    wfi