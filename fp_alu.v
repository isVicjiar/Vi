// Floating point alu file

module fp_alu(
input		clock,
input		reset,
input	[31:0]	instruction,
input	[31:0]	data_a,
input	[31:0]	data_b,

output	[31:0]	data_out);

reg [31:0] result;

assign data_out=result;

always @(*)
begin
	case(instruction[31:25])
		7'b0000000: begin
			result=32'b0; // Fadd
		end
		7'b0000100: begin 
			result=32'b0; // Fsub
		end
		7'b0001000: begin
			result=32'b0; // Fmul
		end
		7'b0001100: begin
			result=32'b0; // Fdiv
		end
	endcase
end
endmodule
