// Decoder file

module decoder(
input		clk_i,
input		rsn_i,
input	[31:0]	instr_i,

output	[4:0]	read_addr_a_o,
output	[4:0]	read_addr_b_o,
output	[4:0]	write_addr_o,
output		int_write_enable_o,
output	[1:0]	csr_addr_o,
output		csr_read_en_o,
output		iret_o);
	
reg int_write_enable;
reg csr_read_en;
	
assign read_addr_a_o = instr_i[19:15];
assign read_addr_b_o = instr_i[24:20];
assign write_addr_o = instr_i[11:7];
assign int_write_enable_o = int_write_enable;
assign csr_read_en_o = csr_read_en;
assign csr_addr_o = instr_i[21:20];

always @(*) begin
	iret_o = 1'b1;
	logic [6:0] funct7;
	logic [2:0] funct3;
	logic [6:0] opcode;
 	funct7 = instr_i[31:25];
	funct3 = instr_i[14:12];
	opcode = instr_i[6:0];
	if (!rsn_i) begin
		int_write_enable = 1'b0;
		csr_read_en = 1'b0;
	end
	else begin
		if (opcode == 7'1101111 || opcode == 7'1101111 || opcode == 7'b0100011 || opcode == 7'b1110011) int_write_enable = 1'b0;
		else int_write_enable = 1'b1;
		if (opcode == 7'b1110011 && instr_i[24:20] == 5'b00010 && instr_i[19:7] = 12'b0) begin
			iret_o = 1'b1;	
		end
		//csrrs rs1 1010 rd 1110011 CSRRS
		if (opcode == 7'b1110011 && funct3 == 3'b010) begin
			csr_read_en = 1'b1;
		end
		else csr_read_en = 1'b0;
	end
end
endmodule
