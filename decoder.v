// Decoder file

module decoder(
input		clk_i,
input		rsn_i,
input	[31:0]	instr_i,
input	[31:0]  pc_i,
output	[4:0]	read_addr_a_o,
output	[4:0]	read_addr_b_o,
output	[4:0]	write_addr_o,
output		int_write_enable_o,
output 	reg	tlbwrite_o,
output		idtlb_write_o,
output	[1:0]	csr_addr_o,
output		csr_read_en_o,
output	reg	iret_o,
output  reg	jal_o,
output  reg [31:0] jal_pc_o);
	
reg int_write_enable;
reg csr_read_en;
reg [6:0] funct7;
reg [2:0] funct3;
reg [6:0] opcode;
wire [31:0] jal_ext_imm;
	
assign read_addr_a_o = instr_i[19:15];
assign read_addr_b_o = instr_i[24:20];
assign write_addr_o = instr_i[11:7];
assign int_write_enable_o = int_write_enable;
assign csr_read_en_o = csr_read_en;
assign csr_addr_o = instr_i[21:20];
assign idtlb_write_o = instr_i[12];
assign jal_ext_imm = {{11{instr_i[31]}},instr_i[31],instr_i[19:12],instr_i[20],instr_i[30:21],1'b0};

always @(*) begin
	iret_o = 1'b0;
	jal_o = 1'b0;
	tlbwrite_o = 1'b0;
	csr_read_en = 1'b0;
 	funct7 = instr_i[31:25];
	funct3 = instr_i[14:12];
	opcode = instr_i[6:0];
	jal_pc_o = pc_i + jal_ext_imm; // Jal
	if (!rsn_i) begin
		int_write_enable = 1'b0;
		csr_read_en = 1'b0;
	end
	else begin
		if (opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0000011 || (opcode == 7'b1110011 && funct3 == 3'b010)) int_write_enable = 1'b1;
		else int_write_enable = 1'b0;
		if (opcode == 7'b1110011 && instr_i[24:20] == 5'b00010 && instr_i[19:7] == 12'b0) begin
			iret_o = 1'b1;	
		end
		if (opcode == 7'b1101111) begin
			jal_o = 1'b1;	
		end
		//csrrs rs1 1010 rd 1110011 CSRRS
		else if (opcode == 7'b1110011 && funct3 == 3'b010) begin
			csr_read_en = 1'b1;
		end
		//tlbwrite i instr[12] = 0 / d instr[12] = 1
		else if (opcode == 7'b1110011 && (funct3 == 3'b000 || funct3 == 3'b001)) begin
			tlbwrite_o = 1'b1;
		end
	end
end
endmodule
