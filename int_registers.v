// Register file

module int_registers(
input		clk_i,
input		rsn_i,
input	[31:0]	write_data_i,
input 	[31:0] 	rm_write_data_i,
input	[4:0]	read_addr_a_i,	
input	[4:0]	read_addr_b_i,
input	[1:0]	read_addr_rm_i,
input	[4:0] 	dec_write_addr_i,
input	[4:0]	write_addr_i,
input		write_enable_i,
input 	[1:0] 	rm_write_addr_i,
input 		rm_write_enable_i,
output	[31:0]	read_data_a_o,
output	[31:0]	read_data_b_o,
output  [31:0] 	read_data_rm_o
output 	[31:0] 	dec_dest_reg_value_o);

reg [31:0] registers [31:0];
reg [31:0] rmregisters [3:0];

/*
reg [31:0] mepc 	00;
reg [31:0] mcause 	01;
reg [31:0] mtval	10;
reg privilege		11;
	
/*
0x341MRW mepc Machine exception program counter.
0x342MRW mcause Machine trap cause.
0x343MRW mtval Machine bad address or instruction.
*/

// Read data
assign read_data_a_o = registers[read_addr_a_i];
assign read_data_b_o = registers[read_addr_b_i];
assign read_data_rm_o = rmregisters[read_addr_rm_i];
assign dec_dest_reg_value_o = registers[dec_write_addr_i];

// Write
always @(posedge(clk_i))
begin
	if (!rsn_i) for (int i=0; i<32; i=i+1) registers[i]=0;	
	else begin
		if (write_enable_i && write_addr > 5'b00000) registers[write_addr_i] = write_data_i;
		if (rm_write_enable_i) rmregisters[rm_write_addr_i] = rm_write_data_i;
	end
end
	
endmodule	
