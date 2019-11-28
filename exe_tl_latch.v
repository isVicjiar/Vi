// Execution tl latch

module exe_tl_latch (
input clk_i,
input rsn_i,
input	[31:0]	exe_cache_addr_i,
input	[4:0]	exe_write_addr_i,
input		exe_int_write_enable_i,
input [31:0] exe_store_data_i,
input	[31:0]	exe_instruction_i,
input	[31:0]	exe_pc_i,
output	[31:0]	tl_cache_addr_o,
output	[4:0]	tl_write_addr_o,
output		tl_int_write_enable_o,
input [31:0] tl_store_data_o,
output	[31:0]	tl_instruction_o,
output 	[31:0]	tl_pc_o);
);
