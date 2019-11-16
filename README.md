# Vi
This is my first RISC-V Core, named after LOL's champion Vi (which actually is inside my name, Víctor, and in risc-V).

It will be composed of 5 stages when doing a normal alu operation and 6 when doing a mult/div or memory operation.

| Feature: | Requirements: | Extra comments:|			
|---|---|---|							
| ISA RISCV	| Minimum instructions: ADD, SUB, MUL, LDB, LDW, STB, STW, BEQ, JUMP | - |
| Memory	| 5 cycles to go to memory	5 cycles to return data from memory to processor | - |
|Data Cache |	4 lines	128 bits	Replacement policy = LRU	4-way associative	|	Could be direct mapped |
|Instruction Cache	| 4 lines	128 bits	Replacement policy = LRU	4-way associative	|	Could be direct mapped |													
| Pipeline | 5 or more stages	MUL 5 stages longer (F, D, M1, M2, M3, M4, M5, WB)	Full set of bypasses	Store buffer	HF	Branch: F D EX	Integer ALU: F D EX W	Memory: F D EX TL C W | - |	
|Virtual memory	| "4.Adding virtual memory" in project PDF	iTLB + dTLB	Mini OS code + 3 new inst (MOV, TLBWRITE, IRET)	Follow RISCV? | - |
|BONUS	| Branch predictor | Maybe in the future: Out of order |
																									
Module	Stage	Pending	Deadline	Specs																					
	S1																								
	S2																								
	S3																								
	S4																								
	S5																								
	SX																								
Total			20/12 (without testing)																						
																									
																									
Action	Assignee	Pending	Deadline	Comments																					
Adapt code	Víctor		17/11																						
																								
