// Latch between registers and exe

module dec_reg_latch(
input		clock,
input		reset,
input	[4:0]	dec_read_addr_a,
input	[4:0]	dec_read_addr_b,
input	[4:0]	dec_write_addr,
input		dec_int_write_enable,
input	[31:0]	dec_instruction,

output	[4:0]	reg_read_addr_a,
output	[4:0]	reg_read_addr_b,
output	[4:0]	reg_write_addr,
output		reg_int_write_enable,
output	[31:0]	reg_instruction);

// Reset 
always @(negedge reset)
begin
	reg_read_addr_a = 0;
	reg_read_addr_b = 0;
	reg_write_addr = 0;
	reg_int_write_enable = 0;
	reg_instruction = 0;
end

// Latch 
always @(posedge clock)
begin
	if (clock == 1)
		reg_read_addr_a = dec_read_addr_a;
		reg_read_addr_b = dec_read_addr_b;
		reg_write_addr = dec_write_addr;
		reg_int_write_enable = dec_int_write_enable;
		reg_instruction = dec_instruction;
end
endmodule	
