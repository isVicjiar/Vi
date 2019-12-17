// Latch between fetch and decode

module fetch_dec_latch(
input		clk_i,
input		rsn_i,
input 		stall_core_i,
input		fetch_misaligned_instr_exc_i,
input		fetch_instr_fault_exc_i,
input	[31:0]	fetch_instr_i,
input	[31:0]	fetch_pc_i,
output reg [31:0]	dec_exc_bits_o, 
output reg [31:0]	dec_instr_o,
output reg [31:0]	dec_pc_o);

// Latch 
	always @(posedge clk_i)
begin
	if (!rsn_i) begin
		dec_exc_bits_o = 32'b0;
		dec_instr_o = 32'b0;
		dec_pc_o = 32'b0;
	end
	else begin
		if (!stall_core_i) begin
			dec_exc_bits_o = {19'b0,fetch_instr_fault_exc_i,11'b0,fetch_misaligned_instr_exc_i};
			dec_instr_o = fetch_instr_i;
			dec_pc_o = fetch_pc_i;
		end
	end
end
endmodule	
