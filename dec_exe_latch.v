// Latch between registers and exe

module dec_exe_latch(
input		clk_i,
input		rsn_i,
input 		kill_i,
input		stall_core_i,
input	[31:0]	dec_read_data_a_i,
input	[31:0]	dec_read_data_b_i,
input	[31:0]	dec_write_addr_i,
input		dec_int_write_enable_i,
input		dec_tlbwrite_i,
input		dec_idtlb_i,
input	[31:0]	dec_instruction_i,
input	[31:0]	dec_pc_i,
output	[31:0]	exe_read_data_a_o,
output	[31:0]	exe_read_data_b_o,
output	[31:0]	exe_write_addr_o,
output		exe_int_write_enable_o,
output		exe_tlbwrite_o,
output		exe_idtlb_o,
output	[31:0]	exe_instruction_o,
output	[31:0]	exe_pc_o);

reg	[31:0]	exe_read_data_a;
reg	[31:0]	exe_read_data_b;
reg	[31:0]	exe_write_addr;
reg		exe_int_write_enable;
reg		exe_tlbwrite;
reg		exe_idtlb;
reg	[31:0]	exe_instruction;
reg	[31:0]	exe_pc;
	
assign exe_read_data_a_o = exe_read_data_a;
assign exe_read_data_b_o = exe_read_data_b;
assign exe_write_addr_o = exe_write_addr;
assign exe_int_write_enable_o = exe_int_write_enable;
assign exe_tlbwrite_o = exe_tlbwrite;
assign exe_idtlb_o = exe_idtlb;
assign exe_instruction_o = exe_instruction;
assign exe_pc_o = exe_pc;
	
// Latch 
always @(posedge clk_i)
begin
	if (!rsn_i || kill_i) begin
		exe_read_data_a = 5'b0;
		exe_read_data_b = 5'b0;
		exe_write_addr = 5'b0;
		exe_int_write_enable = 1'b0;
		exe_tlbwrite = 1'b0;
		exe_idtlb = 1'b0;
		exe_instruction = 32'b0;
		exe_pc = 32'b0;
	end
	else begin
		if (!stall_core_i) begin
			exe_read_data_a = dec_read_data_a_i;
			exe_read_data_b = dec_read_data_b_i;
			exe_write_addr = dec_write_addr_i;
			exe_int_write_enable = dec_int_write_enable_i;
			exe_tlbwrite = dec_tlbwrite_i;
			exe_idtlb = dec_idtlb_i;
			exe_instruction = dec_instruction_i;
			exe_pc = dec_pc_i;
		end
	end
end
endmodule
