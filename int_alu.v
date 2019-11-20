// Integer alu file

module int_alu(
input clk_i,
input rsn_i,
input [31:0] instr_i,
input [63:0] data_a_i,
input [63:0] data_b_i,
output [63:0] data_out_o);

wire	[6:0]	opcode;
wire	[6:0]	funct7;
wire	[2:0]	funct3;
reg	[63:0]	result;
wire	[63:0]	unsigned_ext_imm;
wire	[63:0]	ext_imm;

assign	opcode = instr_i[6:0];
assign	funct7 = instr_i[31:25];
assign	funct3 = instr_i[14:12];	

assign	ext_imm = {{52{instr_i[31]}}, instr_i[31:20]};
assign	unsigned_ext_imm = {52'b0, instr_i[31:20]};

always@(*)
begin
	case (opcode)
	7'b0110011: begin 
		case (funct3)
		3'b000: begin 
			case(funct7)
			7'b0000000: result = data_a + data_b; // Add
			7'b0100000: result = data_a - data_b; // Sub
			endcase
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
