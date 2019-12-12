module tb_core;

reg clk;
reg rsn;

vi_core vi_core(
	.clk_i	(clk),
	.rsn_i	(rsn),
	.mem_data_ready_i (mem_data_ready),
	.mem_data_i	  (mem_data),
	.mem_addr_i	  (mem_addr),
	.mem_read_o	  (mem_read),
	.mem_read_addr_o  (mem_read_addr),
	.mem_write_enable_o	(mem_write_enable),
	.mem_write_addr_o	(mem_write_addr),
	.mem_write_data_o	(mem_write_data)
);

reg [127:0] memory [:0];
reg mem_data_ready;
reg [127:0] mem_data;
reg [19:0] mem_addr;
reg mem_read;
reg [19:0] mem_read_addr;
reg mem_write_enable;
reg [19:0] mem_write_addr:
reg [31:0] mem_write_data;

always begin
	#5 clk = !clk;	
end
/*
OS
add r1, r1, r0
addi r2, r1, #8000
tlbwrite r1, r2
iret

// 0000000 rs2 rs1 000 rd 0110011
// imm[11:0] rs1 000 rd 0010011
// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
// 0011000 00010 00000 000 00000 1110011 (mret)

// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
// 0001001 rs2 rs1 0y01 00000 1110011 (dtlbwrite invented as sfence.vma)

therefore the code is
// 0000 0000 0001 0000 0000 0000 1011 0011 0x001000B3
// 1000 0000 0000 0000 1000 0001 0001 0011 0x80008113
// 0001 0010 0010 0000 1000 0000 0111 0011 0x12208073
// 0011 0000 0010 0000 0000 0000 0111 0011 0x30200073

*/

/*
USER CODE

addi r3, r1, 3
addi r4, r1, 4
addi r5, r1, 5
addi r6, r1, 6

// 0000 0000 0011 0000 1000 0001 1001 0011 0x00308193 
// 0000 0000 0100 0000 1000 0010 0001 0011 0x00408213
// 0000 0000 0101 0000 1000 0010 1001 0011 0x00508293
// 0000 0000 0110 0000 1000 0011 0001 0011 0x00608313
*/
initial begin
	rsn = 1'b0;
	clk = 1'b1;
	#20
	// Initialize memory with os at 0x1000
	// 0001 0000 0|000 0000
	memory[25'h20] = {32'h30200073, 32'h12208073, 32'h80008113, 32'h001000B3};
	// Initialize exc handler at 0x2000
	// 0010 0000 0|000 0000
	//
	// Initialize USER CODE at 0x8000
	memory[25'h100] = {32'h00308193, 32'h00408213, 32'h00508293, 32'h00608313};

//	0000 0000 0000 0000 1000 0000 0|000 0000
	rsn = 1'b1;
	forever begin
		if () begin

		end
		else if (mem_write_enable) begin
			memory[mem_write_addr] = mem_write_data;
		end
	end
end

endmodule
