// Latch between execution and write back

module exe_wb_latch(
input		clock,
input		reset,
input	[63:0]	exe_int_write_data,
input	[4:0]	exe_write_addr,
input		exe_int_write_enable,
input	[31:0]	exe_instruction,

output	[63:0]	wb_int_write_data,
output	[4:0]	wb_write_addr,
output		wb_int_write_enable,
output	[31:0]	wb_instruction);

// Reset 
always @(negedge reset)
begin
	wb_int_write_data = 0;
	wb_write_addr = 0;
	wb_int_write_enable = 0;
	wb_instruction = 0;
end

// Latch 
always @(posedge clock)
begin
	if (clock == 1)
		wb_int_write_data = exe_int_write_data;
		wb_write_addr = exe_write_addr;
		wb_int_write_enable = exe_int_write_enable;
		wb_instruction = exe_instruction;
end
endmodule	
