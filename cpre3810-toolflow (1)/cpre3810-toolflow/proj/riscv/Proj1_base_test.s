
.data
.align 2

.text
.globl main

main:
    # Default result: failure
    addi a0, x0, 0

    # Initialize registers
    addi x1, x0, 20
    addi x2, x0, 6

    # ADD: 20 + 6 = 26
    add x3, x1, x2
    addi t0, x0, 26
    bne x3, t0, done

    # SUB: 20 - 6 = 14
    sub x4, x1, x2
    addi t0, x0, 14
    bne x4, t0, done

    # AND: 20 & 6 = 4
    and x5, x1, x2
    addi t0, x0, 4
    bne x5, t0, done

    # OR: 20 | 6 = 22
    or x6, x1, x2
    addi t0, x0, 22
    bne x6, t0, done

    # XOR: 20 ^ 6 = 18
    xor x7, x1, x2
    addi t0, x0, 18
    bne x7, t0, done

    # ANDI: 20 & 15 = 4
    andi x8, x1, 15
    addi t0, x0, 4
    bne x8, t0, done

    # ORI: 6 | 8 = 14
    ori x9, x2, 8
    addi t0, x0, 14
    bne x9, t0, done

    # XORI: 20 ^ 7 = 19
    xori x10, x1, 7
    addi t0, x0, 19
    bne x10, t0, done

    # SLLI: 6 << 2 = 24
    slli x11, x2, 2
    addi t0, x0, 24
    bne x11, t0, done

    # SRLI: 20 >> 2 = 5
    srli x12, x1, 2
    addi t0, x0, 5
    bne x12, t0, done

    # SRAI: arithmetic shift of -20
    addi t1, x0, -20
    srai x13, t1, 2
    addi t0, x0, -5
    bne x13, t0, done

    # Register-based shifts
    addi t2, x0, 2

    # SLL: 6 << 2 = 24
    sll x14, x2, t2
    addi t0, x0, 24
    bne x14, t0, done

    # SRL: 20 >> 2 = 5
    srl x15, x1, t2
    addi t0, x0, 5
    bne x15, t0, done

    # SRA: -20 >> 2 = -5
    sra x16, t1, t2
    addi t0, x0, -5
    bne x16, t0, done

    # SLT: signed comparison 6 < 20
    slt x17, x2, x1
    addi t0, x0, 1
    bne x17, t0, done

    # SLTU: unsigned comparison 6 < 20
    sltu x18, x2, x1
    addi t0, x0, 1
    bne x18, t0, done

    # SLTI: signed comparison 6 < 10
    slti x19, x2, 10
    addi t0, x0, 1
    bne x19, t0, done

    # SLTIU: unsigned comparison 6 < 10
    sltiu x20, x2, 10
    addi t0, x0, 1
    bne x20, t0, done

    # LUI: load upper immediate
    lui x21, 0x12345
    lui t0, 0x12345
    bne x21, t0, done

    # AUIPC: result = current PC + 0x1000
    # Subtract 0x1000 to recover the instruction PC.
    auipc x22, 0x1
    lui t0, 0x1
    sub t3, x22, t0

    # Confirm recovered PC is word-aligned
    andi t4, t3, 3
    bne t4, x0, done

    # Register dependency tests
    add x23, x3, x4
    addi t0, x0, 40
    bne x23, t0, done

    sub x24, x23, x2
    addi t0, x0, 34
    bne x24, t0, done

    xor x25, x24, x1
    addi t0, x0, 54
    bne x25, t0, done

    # All tests passed
    addi a0, x0, 1

done:
    wfi
