// Execution tl latch

module exe_tl_latch (
input 		clk_i,
input 		rsn_i,
input		kill_i,
input 		stall_core_i,
input	[31:0]	exe_cache_addr_i,
input	[4:0]	exe_write_addr_i,
input		exe_int_write_enable_i,
input 	[31:0] 	exe_store_data_i,
input		exe_tlbwrite_i,
input		exe_idtlb_i,
input	[31:0]	exe_read_data_a_i,
input	[31:0]	exe_read_data_b_i,
input	[31:0]	exe_instruction_i,
input	[31:0]	exe_pc_i,
output		tl_cache_enable_o,
output		tl_store_o,
output	[31:0]	tl_cache_addr_o,
output	[4:0]	tl_write_addr_o,
output		tl_int_write_enable_o,
output 	[31:0] 	tl_store_data_o,
output		tl_tlbwrite_o,
output		tl_idtlb_o,
output	[31:0]	tl_read_data_a_o,
output	[31:0]	tl_read_data_b_o,
output	[31:0]	tl_instruction_o,
output 	[31:0]	tl_pc_o
);

reg [31:0] tl_cache_addr;
reg tl_cache_enable;
reg tl_store;
reg [4:0] tl_write_addr;
reg tl_int_write_enable;
reg [31:0] tl_store_data;
reg tl_tlbwrite;
reg tl_idtlb;
reg [31:0] tl_read_data_a;
reg [31:0] tl_read_data_b;
reg [31:0] tl_instruction;
reg [31:0] tl_pc;

assign tl_store_o = exe_instruction_i[5];
assign tl_cache_addr_o = tl_cache_addr;
assign tl_write_addr_o = tl_write_addr;
assign tl_int_write_enable_o = tl_int_write_enable;
assign tl_store_data_o = tl_store_data;
assign tl_tlbwrite_o = tl_tlbwrite;
assign tl_idtlb_o = tl_idtlb;
assign tl_read_data_a_o = tl_read_data_a;
assign tl_read_data_b_o = tl_read_data_b;
assign tl_instruction_o = tl_instruction;
assign tl_pc_o = tl_pc;
	
// Latch 
always @(posedge clk_i)
begin
	if (!rsn_i || kill_i) begin
		tl_cache_enable = 1'b0;
		tl_cache_addr = 32'b0;
		tl_write_addr = 5'b0;
		tl_int_write_enable = 1'b0;
    		tl_store_data = 32'b0;
		tl_tlbwrite = 1'b0;
		tl_idtlb = 1'b0;
		tl_read_data_a = 32'b0;
		tl_read_data_b = 32'b0;
		tl_instruction = 32'b0;
		tl_pc = 32'b0;
	end
	else begin
		if (!stall_core_i) begin
			if (exe_instruction_i[6:0] == 7'b0100011 || exe_instruction_i[6:0] == 7'b0000011) begin
				tl_int_write_enable = exe_int_write_enable_i;
				tl_cache_enable = 1'b1;
			end
			else begin
				tl_int_write_enable = 1'b0;
				tl_cache_enable = 1'b0;
			end
			tl_cache_addr = exe_cache_addr_i;
			tl_write_addr = exe_write_addr_i;
    			tl_store_data = exe_store_data_i;
			tl_tlbwrite   = exe_tlbwrite_i;
			tl_idtlb      = exe_idtlb_i;
			tl_read_data_a = exe_read_data_a_i;
			tl_read_data_b = exe_read_data_b_i;
			tl_instruction = exe_instruction_i;
			tl_pc = exe_pc_i;
		end
	end
end
endmodule	
