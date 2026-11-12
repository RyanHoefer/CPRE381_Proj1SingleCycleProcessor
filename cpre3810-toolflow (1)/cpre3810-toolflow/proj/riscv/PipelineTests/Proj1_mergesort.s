# Sorting Algorithm Template in RISC-V Assembly - Tyler Bibus
# This template provides a basic structure for implementing a sorting algorithm (i.e. mergesort) in RISC-V assembly language.

# Note: You MUST put the sorted array back in the SAME memory location as the original array.
#       During grading we will insert our own array and corresponding array_size for testing.
#       The max size will be 512 elements.
.data
    array_size: .word 12
    array: .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
    # TODO: You may add additional temporary data here
.text
.globl main

main:
    # Save return address
    lui sp, 0x7FFFF
    nop
    nop
    addi sp, sp, -4         # sp = 0x7FFFEFFC
    addi ra, x0, 0
    nop

    addi sp, sp, -4
    nop
    nop
    sw ra, 0(sp)
    
    # Call sorting function
    lasw2 a1, array_size
    lasw2 a0, array
    lw a1, 0(a1)
    jal ra, sort
    nop
    nop

    # restore stack
    lw ra, 0(sp)
    nop
    nop
    addi sp, sp, 4
    
    # Exit program
    jal x0, program_exit
    nop
    nop

# void sort(int* array, int size);
.globl sort
sort:
# TODO: Implement your sorting algorithm here.

    # int width = 1;
    addi a2, x0, 1
    nop
    nop

width_loop:
    # Continue while width < size.
    bge a2, a1, sort_done
    nop
    nop

    # int left = 0;
    addi a3, x0, 0
    nop
    nop

pair_loop:
    # int mid = left + width;
    add a4, a3, a2
    nop
    nop

    # Continue while left + width < size.
    bge a4, a1, next_width
    nop
    nop

    # int right = mid + width;
    add a5, a4, a2
    nop
    nop

    # if (right > size)
    #     right = size;
    bge a1, a5, right_ready
    nop
    nop
    add a5, a1, x0

right_ready:
    # int i = left;
    add a6, a3, x0

    # int j = mid;
    add a7, a4, x0
    nop
    nop

merge_loop:
    # Continue while i < j && j < right.
    bge a6, a7, next_pair
    nop
    nop
    bge a7, a5, next_pair
    nop
    nop

    # Read array[i] into t1.
    slli t2, a6, 2
    nop
    nop
    add t2, a0, t2
    nop
    nop
    lw t1, 0(t2)

    # Read array[j] into t0.
    slli t2, a7, 2
    nop
    nop
    add t2, a0, t2
    nop
    nop
    lw t0, 0(t2)
    nop
    nop

    # if (array[i] <= array[j])
    #     i++;
    bge t0, t1, advance_i
    nop
    nop

    # else:
    # int value = array[j];
    # value is already in t0.

    # int k = j;
    add t3, a7, x0
    nop
    nop

shift_loop:
    # Continue while k > i.
    bge a6, t3, insert_value
    nop
    nop

    # array[k] = array[k - 1];
    slli t2, t3, 2
    nop
    nop
    add t2, a0, t2
    nop
    nop
    lw t4, -4(t2)
    nop
    nop

    sw t4, 0(t2)

    # k--;
    addi t3, t3, -1
    jal x0, shift_loop
    nop
    nop

insert_value:
    # array[i] = value;
    slli t2, a6, 2
    nop
    nop
    add t2, a0, t2
    nop
    nop
    sw t0, 0(t2)

    # i++;
    addi a6, a6, 1

    # j++;
    addi a7, a7, 1
    jal x0, merge_loop
    nop
    nop

advance_i:
    # i++;
    addi a6, a6, 1
    jal x0, merge_loop
    nop
    nop

next_pair:
    # left = right;
    add a3, a5, x0
    jal x0, pair_loop
    nop
    nop

next_width:
    # width *= 2;
    slli a2, a2, 1
    jal x0, width_loop
    nop
    nop

sort_done:
    # return;
    jalr x0, 0(ra)
    nop
    nop

program_exit:
    wfi