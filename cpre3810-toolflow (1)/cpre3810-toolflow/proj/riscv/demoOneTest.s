#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

addi x1, x0, 10
lui x2, 0x10010
addi x2, x2, 128

sw x1, 0(x2)
lw x3, 0(x2)


wfi
