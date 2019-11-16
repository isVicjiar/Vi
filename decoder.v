// Decoder file

module decoder(
input		clock,
input		reset,
input	[31:0]	instruction,

output	[4:0]	read_addr_a, //rs1
output	[4:0]	read_addr_b, //rs2
output	[4:0]	write_addr,  //rd
output  [4:0]	rs3,
output	[6:0]	funct7,
output	[2:0]	funct3,
output	[6:0]	opcode,
output		int_write_enable);

assign read_addr_a = instruction[19:15];
assign read_addr_b = instruction[24:20];
assign write_addr = instruction[11:7];
assign rs3 = instruction[31:27];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
assign opcode = instruction[6:0];

always @(negedge reset)
begin
	read_addr_a = 0;
	read_addr_b = 0;
	write_addr = 0;
	rs3 = 0;
	funct7 = 0;
	funct3 = 0;
	opcode = 0;

end

always @(instruction)
begin
	
end
endmodule
