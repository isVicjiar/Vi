// Decoder file

module decoder(
input		clock,
input		reset,
input	[31:0]	instruction,

output	[4:0]	read_addr_a,
output	[4:0]	read_addr_b,
output	[4:0]	write_addr,
output		int_write_enable,
output		fp_write_enable);
