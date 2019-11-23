// Latch between mult1 and mult2

module exe_mult1_latch(
input		clk_i,
input		rsn_i,
input	[31:0]	mult2_int_write_data_i,
input	[4:0]	mult2_write_addr_i,
input		mult2_int_write_enable_i,
input	[31:0]	mult2_instruction_i,
input	[31:0]	mult2_pc_i,
output	[31:0]	mult3_int_write_data_o,
output	[4:0]	mult3_write_addr_o,
output		mult3_int_write_enable_o,
output	[31:0]	mult3_instruction_o,
output 	[31:0]	mult3_pc_o);

reg	[31:0]	mult3_int_write_data;
reg	[4:0]	mult3_write_addr;
reg		mult3_int_write_enable;
reg	[31:0]	mult3_instruction;
reg 	[31:0]	mult3_pc;
	
assign mult3_int_write_data_o = mult3_int_write_data;
assign mult3_write_addr_o = mult3_write_addr;
assign mult3_int_write_enable_o = mult3_int_write_enable;
assign mult3_instruction_o = mult3_instruction;
assign mult3_pc_o = mult3_pc;
	
// Latch 
always @(posedge clock)
begin
	if (!rsn_i) begin
		mult3_int_write_data = 32'b0;
		mult3_write_addr = 5'b0;
		mult3_int_write_enable = 1'b0;
		mult3_instruction = 32'b0;
		mult3_pc = 32'b0;
	end
	else begin
		mult3_int_write_data = mult2_int_write_data_i;
		mult3_write_addr = mult2_write_addr_i;
		mult3_int_write_enable = mult2_int_write_enable_i;
		mult3_instruction = mult2_instruction_i;
		mult3_pc = mult2_pc_i;
	end
end
endmodule
