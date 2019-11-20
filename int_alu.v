// Integer alu file

module int_alu(
input clk_i,
input rsn_i,
input [63:0] pc_i,
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
wire	[63:0] jal_ext_imm;
wire	[63:0] branch_ext_imm;
wire	[63:0] store_ext_imm;
wire	[63:0] load_ext_imm;

assign	opcode = instr_i[6:0];
assign	funct7 = instr_i[31:25];
assign	funct3 = instr_i[14:12];	

assign	ext_imm = {{52{instr_i[31]}}, instr_i[31:20]};
assign	unsigned_ext_imm = {52'b0, instr_i[31:20]};
assign  jal_ext_imm = { 43{instr_i[31]}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0 };
assign  branch_ext_imm = { 51{instr_i[31]}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0 };
assign  load_ext_imm = { 52{instr_i[31]}, instr_i[31:25], instr_i[11:7] };
assign  store_ext_imm = { 52{instr_i[31]}, instr_i[31:20] };

always@(*)
begin
	//  ADD, SUB, MUL, LDB, LDW, STB, STW, BEQ, JUMP RV64I
	case (opcode)
	7'b0110011: begin 
		case (funct3)
		3'b000: begin 
			case(funct7)
			7'b0000000: result = data_a_i + data_b_i; // Add
			7'b0100000: result = data_a_i - data_b_i; // Sub
			7'b0000001: result = data_a_i * data_b_i; // Mul
			endcase
		end
		endcase
	end
	7'b0010011: begin
		case(inst_type)
		3'b000: begin
			result = data_a_i + ext_imm; // Addi - NOP
		end
		endcase
	end
	7'b0000011: begin
		result = data_a_i + load_ext_imm; // Load
	end
	7'b0100011: begin
		result = data_a_i + store_ext_imm; // Store
	end
	7'b1100011: begin
		result =  (data_a_i == data_b_i) ? pc_i + branch_ext_imm : pc_i; // Beq
	end
	7'b1101111: begin
		result = pc_i + jal_ext_imm; // Jal
	end
	endcase
end
endmodule
