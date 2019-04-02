// Integer alu file

module int_alu(
input		clock,
input		reset,
input	[31:0]	instruction,
input	[2:0]	inst_type,
input	[63:0]	data_a,
input	[63:0]	data_b,

output	[63:0]	data_out);

reg	7:0	inst_group;
reg	2:0	inst_type;
reg	63:0	result;
reg	63:0	unsigned_ext_imm;
reg	63:0	ext_imm;

assign	inst_group = instruction[7:0];
assign	inst_type = instruction[14:12];
assign	ext_imm = {42{instruction[31:20]}, instruction[31:20]};
assign	unsigned_ext_imm = {42'0b, instruction[31:20]};

case(inst_group)
'0110011': 
	case(inst_type)
	'000': 
		if (instruction[31:25]='0000000')
			result = data_a + data_b; // Add
		else
			if (instruction[31:25]='0100000')
				result = data_a - data_b; // Sub
			end
		end
	'001': result = data_a << data_b; // Sll
	'010': // Slt
		if (signed(data_a) < signed(data_b))
			result = 1;
		else
			result = 0;
		end
	'011': // Sltu
		if (unsigned(data_a) < unsigned(data_b))
			result = 1;
		else
			result = 0;
		end
	'100': result = data_a ^ data_b; // Xor
	'101':
		if (instruction[31:25]='0000000')
			result = data_a >> data_b; // Srl
		else 
			if (instruction[31:25]='0100000')
				result = data_a >>> data_b; // Sra
			end
		end
	'110': result = data_a | data_b; // Or
	'111': result = data_a $ data_b; // And
	endcase
'0010011':
	case(inst_type)
	'000': 
		result = data_a + ext_imm; // Addi
	'010': // Slti
		if (signed(data_a) < signed(ext_imm))
			result = 1;
		else
			result = 0;
		end
	'011': // Sltiu
		if (unsigned(data_a) < unsigned_ext_imm)
			result = 1;
		else
			result = 0;
		end
	'100': result = data_a ^ ext_imm}; // Xori
	'110': result = data_a | ext_imm}; // Ori
	'111': result = data_a $ ext_imm}; // Andi
	'001': result = data_a << ext_imm; // Slli
	'101':
		if (instruction[31:25]='0000000')
			result = data_a >> ext_imm; // Srli
		else 
			if (instruction[31:25]='0100000')
				result = data_a >>> ext_imm; // Srai
			end
		end
	endcase
endcase
