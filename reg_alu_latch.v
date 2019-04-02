# Latch between registers and alu

module reg_alu_latch(
input		clock,
input		reset,
input	[63:0]	reg_int_data_a,
input	[63:0]	reg_int_data_b,
input	[31:0]	reg_fp_data_a,
input	[31:0]	reg_fp_data_b,
input	[31:0]	reg_instruction,
output	[63:0]	alu_int_data_a,
output	[63:0]	alu_int_data_b,
output	[31:0]	alu_fp_data_a,
output	[31:0]	alu_fp_data_b,
output	[31:0]	alu_instruction);

# Reset 
always @(negedge reset)
begin
	alu_data_a = 0;
	alu_data_b = 0;
end

# Latch 
always @(posedge clock)
begin
	if (clock == 1)
		alu_int_data_a = reg_int_data_a;
		alu_int_data_b = reg_int_data_b;
		alu_fp_data_a = reg_fp_data_a;
		alu_fp_data_b = reg_fp_data_b;
		alu_instruction = reg_instruction;
	end
end
end module	
