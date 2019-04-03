// Integer alu file

module int_alu(
input		clock,
input		reset,
input	[31:0]	instruction,
input	[63:0]	data_a,
input	[63:0]	data_b,

output	[63:0]	data_out);

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
		3'b010: begin // Slt
			if ($signed(data_a) < $signed(data_b))
				result = 64'b1;
			else 
				result = 64'b0;
		end
		3'b011: begin // Sltu
			if ($unsigned(data_a) < $unsigned(data_b))
				result = 64'b1;
			else
				result = 64'b0;
		end
		3'b100: begin 
			result = data_a ^ data_b; // Xor
		end
		3'b101: begin
			if (instruction[31:25]==7'b0000000) begin
				result = data_a >> data_b; // Srl
			end else if (instruction[31:25]==7'b0100000) begin
				result = data_a >>> data_b; // Sra
			end
		end
		3'b110: begin
			result = data_a | data_b; // Or
		end
		3'b111: begin
			result = data_a & data_b; // And
		end
		endcase
	end
	7'b0010011: begin
		case(inst_type)
		3'b000: begin
			result = data_a + ext_imm; // Addi
		end
		3'b010: begin // Slti
			if ($signed(data_a) < $signed(ext_imm)) 
				result = 64'b1;
			else
				result = 64'b0;
		end
		3'b011: begin // Sltiu
			if ($unsigned(data_a) < unsigned_ext_imm) 
				result = 64'b1;
			else
				result = 64'b0;
		end
		3'b100: begin 
			result = data_a ^ ext_imm; // Xori
		end
		3'b110: begin 
			result = data_a | ext_imm; // Ori
		end
		3'b111: begin 
			result = data_a & ext_imm; // Andi
		end
		3'b001: begin
			result = data_a << ext_imm; // Slli
		end
		3'b101: begin
			if (instruction[31:25]==7'b0000000) begin
				result = data_a >> ext_imm; // Srli
			end else if (instruction[31:25]==7'b0100000) begin
				result = data_a >>> ext_imm; // Srai
			end
		end
		endcase
	end
	endcase
end
endmodule
