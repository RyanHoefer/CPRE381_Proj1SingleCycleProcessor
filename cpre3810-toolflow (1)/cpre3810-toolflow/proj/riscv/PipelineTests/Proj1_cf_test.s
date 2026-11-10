
.data
.align 2

# Reserve 256 bytes for the stack.
stack:
    .space 256

stack_top:

.text
.globl main

main:
    # Initialize stack pointer to the end of our stack area.
    lui sp, 0x10010
    addi sp, sp, 256

    # Default result: failure.
    addi a0, x0, 0

    # --------------------------------------------------
    # Test BEQ
    # --------------------------------------------------
    addi t0, x0, 5
    addi t1, x0, 5

    beq t0, t1, beq_pass
    jal x0, done

beq_pass:
    # --------------------------------------------------
    # Test BNE
    # --------------------------------------------------
    addi t1, x0, 6

    bne t0, t1, bne_pass
    jal x0, done

bne_pass:
    # --------------------------------------------------
    # Test BLT (signed)
    # --------------------------------------------------
    addi t0, x0, -5
    addi t1, x0, 5

    blt t0, t1, blt_pass
    jal x0, done

blt_pass:
    # --------------------------------------------------
    # Test BGE (signed)
    # --------------------------------------------------
    bge t1, t0, bge_pass
    jal x0, done

bge_pass:
    # --------------------------------------------------
    # Test BLTU (unsigned)
    # --------------------------------------------------
    addi t0, x0, 3
    addi t1, x0, 9

    bltu t0, t1, bltu_pass
    jal x0, done

bltu_pass:
    # --------------------------------------------------
    # Test BGEU (unsigned)
    # --------------------------------------------------
    bgeu t1, t0, bgeu_pass
    jal x0, done

bgeu_pass:
    # --------------------------------------------------
    # Test nested function calls
    # --------------------------------------------------

    # s0 counts how many functions were entered.
    addi s0, x0, 0

    # Save original stack pointer for verification.
    add s1, sp, x0

    # Call function1.
    jal ra, function1

    # Verify all five functions executed.
    addi t0, x0, 5
    bne s0, t0, done

    # Verify stack pointer was restored.
    bne sp, s1, done

    # All tests passed.
    addi a0, x0, 1
    jal x0, done

# --------------------------------------------------
# Function 1
# --------------------------------------------------
function1:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1

    jal ra, function2

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# --------------------------------------------------
# Function 2
# --------------------------------------------------
function2:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1

    jal ra, function3

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# --------------------------------------------------
# Function 3
# --------------------------------------------------
function3:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1

    jal ra, function4

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# --------------------------------------------------
# Function 4
# --------------------------------------------------
function4:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1

    jal ra, function5

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# --------------------------------------------------
# Function 5
# --------------------------------------------------
function5:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi s0, s0, 1

    # Deepest call reached.
    # Return to function4.

    lw ra, 12(sp)
    addi sp, sp, 16
    jalr x0, 0(ra)

# --------------------------------------------------
# End program
# --------------------------------------------------
done:
    wfi
