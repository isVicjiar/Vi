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
integer i;

// Reset 
always @(negedge reset)
begin
	for (i=0; i<32; i=i+1) registers[i]=0;	
end

// Read data
assign read_data_a = registers[read_addr_a];
assign read_data_b = registers[read_addr_b];

// Write
always @(clock)
begin
	if (clock == 1)
		if (write_enable == 1)
			if (write_addr > 5'b00000) registers[write_addr] = write_data;
end
endmodule	
