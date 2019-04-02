// Latch between fetch and decode

module fetch_dec_latch(
input		clock,
input		reset,
input	[31:0]	fetch_instruction,

output	[31:0]	dec_instruction);

// Reset 
always @(negedge reset)
begin
	dec_instruction = 0;
end

// Latch 
always @(posedge clock)
begin
	if (clock == 1)
		dec_instruction = fetch_instruction;
	end
end
end module	
