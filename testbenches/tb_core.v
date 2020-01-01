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

initial begin
	rsn = 1'b0;
	clk = 1'b1;
	#20
	tmp_mem_data = 128'b0;
	tmp_mem_addr = 20'b0;
	tmp_mem_data_ready = 1'b0;
	// 1000 8-bit element /  
	
	// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
	// 0001001 rs2 rs1 001 00000 1110011 (dtlbwrite invented as sfence.vma)
	//itlbwrite x1,x2
	//0001 0010 0010 0000 1000 0000 0111 0011
	//12208073
	//dtlbwrite x1,x2
	//0001 0010 0010 0000 1001 0000 0111 0011
	//12209073

	// Initialize memory with os at 0x1000	// 0001 0000 0000 |0000 000	
	memory[25'h100] = {32'h00311133, 32'h00F00193, 32'h00108113, 32'h001000B3};
	memory[25'h101] = {32'h00000000, 32'h00000000, 32'h30200073, 32'h12208073};
	// Initialize exc handler at 0x2000	// 0010 0000 0|000 0000
	memory[25'h200] = {32'h00000f33, 32'h01ef9fb3, 32'h00b00f13, 32'h00100f93};
	memory[25'h201] = {32'h004fb623, 32'h003fb423, 32'h002fb223, 32'h001fb023};
	memory[25'h202] = {32'h008fbe23, 32'h007fbc23, 32'h006fba23, 32'h005fb823};
	memory[25'h203] = {32'h00100113, 32'h342020f3, 32'h02afb223, 32'h029fb023};
	memory[25'h204] = {32'h003112b3, 32'h00400193, 32'h00311233, 32'h00200193};
	memory[25'h205] = {32'h003113b3, 32'h00c00193, 32'h00311333, 32'h00600193};
	memory[25'h206] = {32'h003114b3, 32'h00f00193, 32'h00311433, 32'h00d00193};
	memory[25'h207] = {32'h02608c63, 32'h02508863, 32'h02408463, 32'h02208063};
	memory[25'h208] = {32'h0a0000ef, 32'h08908063, 32'h06808063, 32'h04708063};
	memory[25'h209] = {32'h0aa00f13, 32'h094000ef, 32'h00000f93, 32'h0aa00f13};
	memory[25'h20a] = {32'h00400f93, 32'h0aa00f13, 32'h088000ef, 32'h00200f93};
	memory[25'h20b] = {32'h070000ef, 32'h00600f93, 32'h0aa00f13, 32'h07c000ef};
	memory[25'h20c] = {32'h00311133, 32'h00f00193, 32'h00100113, 32'h341020f3};
	memory[25'h20d] = {32'h00c00f93, 32'h0aa00f13, 32'h12208073, 32'h00208133};
	memory[25'h20e] = {32'h01000193, 32'h00100113, 32'h341020f3, 32'h04c000ef};
	memory[25'h20f] = {32'h0aa00f13, 32'h12209073, 32'h00208133, 32'h00311133};
	memory[25'h210] = {32'h00100113, 32'h341020f3, 32'h028000ef, 32'h00d00f93};
	memory[25'h211] = {32'h12209073, 32'h00208133, 32'h00311133, 32'h01000193};
	memory[25'h212] = {32'h00100513, 32'h004000ef, 32'h00f00f93, 32'h0aa00f13};
	memory[25'h213] = {32'h00453103, 32'h00053083, 32'h00951533, 32'h00b00493};
	memory[25'h214] = {32'h01453303, 32'h01053283, 32'h00c53203, 32'h00853183};
	memory[25'h215] = {32'h02453503, 32'h02053483, 32'h01c53403, 32'h01853383};
	memory[25'h216] = {32'h00000000, 32'h00000000, 32'h00000000, 32'h30200073};

	// Initialize USER CODE at 0x8000 // 1000 0000 0000 |0000 000
	memory[25'h800] = {32'h00110233, 32'h002081b3, 32'h00200113, 32'h00100093};
	memory[25'h801] = {32'h02610433, 32'h023103b3, 32'h40208333, 32'h401102b3};
	memory[25'h802] = {32'h00418463, 32'h00208463, 32'h006f8223, 32'h006fb023};
	memory[25'h803] = {32'h008000ef, 32'h004f8503, 32'h000fb483, 32'h0aa08613};
	memory[25'h804] = {32'b00000000, 32'b00000000, 32'h00100593, 32'h0bb00693};
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
