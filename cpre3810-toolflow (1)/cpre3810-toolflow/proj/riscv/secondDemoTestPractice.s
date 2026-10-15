#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

addi x10, x0, 12
addi x8, x0, 20

sub x7, x8, x10

lui x1, 0x10010
addi x1, x1, 24

sw x7, 0(x1)
lw x5, 0(x1)

wfi
