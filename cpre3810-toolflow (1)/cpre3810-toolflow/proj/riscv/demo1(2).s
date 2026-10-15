#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

addi x10, x10, 12
addi x8, x8, 20

sub x7, x8, x10

lui x1, 0x10010
addi x1, x1, 193

sw x7, 0(x1)
lw x5, 0(x1)

wfi
