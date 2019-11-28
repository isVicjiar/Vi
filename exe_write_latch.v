// Latch between execution and write back

module exe_write_latch(
input		clk_i,
input		rsn_i,
input	[31:0]	exe_int_write_data_i,
input	[4:0]	exe_write_addr_i,
input		exe_int_write_enable_i,
input	[31:0]	exe_instruction_i,
input	[31:0]	exe_pc_i,
output	[31:0]	write_int_write_data_o,
output	[4:0]	write_write_addr_o,
output		write_int_write_enable_o,
output	[31:0]	write_instruction_o,
output 	[31:0]	write_pc_o);

reg	[31:0]	write_int_write_data;
reg	[4:0]	write_write_addr;
reg		write_int_write_enable;
reg	[31:0]	write_instruction;
reg 	[31:0]	write_pc;
	
assign write_int_write_data_o = write_int_write_data;
assign write_write_addr_o = write_write_addr;
assign write_int_write_enable_o = write_int_write_enable;
assign write_instruction_o = write_instruction;
assign write_pc_o = write_pc;
	
// Latch 
always @(posedge clk_i)
begin
	if (!rsn_i) begin
		write_int_write_data = 32'b0;
		write_write_addr = 5'b0;
		write_int_write_enable = 1'b0;
		write_instruction = 32'b0;
		write_pc = 32'b0;
	end
	else begin
		write_int_write_data = exe_int_write_data_i;
		write_write_addr = exe_write_addr_i;
		write_int_write_enable = exe_int_write_enable_i;
		write_instruction = exe_instruction_i;
		write_pc = exe_pc_i;
	end
end
endmodule	
