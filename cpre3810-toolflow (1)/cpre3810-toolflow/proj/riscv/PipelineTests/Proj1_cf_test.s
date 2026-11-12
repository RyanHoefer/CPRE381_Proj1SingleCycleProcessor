
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
    nop
    nop
    addi sp, sp, 256

    # Default result: failure.
    addi a0, x0, 0

    # --------------------------------------------------
    # Test BEQ
    # --------------------------------------------------
    addi t0, x0, 5
    addi t1, x0, 5
    nop
    nop

    beq t0, t1, beq_pass
    nop
    nop
    jal x0, done
    nop
    nop

beq_pass:
    # --------------------------------------------------
    # Test BNE
    # --------------------------------------------------
    addi t1, x0, 6
    nop
    nop

    bne t0, t1, bne_pass
    nop
    nop
    jal x0, done
    nop
    nop

bne_pass:
    # --------------------------------------------------
    # Test BLT (signed)
    # --------------------------------------------------
    nop
    addi t0, x0, -5
    addi t1, x0, 5
    nop
    nop

    blt t0, t1, blt_pass
    nop
    nop
    jal x0, done
    nop
    nop

blt_pass:
    # --------------------------------------------------
    # Test BGE (signed)
    # --------------------------------------------------
    bge t1, t0, bge_pass
    nop
    nop
    jal x0, done
    nop
    nop

bge_pass:
    # --------------------------------------------------
    # Test BLTU (unsigned)
    # --------------------------------------------------
    addi t0, x0, 3
    addi t1, x0, 9
    nop
    nop

    bltu t0, t1, bltu_pass
    nop
    nop
    jal x0, done
    nop
    nop

bltu_pass:
    # --------------------------------------------------
    # Test BGEU (unsigned)
    # --------------------------------------------------
    bgeu t1, t0, bgeu_pass
    nop
    nop
    jal x0, done
    nop
    nop

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
    nop
    nop

    # Verify all five functions executed.
    addi t0, x0, 5
    nop
    nop
    bne s0, t0, done
    nop
    nop

    # Verify stack pointer was restored.
    bne sp, s1, done
    nop
    nop

    # All tests passed.
    addi a0, x0, 1
    jal x0, done
    nop
    nop

# --------------------------------------------------
# Function 1
# --------------------------------------------------
function1:
    addi sp, sp, -16
    nop
    nop
    sw ra, 12(sp)
    nop

    addi s0, s0, 1

    jal ra, function2
    nop
    nop

    lw ra, 12(sp)
    nop
    addi sp, sp, 16
    jalr x0, 0(ra)
    nop
    nop

# --------------------------------------------------
# Function 2
# --------------------------------------------------
function2:
    addi sp, sp, -16
    nop
    nop
    sw ra, 12(sp)
    nop

    addi s0, s0, 1

    jal ra, function3
    nop
    nop

    lw ra, 12(sp)
    nop
    nop
    addi sp, sp, 16
    jalr x0, 0(ra)
    nop
    nop

# --------------------------------------------------
# Function 3
# --------------------------------------------------
function3:
    addi sp, sp, -16
    nop
    nop
    sw ra, 12(sp)
    nop

    addi s0, s0, 1

    jal ra, function4
    nop
    nop

    lw ra, 12(sp)
    nop
    nop
    addi sp, sp, 16
    jalr x0, 0(ra)
    nop
    nop

# --------------------------------------------------
# Function 4
# --------------------------------------------------
function4:
    addi sp, sp, -16
    nop
    nop
    sw ra, 12(sp)
    nop

    addi s0, s0, 1

    jal ra, function5
    nop
    nop

    lw ra, 12(sp)
    nop
    nop
    
    addi sp, sp, 16
    jalr x0, 0(ra)
    nop
    nop

# --------------------------------------------------
# Function 5
# --------------------------------------------------
function5:
    addi sp, sp, -16
    nop
    nop

    sw ra, 12(sp)

    addi s0, s0, 1

    # Deepest call reached.
    # Return to function4.

    lw ra, 12(sp)
    nop
    nop

    addi sp, sp, 16
    jalr x0, 0(ra)
    nop
    nop
    

# --------------------------------------------------
# End program
# --------------------------------------------------
done:
    wfi
