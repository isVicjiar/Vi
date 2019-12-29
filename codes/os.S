.section .text
.globl _start
_start:

add x1,x1,x0
addi x2,x1,1
addi x3,x0,0xf
sll x2,x2,x3
addi x0,x0,0
mret

// 0000000 rs2 rs1 000 rd 0110011
// imm[11:0] rs1 000 rd 0010011
// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
// 0011000 00010 00000 000 00000 1110011 (mret)

// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
// 0001001 rs2 rs1 001 00000 1110011 (dtlbwrite invented as sfence.vma)
