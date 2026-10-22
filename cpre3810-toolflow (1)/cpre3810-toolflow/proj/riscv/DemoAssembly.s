#
# 
#

# data section
.data

# code/instruction section
.text


addi x14, x0, 10

lui x1, 0x10010

addi x1, x1, 96

sw x14, 0(x1)


#load from address 24
lui x13, 0x10010
addi x13, x13, 96
lw x14, 0(x13)

#sub 10 from x14
addi x15, x0, 10
sub x16, x14, x15

wfi
