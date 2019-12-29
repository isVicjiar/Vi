.section .text
.globl _start
_start:

//EXCEPTION HANDLER
addi x31, x0, 1
addi x30, x0, 0xB
sll x31, x31, x30
add x30, x0, x0
sd x1, 0(x31)
sd x2, 4(x31)
sd x3, 8(x31)
sd x4, 12(x31)
sd x5, 16(x31)
sd x6, 20(x31)
sd x7, 24(x31)
sd x8, 28(x31)
sd x9, 32(x31)
sd x10, 36(x31)
csrrs x1, mcause, x0
addi x2, x0, 0x1
addi x3, x0, 0x2
sll x4, x2, x3
addi x3, x0, 0x4
sll x5, x2, x3
addi x3, x0, 0x6
sll x6, x2, x3
addi x3, x0, 0xC
sll x7, x2, x3
addi x3, x0, 0xD
sll x8, x2, x3
addi x3, x0, 0xF
sll x9, x2, x3
beq x1,x2,imisaligned
beq x1,x4,illinstr
beq x1,x5,lmisaligned
beq x1,x6,smisaligned
beq x1,x7,ipfault
beq x1,x8,lpfault
beq x1,x9,spfault
jal excreturn

//INSTRUCTION MISALIGNED ------------ 0
imisaligned: addi x30, x0, 0xAA
addi x31, x0, 0
jal excreturn

//ILLEGAL INSTRUCTION --------------- 2
illinstr: addi x30, x0, 0xAA
addi x31, x0, 2
jal excreturn

//LOAD MISALIGNED ------------------- 4
lmisaligned: addi x30, x0, 0xAA
addi x31, x0, 4
jal excreturn

//STORE MISALIGNED ------------------ 6
smisaligned: addi x30, x0, 0xAA
addi x31, x0, 6
jal excreturn

//INSTRUCTION PAGE FAULT ------------ 12
ipfault: 

//TLBWRITE
csrrs x1, mepc, x0
addi x2, x0, 1
addi x3, x0, 0xF
sll x2, x2, x3
add x2, x1, x2
itlbwrite x1, x2

addi x30, x0, 0xAA
addi x31, x0, 0xC
jal excreturn

//LOAD PAGE FAULT ------------------ 13
lpfault: 

//TLBWRITE
csrrs x1, mepc, x0
addi x2, x0, 1
addi x3, x0, 0x10
sll x2, x2, x3
add x2, x1, x2
dtlbwrite x1, x2

addi x30, x0, 0xAA
addi x31, x0, 0xD
jal excreturn

//STORE PAGE FAULT ---------------- 15
spfault: 

//TLBWRITE
csrrs x1, mepc, x0
addi x2, x0, 1
addi x3, x0, 0x10
sll x2, x2, x3
add x2, x1, x2
dtlbwrite x1, x2

addi x30, x0, 0xAA
addi x31, x0, 0xF
jal excreturn

excreturn: 
addi x10, x0, 1
addi x9, x0, 0xB
sll x10, x10, x9
ld x1, 0(x10)
ld x2, 4(x10)
ld x3, 8(x10)
ld x4, 12(x10)
ld x5, 16(x10)
ld x6, 20(x10)
ld x7, 24(x10)
ld x8, 28(x10)
ld x9, 32(x10)
ld x10, 36(x10)
mret
