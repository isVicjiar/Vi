// Latch between registers and exe

module reg_exe_latch(
input		clock,
input		reset,
input	[63:0]	reg_int_data_a,
input	[63:0]	reg_int_data_b,
input	[31:0]	reg_fp_data_a,
input	[31:0]	reg_fp_data_b,
input		reg_int_write_enable,
input		reg_fp_write_enable,
input	[4:0]	reg_write_addr,
input	[31:0]	reg_instruction,

output	[63:0]	exe_int_data_a,
output	[63:0]	exe_int_data_b,
output	[31:0]	exe_fp_data_a,
output	[31:0]	exe_fp_data_b,
output		exe_int_write_enable,
output		exe_fp_write_enable,
output	[4:0]	exe_write_addr,
output	[31:0]	exe_instruction);

// Reset 
always @(negedge reset)
begin
	exe_int_data_a = 0;
	exe_int_data_b = 0;
	exe_fp_data_a = 0;
	exe_fp_data_b = 0;
	exe_int_write_enable = 0;
	exe_fp_write_enable = 0;
	exe_write_addr = 0;
	exe_instruction = 0;
end

// Latch 
always @(posedge clock)
begin
	if (clock == 1)
		exe_int_data_a = reg_int_data_a;
		exe_int_data_b = reg_int_data_b;
		exe_fp_data_a = reg_fp_data_a;
		exe_fp_data_b = reg_fp_data_b;
		exe_int_write_enable = reg_int_write_enable;
		exe_fp_write_enable = reg_fp_write_enable;
		exe_write_addr = reg_write_addr;
		exe_instruction = reg_instruction;
	end
end
end module	
