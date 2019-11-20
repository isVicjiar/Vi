// Integer alu file

module int_alu(
	input clk_i,
	input rsn_i,
	input [31:0] instr_i,
	input [63:0] data_a_i,
	input [63:0] data_b_i,
	output [63:0] data_out_o);

	wire	[7:0]	inst_group;
wire	[2:0]	inst_type;
reg	[63:0]	result;
wire	[63:0]	unsigned_ext_imm;
wire	[63:0]	ext_imm;

assign	inst_group = instruction[7:0];
assign	inst_type = instruction[14:12];
assign	ext_imm = {{52{instruction[31]}}, instruction[31:20]};
assign	unsigned_ext_imm = {42'b0, instruction[31:20]};

always@(*)
begin
	case (inst_group)
	7'b0110011: begin 
		case(inst_type)
		3'b000: begin 
			if (instruction[31:25]==7'b0000000) begin
				result = data_a + data_b; // Add
			end else if (instruction[31:25]==7'b0100000) begin
				result = data_a - data_b; // Sub
			end
		end
		3'b001: begin
			 result = data_a << data_b; // Sll
		end
		endcase
	end
	7'b0010011: begin
		case(inst_type)
		3'b000: begin
			result = data_a + ext_imm; // Addi
		end
		endcase
	end
	endcase
end
endmodule
