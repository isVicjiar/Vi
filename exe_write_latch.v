// Latch between execution and write back

module exe_write_latch(
input		clk_i,
input		rsn_i,
input		kill_i,
input	[31:0]	exe_int_write_data_i,
input	[4:0]	exe_write_addr_i,
input		exe_int_write_enable_i,
input		exe_illegal_inst_exc_i,
input	[31:0]	exe_exc_bits_i,
input	[31:0]	exe_instruction_i,
input	[31:0]	exe_pc_i,
input	[31:0]	mult5_int_write_data_i,
input	[4:0]	mult5_write_addr_i,
input		mult5_int_write_enable_i,
input	[31:0]	mult5_instruction_i,
input	[31:0]	mult5_pc_i,
input	[31:0]	cache_int_write_data_i,
input	[4:0]	cache_write_addr_i,
input		cache_int_write_enable_i,
input	[31:0]	cache_exc_bits_i,
input	[31:0]	cache_instruction_i,
input	[31:0]	cache_pc_i,
output	[31:0]	write_int_write_data_o,
output	[4:0]	write_write_addr_o,
output		write_int_write_enable_o,
output	[31:0]	write_exc_bits_o,
output	[31:0]	write_instruction_o,
output 	[31:0]	write_pc_o
);

reg	[31:0]	write_int_write_data;
reg	[4:0]	write_write_addr;
reg		write_int_write_enable;
reg	[31:0]	write_exc_bits;
reg	[31:0]	write_instruction;
reg 	[31:0]	write_pc;
	
assign write_int_write_data_o = write_int_write_data;
assign write_write_addr_o = write_write_addr;
assign write_int_write_enable_o = write_int_write_enable;
assign write_exc_bits_o = write_exc_bits;
assign write_instruction_o = write_instruction;
assign write_pc_o = write_pc;
	
// Latch 
always @(posedge clk_i)
begin
	if (!rsn_i || kill_i) begin
		write_int_write_data = 32'b0;
		write_write_addr = 5'b0;
		write_int_write_enable = 1'b0;
		write_exc_bits = 32'b0;
		write_instruction = 32'b0;
		write_pc = 32'b0;
	end
	else begin
		if (mult5_int_write_enable_i) begin
			write_int_write_data = mult5_int_write_data_i;
			write_write_addr = mult5_write_addr_i;
			write_int_write_enable = mult5_int_write_enable_i;
			write_exc_bits = 32'b0;
			write_instruction = mult5_instruction_i;
			write_pc = mult5_pc_i;			
		end
		else if (cache_int_write_enable_i) begin /*TODO IDENTIFY FOR STORES?? EXC BITS*/
			write_int_write_data = cache_int_write_data_i;
			write_write_addr = cache_write_addr_i;
			write_int_write_enable = cache_int_write_enable_i;
			write_exc_bits = cache_exc_bits_i;
			write_instruction = cache_instruction_i;
			write_pc = cache_pc_i;			
		end
		else if (exe_int_write_enable_i && (exe_instruction_i[6:0] != 7'b0000011 && exe_instruction_i[6:0] != 7'b0100011 && !(exe_instruction_i[6:0] == 7'b0110011 && exe_instruction_i[31:25] == 7'b0000001))) begin
			write_int_write_data = exe_int_write_data_i;
			write_write_addr = exe_write_addr_i;
			write_int_write_enable = exe_int_write_enable_i;
			write_exc_bits = exe_exc_bits_i | {29'b0, exe_illegal_inst_exc_i, 2'b0};
			write_instruction = exe_instruction_i;
			write_pc = exe_pc_i;
		end
		else write_int_write_enable = 1'b0;
	end
end
endmodule	
