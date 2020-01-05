.globl _start
_start:
.section .text

//R1 = i
//R2 = j
//R3 = k
//R4 a address
//R5 b address
//R6 c address
//R7 a[i][k]
//R8 b[k][j]
//R9 c[i][j]
//R11 a[i] address
//R12 b[i] address
//R13 c[i] address
//R15 128
//128*128 = 16K elements at 4 bytes each
	addi x1, x0, 0
	addi x2, x0, 0
	addi x3, x0, 0
	addi x15, x0, 128
	addi x4,x0,0
	addi x5,x0,1
	addi x10,x0,18
	sll x5,x5,x10
	addi x6,x0,1
	sll x6,x5,x6
loop1: 	beq x1,x15,endloop1
	addi x2,x0,0
loop2: 	beq x2,x15,endloop2
	addi x3,x0,0
	addi x9, x0, 0
	// c[i*ncols*4 + j*4]
	mul x13, x1, x15
	addi x16, x0, 2
	sll x13, x13, x16
	sll x17, x2, x16 
	add x13, x13, x17
	add x13, x13, x6
	sw x9, 0(x13)
loop3: 	beq x3,x15,endloop3
	// a[i*ncols*4 + k*4]
	mul x11, x1, x15
	sll x11, x11, x16
	sll x17, x3, x16 
	add x11, x11, x17
	add x11, x11, x4
	// b[k*ncols*4 + j*4]
	mul x12, x3, x15
	sll x12, x12, x16
	sll x17, x2, x16 
	add x12, x12, x17
	add x12, x12, x5
	// loads
	lw x7, 0(x11)
	lw x8, 0(x12)
	lw x9, 0(x13)
	mul x14, x7, x8
	add x9, x9, x14
	sw x9, 0(x13)
	addi x3,x3,1
	jal loop3
endloop3: addi x2,x2,1
	jal loop2
endloop2: addi x1,x1,1
	jal loop1
endloop1: addi x0,x0,0
	beq x1,x1,endloop1
