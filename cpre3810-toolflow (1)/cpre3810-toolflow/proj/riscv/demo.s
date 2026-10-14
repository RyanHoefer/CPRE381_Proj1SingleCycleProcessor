# Demo for ADDI, ADD, SUB, LUI, SW, LW, and WFI.
# Uses the default RARS data address, which maps to hardware RAM word 0.

.data
result: .word 0

.text
main:
    addi x1, x0, 10       # x1 = 10
    addi x2, x0, 20       # x2 = 20
    add  x3, x1, x2       # x3 = 30
    sub  x4, x3, x1       # x4 = 20
    lui  x5, 0x12345      # x5 = 0x12345000

    lui  x8, 0x10010      # x8 = 0x10010000 (result address)
    sw   x3, 0(x8)        # Store 30 to result / hardware RAM word 0
    lw   x6, 0(x8)        # x6 = 30
    add  x7, x6, x4       # x7 = 50

    wfi                  # Signal completion to the toolflow
