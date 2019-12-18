module tb_core;

reg clk;
reg rsn;

reg [127:0] memory [25'hFFF:0];
reg tmp_mem_data_ready;
reg [127:0] tmp_mem_data;
reg [19:0] tmp_mem_addr;

wire mem_data_ready;
wire [127:0] mem_data;
wire [19:0] mem_addr;
wire mem_read;
wire [19:0] mem_read_addr;
wire mem_write_enable;
wire [19:0] mem_write_addr;
wire [31:0] mem_write_data;
wire mem_write_byte;

assign mem_data_ready = tmp_mem_data_ready;
assign mem_data = tmp_mem_data;
assign mem_addr = tmp_mem_addr;

vi_core vi_core(
	.clk_i	(clk),
	.rsn_i	(rsn),
	.mem_data_ready_i (mem_data_ready),
	.mem_data_i	  (mem_data),
	.mem_addr_i	  (mem_addr),
	.mem_read_o	  (mem_read),
	.mem_read_addr_o  (mem_read_addr),
	.mem_write_enable_o	(mem_write_enable),
	.mem_write_byte_o	(mem_write_byte),
	.mem_write_addr_o	(mem_write_addr),
	.mem_write_data_o	(mem_write_data)
);

always begin
	#5 clk = !clk;	
end
/*OS
add r1, r1, r0
addi r2, r1, #1
addi r3, r0, #F
sll  r2, r2, r3
tlbwrite r1, r2
iret
// 0000000 rs2 rs1 000 rd 0110011 add/sll
// imm[11:0] rs1 000 rd 0010011 addi
// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
// 0011000 00010 00000 000 00000 1110011 (mret)

// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
// 0001001 rs2 rs1 001 00000 1110011 (dtlbwrite invented as sfence.vma)
therefore the code is
// 0000 0000 0001 0000 0000 0000 1011 0011 0x001000B3 add
// 0000 0000 0001 0000 1000 0001 0001 0011 0x00108113 addi
// 0000 0000 1111 0000 0000 0001 1001 0011 0x00F00193 addi
// 0000 0000 0011 0001 0001 0001 0011 0011 0x00311133 sll
// 0001 0010 0010 0000 1000 0000 0111 0011 0x12208073 tlbwrite
// 0011 0000 0010 0000 0000 0000 0111 0011 0x30200073 iret
//
EXC HANDLER
addi r31, r0, 0xAA
iret

// 0000 1010 1010 0000 0000 1111 1001 0011 0x0AA00F93 addi
// 0011 0000 0010 0000 0000 0000 0111 0011 0x30200073 iret

USER CODE
addi r3, r1, 3
addi r4, r1, 4
addi r5, r1, 5
addi r6, r1, 6
// 0000 0000 0011 0000 1000 0001 1001 0011 0x00308193 
// 0000 0000 0100 0000 1000 0010 0001 0011 0x00408213
// 0000 0000 0101 0000 1000 0010 1001 0011 0x00508293
// 0000 0000 0110 0000 1000 0011 0001 0011 0x00608313 */
initial begin
	rsn = 1'b0;
	clk = 1'b1;
	#20
	tmp_mem_data = 128'b0;
	tmp_mem_addr = 20'b0;
	tmp_mem_data_ready = 1'b0;
	// 1000 8-bit element /  
	// Initialize memory with os at 0x1000	// 0001 0000 0000 |0000 000
	
	memory[25'h100] = {32'h00311133, 32'h00F00193, 32'h00108113, 32'h001000B3};
	// Initialize memory with os 2 at 0x1010	// 0001 0000 0001 |0000 000
	memory[25'h101] = {32'h00000000, 32'h00000000, 32'h30200073, 32'h12208073};
	// Initialize exc handler at 0x2000	// 0010 0000 0|000 0000
	memory[25'h200] = {32'h00000000, 32'h00000000, 32'h30200073, 32'h0AA00F93};
	// Initialize USER CODE at 0x8000 // 1000 0000 0000 |0000 000
	memory[25'h800] = {32'h00608313, 32'h00508293, 32'h00409213, 32'h00308193}; //now second instr gives ill instr
//	0000 0000 0000 0000 1000 0000 0|000 0000
	rsn = 1'b1;
end

always @ (posedge clk) begin
	if (mem_read) begin
		tmp_mem_data = memory[mem_read_addr*8/128];
		tmp_mem_addr = mem_read_addr;
		tmp_mem_data_ready = 1'b1;
	end
	else if (mem_write_enable) begin
		memory[mem_write_addr] = mem_write_data;
	end
	else tmp_mem_data_ready = 1'b0;
end

endmodule
