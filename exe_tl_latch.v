// Execution tl latch

module exe_tl_latch (
input 		clk_i,
input 		rsn_i,
input 		stall_core_i,
input	[31:0]	exe_cache_addr_i,
input	[4:0]	exe_write_addr_i,
input		exe_int_write_enable_i,
input 	[31:0] 	exe_store_data_i,
input	[31:0]	exe_instruction_i,
input	[31:0]	exe_pc_i,
output	[31:0]	tl_cache_addr_o,
output	[4:0]	tl_write_addr_o,
output		tl_int_write_enable_o,
input 	[31:0] 	tl_store_data_o,
output	[31:0]	tl_instruction_o,
output 	[31:0]	tl_pc_o);
);

assign tl_cache_addr_o = tl_cache_addr;
assign tl_write_addr_o = tl_write_addr;
assign tl_int_write_enable_o = tl_int_write_enable;
assign tl_store_data_o = tl_store_data;
assign tl_instruction_o = tl_instruction;
assign tl_pc_o = tl_pc;
	
// Latch 
always @(posedge clk_i)
begin
	if (!rsn_i) begin
		tl_cache_addr = 32'b0;
		tl_write_addr = 5'b0;
		tl_int_write_enable = 1'b0;
    		tl_store_data = 32'b0;
		tl_instruction = 32'b0;
		tl_pc = 32'b0;
	end
	else begin
		if (!stall_core_i) begin
			tl_cache_addr = exe_cache_addr_i;
			tl_write_addr = exe_write_addr_i;
			tl_int_write_enable = exe_int_write_enable_i;
    			tl_store_data = exe_store_data_i;
			tl_instruction = exe_instruction_i;
			tl_pc = exe_pc_i;
		end
	end
end
endmodule	
