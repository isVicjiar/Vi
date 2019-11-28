// Latch between fetch and decode

module fetch_dec_latch(
input		clk_i,
input		rsn_i,
input 		stall_core_i,
input	[31:0]	fetch_instr_i,
output reg [31:0]	dec_instr_o);

// Latch 
	always @(posedge clk_i)
begin
	if (!rsn_i) dec_instr_o = 32'b0;
	else begin
		if (!stall_core_i) dec_instr_o = fetch_instr_i;
	end
end
endmodule	
