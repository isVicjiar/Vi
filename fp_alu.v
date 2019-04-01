# Floating point alu file

module fp_alu(
input		clock,
input		reset,
input	31:0	instruction,
input	31:0	data_a,
input	31:0	data_b,
output	31:0	data_out);

case(instruction[31:25])
	'0000000': fadd;
	'0000100': fsub;
	'0001000': fmul;
	'0001100': fdiv;
endcase
