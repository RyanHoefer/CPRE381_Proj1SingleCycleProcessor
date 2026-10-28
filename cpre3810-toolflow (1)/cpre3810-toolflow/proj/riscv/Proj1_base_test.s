
.data

.text
.globl main

main:
    # Initialize registers
    addi x1, x0, 20
    addi x2, x0, 6

    # Addition and subtraction
    add  x3, x1, x2       # x3 = 26
    sub  x4, x1, x2       # x4 = 14

    # Logical operations
    and  x5, x1, x2       # x5 = 4
    or   x6, x1, x2       # x6 = 22
    xor  x7, x1, x2       # x7 = 18

    # Immediate logical operations
    andi x8, x1, 15       # x8 = 4
    ori  x9, x2, 8        # x9 = 14
    xori x10, x1, 7       # x10 = 19

    # Shift operations
    slli x11, x2, 2       # x11 = 24
    srli x12, x1, 2       # x12 = 5
    srai x13, x1, 2       # x13 = 5

    # Register-based shifts
    sll  x14, x2, x2      # x14 = 384
    srl  x15, x1, x2      # x15 = 0
    sra  x16, x1, x2      # x16 = 0

    # Comparisons
    slt  x17, x2, x1      # x17 = 1
    sltu x18, x2, x1      # x18 = 1
    slti x19, x2, 10      # x19 = 1
    sltiu x20, x2, 10     # x20 = 1

    # Test register dependencies
    add  x21, x3, x4      # x21 = 40
    sub  x22, x21, x2     # x22 = 34
    xor  x23, x22, x1     # x23 = 54

    # End program (WFI)
    .word 0x10500073
