module tb_core;

reg clk;
reg rsn;

vi_core vi_core(
	.clk_i	(clk),
	.rsn_i	(rsn)
);

initial begin
	rsn = 1'b0;
	clk = 1'b1;
	#20
	rsn = 1'b1;
end

always begin
	#5 clk = !clk;	
end

endmodule
