// Decoder file

module decoder(
input		clk_i,
input		rsn_i,
input	[31:0]	instr_i,

output	[4:0]	read_addr_a_o,
output	[4:0]	read_addr_b_o,
output	[4:0]	write_addr_o,
output		int_write_enable_o);
	
reg bit int_write_enable;

assign read_addr_a_o = instr_i[19:15];
assign read_addr_b_o = instr_i[24:20];
assign write_addr_o = instr_i[11:7];
assign int_write_enable_o = int_write_enable;

always @(*) begin
	logic [6:0] funct7;
	logic [2:0] funct3;
	logic [6:0] opcode;
 	funct7 = instr_i[31:25];
	funct3 = instr_i[14:12];
	opcode = instr_i[6:0];
	if (!rsn_i) int_write_enable = 1'b0;
	else begin
		if (opcode == 7'1101111 || opcode == 7'1101111 || opcode == 7'b0100011) int_write_enable = 1'b0;
		else int_write_enable = 1'b1;
	end
end
endmodule
