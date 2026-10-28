.data
.align 2

# Expected result:
# -20, -7, -3, 0, 1, 2, 4, 5, 5, 8, 12, 19
array:
    .word 12, -3, 5, 0, 19, -7, 5, 2, -20, 8, 1, 4

buffer:
    .space 48

.text
.globl main

main:
    lui s0, 0x10010          # Array base = 0x10010000
    addi s9, s0, 48         # Buffer starts after 12 words
    addi s1, x0, 12         # Number of elements
    addi s2, x0, 1          # Initial run width

width_loop:
    bge s2, s1, verify_start
    addi s3, x0, 0          # Left boundary

pair_loop:
    bge s3, s1, copy_start

    # mid = min(left + width, length)
    add s4, s3, s2
    blt s4, s1, mid_ready
    add s4, s1, x0

mid_ready:
    # right = min(mid + width, length)
    add s5, s4, s2
    blt s5, s1, right_ready
    add s5, s1, x0

right_ready:
    add s6, s3, x0          # Left-run index
    add s7, s4, x0          # Right-run index
    add s8, s3, x0          # Buffer output index

merge_loop:
    bge s8, s5, next_pair
    bge s6, s4, take_right
    bge s7, s5, take_left

    # Read left element.
    slli t0, s6, 2
    add t0, s0, t0
    lw t2, 0(t0)

    # Read right element.
    slli t1, s7, 2
    add t1, s0, t1
    lw t3, 0(t1)

    blt t3, t2, take_right

take_left:
    slli t0, s6, 2
    add t0, s0, t0
    lw t4, 0(t0)
    addi s6, s6, 1
    jal x0, store_element

take_right:
    slli t0, s7, 2
    add t0, s0, t0
    lw t4, 0(t0)
    addi s7, s7, 1

store_element:
    slli t0, s8, 2
    add t0, s9, t0
    sw t4, 0(t0)

    addi s8, s8, 1
    jal x0, merge_loop

next_pair:
    add s3, s5, x0
    jal x0, pair_loop

copy_start:
    addi t5, x0, 0

copy_loop:
    bge t5, s1, next_width

    slli t0, t5, 2

    add t1, s9, t0
    lw t2, 0(t1)

    add t1, s0, t0
    sw t2, 0(t1)

    addi t5, t5, 1
    jal x0, copy_loop

next_width:
    slli s2, s2, 1
    jal x0, width_loop

verify_start:
    addi a0, x0, 0          # Failure unless verification finishes
    addi t5, x0, 1

verify_loop:
    bge t5, s1, success

    slli t0, t5, 2
    add t0, s0, t0

    lw t1, -4(t0)
    lw t2, 0(t0)
    blt t2, t1, done

    addi t5, t5, 1
    jal x0, verify_loop

success:
    addi a0, x0, 1          # x10 = 1 means array is ordered

done:
    wfi