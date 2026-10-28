
.data
.align 2

# Test memory
test_data:
    .word 0x12345678
    .word -1
    .word 0
    .word 0

.text
.globl main

main:
    # Failure by default
    addi a0, x0, 0

    # Memory base address
    lui s0, 0x10010

    # ------------------------------------------
    # Arithmetic and logic
    # ------------------------------------------

    addi t0, x0, 20
    addi t1, x0, 6

    add t2, t0, t1
    addi t3, x0, 26
    bne t2, t3, fail

    sub t2, t0, t1
    addi t3, x0, 14
    bne t2, t3, fail

    and t2, t0, t1
    addi t3, x0, 4
    bne t2, t3, fail

    or t2, t0, t1
    addi t3, x0, 22
    bne t2, t3, fail

    xor t2, t0, t1
    addi t3, x0, 18
    bne t2, t3, fail

    andi t2, t0, 15
    addi t3, x0, 4
    bne t2, t3, fail

    ori t2, t1, 8
    addi t3, x0, 14
    bne t2, t3, fail

    xori t2, t0, 7
    addi t3, x0, 19
    bne t2, t3, fail

    # ------------------------------------------
    # Shifts
    # ------------------------------------------

    slli t2, t1, 2
    addi t3, x0, 24
    bne t2, t3, fail

    srli t2, t0, 2
    addi t3, x0, 5
    bne t2, t3, fail

    addi t4, x0, -20

    srai t2, t4, 2
    addi t3, x0, -5
    bne t2, t3, fail

    addi t5, x0, 2

    sll t2, t1, t5
    addi t3, x0, 24
    bne t2, t3, fail

    srl t2, t0, t5
    addi t3, x0, 5
    bne t2, t3, fail

    sra t2, t4, t5
    addi t3, x0, -5
    bne t2, t3, fail

    # ------------------------------------------
    # Comparisons
    # ------------------------------------------

    slt t2, t1, t0
    addi t3, x0, 1
    bne t2, t3, fail

    sltu t2, t1, t0
    bne t2, t3, fail

    slti t2, t1, 10
    bne t2, t3, fail

    sltiu t2, t1, 10
    bne t2, t3, fail

    # Signed vs unsigned comparison
    slt t2, t4, t0
    bne t2, t3, fail

    sltu t2, t4, t0
    bne t2, x0, fail

    # ------------------------------------------
    # LUI and AUIPC
    # ------------------------------------------

    lui s1, 0x12345
    lui t3, 0x12345
    bne s1, t3, fail

    # AUIPC should give PC + 0x1000
    auipc s2, 1
    lui t3, 1
    sub t2, s2, t3

    # Check recovered PC is aligned
    andi t2, t2, 3
    bne t2, x0, fail

    # ------------------------------------------
    # Word memory operations
    # ------------------------------------------

    lw t2, 0(s0)
    lui t3, 0x12345
    addi t3, t3, 0x678
    bne t2, t3, fail

    addi t2, x0, 99
    sw t2, 8(s0)
    lw t3, 8(s0)
    bne t2, t3, fail

    # ------------------------------------------
    # Byte loads: LB and LBU
    # ------------------------------------------

    addi t2, x0, -1
    sb t2, 12(s0)

    lb t3, 12(s0)
    bne t3, t2, fail

    lbu t3, 12(s0)
    addi t4, x0, 255
    bne t3, t4, fail

    # ------------------------------------------
    # Halfword loads: LH and LHU
    # ------------------------------------------

    addi t2, x0, -1
    sh t2, 14(s0)

    lh t3, 14(s0)
    bne t3, t2, fail

    lhu t3, 14(s0)
    lui t4, 0x10
    addi t4, t4, -1
    bne t3, t4, fail

    # ------------------------------------------
    # Branch instructions
    # ------------------------------------------

    addi t0, x0, 5
    addi t1, x0, 5

    beq t0, t1, beq_ok
    jal x0, fail

beq_ok:
    addi t1, x0, 6
    bne t0, t1, bne_ok
    jal x0, fail

bne_ok:
    addi t0, x0, -5
    addi t1, x0, 5
    blt t0, t1, blt_ok
    jal x0, fail

blt_ok:
    bge t1, t0, bge_ok
    jal x0, fail

bge_ok:
    addi t0, x0, 3
    addi t1, x0, 9
    bltu t0, t1, bltu_ok
    jal x0, fail

bltu_ok:
    bgeu t1, t0, bgeu_ok
    jal x0, fail

bgeu_ok:
    # ------------------------------------------
    # JAL and JALR
    # ------------------------------------------

    jal ra, test_function

    # Function should set s3 = 42
    addi t0, x0, 42
    bne s3, t0, fail

    # ------------------------------------------
    # Register dependency chain
    # ------------------------------------------

    addi t0, x0, 10
    addi t1, x0, 20

    add t2, t0, t1
    sub t3, t2, t0
    xor t4, t3, t1

    bne t4, x0, fail

    # All checks passed
    addi a0, x0, 1
    jal x0, done

test_function:
    addi s3, x0, 42
    jalr x0, 0(ra)

fail:
    addi a0, x0, 0

done:
    wfi
