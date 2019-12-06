// Latch between mult1 and mult2

module mult1_mult2_latch(
input		clk_i,
input		rsn_i,
input		kill_i,
input	[31:0]	mult1_int_write_data_i,
input	[4:0]	mult1_write_addr_i,
input		mult1_int_write_enable_i,
input	[31:0]	mult1_instruction_i,
input	[31:0]	mult1_pc_i,
output	[31:0]	mult2_int_write_data_o,
output	[4:0]	mult2_write_addr_o,
output		mult2_int_write_enable_o,
output	[31:0]	mult2_instruction_o,
output 	[31:0]	mult2_pc_o);

reg	[31:0]	mult2_int_write_data;
reg	[4:0]	mult2_write_addr;
reg		mult2_int_write_enable;
reg	[31:0]	mult2_instruction;
reg 	[31:0]	mult2_pc;
	
assign mult2_int_write_data_o = mult2_int_write_data;
assign mult2_write_addr_o = mult2_write_addr;
assign mult2_int_write_enable_o = mult2_int_write_enable;
assign mult2_instruction_o = mult2_instruction;
assign mult2_pc_o = mult2_pc;
	
// Latch 
always @(posedge clock)
begin
	if (!rsn_i || kill_i) begin
		mult2_int_write_data = 32'b0;
		mult2_write_addr = 5'b0;
		mult2_int_write_enable = 1'b0;
		mult2_instruction = 32'b0;
		mult2_pc = 32'b0;
	end
	else begin
		mult2_int_write_data = mult1_int_write_data_i;
		mult2_write_addr = mult1_write_addr_i;
		mult2_int_write_enable = mult1_int_write_enable_i;
		mult2_instruction = mult1_instruction_i;
		mult2_pc = mult1_pc_i;
	end
end
endmodule
