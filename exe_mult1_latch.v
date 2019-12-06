// Latch between execution and mult1

module exe_mult1_latch(
input		clk_i,
input		rsn_i,
input 		kill_i,
input	[31:0]	exe_int_write_data_i,
input	[4:0]	exe_write_addr_i,
input		exe_int_write_enable_i,
input	[31:0]	exe_instruction_i,
input	[31:0]	exe_pc_i,
output	[31:0]	mult1_int_write_data_o,
output	[4:0]	mult1_write_addr_o,
output		mult1_int_write_enable_o,
output	[31:0]	mult1_instruction_o,
output 	[31:0]	mult1_pc_o);

reg	[31:0]	mult1_int_write_data;
reg	[4:0]	mult1_write_addr;
reg		mult1_int_write_enable;
reg	[31:0]	mult1_instruction;
reg 	[31:0]	mult1_pc;
	
assign mult1_int_write_data_o = mult1_int_write_data;
assign mult1_write_addr_o = mult1_write_addr;
assign mult1_int_write_enable_o = mult1_int_write_enable;
assign mult1_instruction_o = mult1_instruction;
assign mult1_pc_o = mult1_pc;
	
// Latch 
always @(posedge clock)
begin
	if (!rsn_i || kill_i) begin
		mult1_int_write_data = 32'b0;
		mult1_write_addr = 5'b0;
		mult1_int_write_enable = 1'b0;
		mult1_instruction = 32'b0;
		mult1_pc = 32'b0;
	end
	else begin
		if (exe_instruction_i[31:25] == 7'b0000001 && exe_instruction_i[6:0] == 7'b0110011) begin
			mult1_int_write_data = exe_int_write_data_i;
			mult1_write_addr = exe_write_addr_i;
			mult1_int_write_enable = exe_int_write_enable_i;
			mult1_instruction = exe_instruction_i;
			mult1_pc = exe_pc_i;
		else
			mult1_int_write_enable = 1'b0;
			mult1_instruction = exe_instruction_i;
			mult1_pc = exe_pc_i;
		end
	end
end
endmodule
