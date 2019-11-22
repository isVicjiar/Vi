// Latch between registers and exe

module dec_reg_latch(
input		clk_i,
input		rsn_i,
input	[31:0]	dec_read_data_a_i,
input	[31:0]	dec_read_data_b_i,
input	[31:0]	dec_write_addr_i,
input		dec_int_write_enable_i,
input	[31:0]	dec_instruction_i,

output	[31:0]	exe_read_data_a_o,
output	[31:0]	exe_read_data_b_o,
output	[31:0]	exe_write_addr_o,
output		exe_int_write_enable_o,
output	[31:0]	exe_instruction_o);

reg	[31:0]	exe_read_data_a;
reg	[31:0]	exe_read_data_b;
reg	[31:0]	exe_write_addr;
reg	exe_int_write_enable;
reg	[31:0]	exe_instruction;
	
assign exe_read_data_a_o = exe_read_data_a;
assign exe_read_data_b_o = exe_read_data_b;
assign exe_write_addr_o = exe_write_addr;
assign exe_int_write_enable_o = exe_int_write_enable;
assign exe_instruction_o = exe_instruction;
	
// Latch 
always @(posedge clock)
begin
	if (!rsn_i) begin
		exe_read_addr_a = 0;
		exe_read_addr_b = 0;
		exe_write_addr = 0;
		exe_int_write_enable = 0;
		exe_instruction = 0;
	end
	else begin
		exe_read_addr_a = dec_read_addr_a_i;
		exe_read_addr_b = dec_read_addr_b_i;
		exe_write_addr = dec_write_addr_i;
		exe_int_write_enable = dec_int_write_enable_i;
		exe_instruction = dec_instruction_i;
	end
end
endmodule
