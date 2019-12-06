// Latch between mult4 and mult5

module mult4_mult5_latch(
input		clk_i,
input		rsn_i,
input		kill_i,
input	[31:0]	mult4_int_write_data_i,
input	[4:0]	mult4_write_addr_i,
input		mult4_int_write_enable_i,
input	[31:0]	mult4_instruction_i,
input	[31:0]	mult4_pc_i,
output	[31:0]	mult5_int_write_data_o,
output	[4:0]	mult5_write_addr_o,
output		mult5_int_write_enable_o,
output	[31:0]	mult5_instruction_o,
output 	[31:0]	mult5_pc_o);

reg	[31:0]	mult5_int_write_data;
reg	[4:0]	mult5_write_addr;
reg		mult5_int_write_enable;
reg	[31:0]	mult5_instruction;
reg 	[31:0]	mult5_pc;
	
assign mult5_int_write_data_o = mult5_int_write_data;
assign mult5_write_addr_o = mult5_write_addr;
assign mult5_int_write_enable_o = mult5_int_write_enable;
assign mult5_instruction_o = mult5_instruction;
assign mult5_pc_o = mult5_pc;
	
// Latch 
always @(posedge clock)
begin
	if (!rsn_i || kill_i) begin
		mult5_int_write_data = 32'b0;
		mult5_write_addr = 5'b0;
		mult5_int_write_enable = 1'b0;
		mult5_instruction = 32'b0;
		mult5_pc = 32'b0;
	end
	else begin
		mult5_int_write_data = mult4_int_write_data_i;
		mult5_write_addr = mult4_write_addr_i;
		mult5_int_write_enable = mult4_int_write_enable_i;
		mult5_instruction = mult4_instruction_i;
		mult5_pc = mult4_pc_i;
	end
end
endmodule
