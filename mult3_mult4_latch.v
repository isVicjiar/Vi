// Latch between mult3 and mult4

module mult3_mult4_latch(
input		clk_i,
input		rsn_i,
input	[31:0]	mult3_int_write_data_i,
input	[4:0]	mult3_write_addr_i,
input		mult3_int_write_enable_i,
input	[31:0]	mult3_instruction_i,
input	[31:0]	mult3_pc_i,
output	[31:0]	mult4_int_write_data_o,
output	[4:0]	mult4_write_addr_o,
output		mult4_int_write_enable_o,
output	[31:0]	mult4_instruction_o,
output 	[31:0]	mult4_pc_o);

reg	[31:0]	mult4_int_write_data;
reg	[4:0]	mult4_write_addr;
reg		mult4_int_write_enable;
reg	[31:0]	mult4_instruction;
reg 	[31:0]	mult4_pc;
	
assign mult4_int_write_data_o = mult4_int_write_data;
assign mult4_write_addr_o = mult4_write_addr;
assign mult4_int_write_enable_o = mult4_int_write_enable;
assign mult4_instruction_o = mult4_instruction;
assign mult4_pc_o = mult4_pc;
	
// Latch 
always @(posedge clock)
begin
	if (!rsn_i) begin
		mult4_int_write_data = 32'b0;
		mult4_write_addr = 5'b0;
		mult4_int_write_enable = 1'b0;
		mult4_instruction = 32'b0;
		mult4_pc = 32'b0;
	end
	else begin
		mult4_int_write_data = mult3_int_write_data_i;
		mult4_write_addr = mult3_write_addr_i;
		mult4_int_write_enable = mult3_int_write_enable_i;
		mult4_instruction = mult3_instruction_i;
		mult4_pc = mult3_pc_i;
	end
end
endmodule
