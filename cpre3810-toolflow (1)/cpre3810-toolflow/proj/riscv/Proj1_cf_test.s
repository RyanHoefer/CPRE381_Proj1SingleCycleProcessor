
.data
.align 2

.text
.globl main

main:
    # Default result: failure
    addi a0, x0, 0

    # Initialize stack pointer
    lui sp, 0x10010
    addi sp, sp, 2047

    # Test BEQ (taken)
    addi t0, x0, 5
    addi t1, x0, 5
    beq t0, t1, beq_pass
    jal x0, done

beq_pass:
    # Test BNE (taken)
    addi t1, x0, 6
    bne t0, t1, bne_pass
    jal x0, done

bne_pass:
    # Test BLT (signed)
    addi t0, x0, -5
    addi t1, x0, 5
    blt t0, t1, blt_pass
    jal x0, done

blt_pass:
    # Test BGE (signed)
    bge t1, t0, bge_pass
    jal x0, done

bge_pass:
    # Test BLTU (unsigned)
    addi t0, x0, 3
    addi t1, x0, 9
    bltu t0, t1, bltu_pass
    jal x0, done

bltu_pass:
    # Test BGEU (unsigned)
    bgeu t1, t0, bgeu_pass
    jal x0, done

bgeu_pass:
    # Call first function
    jal ra, function1

    # Check nested call result
    addi t0, x0, 5
    bne s0, t0, done

    # All tests passed
    addi a0, x0, 1
    jal x0, done

# Function 1
function1:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, x0, 1
    jal ra, function2

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# Function 2
function2:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1
    jal ra, function3

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# Function 3
function3:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1
    jal ra, function4

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# Function 4
function4:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1
    jal ra, function5

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# Function 5
function5:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

done:
    wfi
