module tb_core;

reg clk;
reg rsn;

vi_core vi_core(
	.clk_i	(clk),
	.rsn_i	(rsn)
);

reg [127:0] memory [:0];

always begin
	#5 clk = !clk;	
end

initial begin
	rsn = 1'b0;
	clk = 1'b1;
	#20
	// Initialize memory with os at 0x1000
	// 0001 0000 0|000 0000
	memory[7'h20] = {32'hXXXX, 32'hXXXX, 32'hXXXX, 32'hXXXX};
	// Initialize exc handler at 0x2000
	// 0010 0000 0|000 0000
	memory[7'h40] = {32'h0000, 32'h0000, 32'h0000, 32'h0000};


	rsn = 1'b1;
	
end

endmodule
