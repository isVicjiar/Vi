.section .text
.globl _start
_start:

		addi x1, x0, 1 // R1 = 1
		addi x2, x0, 2 // R2 = 2
		add x3, x1, x2 // R3 = 3
		add x4, x2, x1 // R4 = 3
		sub x5, x2, x1 // R5 = 1
		sub x6, x1, x2 // R6 = -1
		mul x7, x2, x3 // R7 = 6
		mul x8, x2, x6 // R8 = -2
		sd x6, 0 (x31) // 0(x31) = -1
		sb x6, 4 (x31) // 0(x31) = 0x000000FF
		beq x1, x2, noloads // mustn't jump
		beq x3, x4, loads // must jump
noloads: 	addi x12,x1,0xAA // IF AA IN R12, ERROR IN FIRST BEQ
loads: 		ld x9, 0(x31) //R9 = 0x000000FF
		lb x10, 4(x31)  // R10 = 0x000000FF
		jal point
		addi x13,x0,0xBB // IF BB IN R13, ERROR IN JAL
point : 	addi x11,x0,1 //R11 = 1
