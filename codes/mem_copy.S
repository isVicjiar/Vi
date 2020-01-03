.globl _start
_start:
.section .text

//R1 = i
//R2 = max
//R3 = 5/a[i] value
//R4 = a address
//R5 = b address
//R6 = a[i]
//R7 = b[i]
    addi x1, x0, 0
    addi x2, x0,128
    addi x3, x0, 5
    addi x4, x0, 0
    addi x5, x4,512
    addi x6, x4, 0
loop1:
    beq x1, x2, end1
    sw x3, 0(x6)
    addi x6, x6, 4
    addi x1, x1, 1
    beq x1, x1, loop1
end1:
    addi x6, x4, 0
    addi x7, x5, 0
    addi x1, x0, 0
loop2:
    beq x1, x2, end2
    lw x3, 0(x6)
    sw x3, 0(x7)
    addi x6, x6, 4
    addi x7, x7, 4
    addi x1, x1, 1
    beq x1, x1, loop2
end2:
    addi x0,x0,0
    beq x1,x1,end2


