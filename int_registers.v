// Register file

module int_registers(
input		clk_i,
input		rsn_i,
input	[31:0]	write_data_i,
input	[4:0]	read_addr_a_i,	
input	[4:0]	read_addr_b_i,
input	[4:0]	write_addr_i,
input		write_enable_i,
output	[31:0]	read_data_a_o,
output	[31:0]	read_data_b_o);

reg [31:0] registers [31:0];
reg [31:0] mepc;
reg [31:0] mcause;
reg [31:0] mtval;

// Read data
assign read_data_a_o = registers[read_addr_a_i];
assign read_data_b_o = registers[read_addr_b_i];

// Write
always @(posedge(clk_i))
begin
	if (!rsn_i) for (int i=0; i<32; i=i+1) registers[i]=0;	
	else if (write_enable_i && write_addr > 5'b00000) registers[write_addr_i] = write_data_i;
end
	
endmodule	
