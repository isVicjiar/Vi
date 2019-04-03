// Fetch file

module fetch(
input		clock,
input		reset,

output	[31:0]	instruction);

reg [31:0] fetched_inst;

assign instruction = fetched_inst;

always @(negedge reset)
begin
	fetched_inst = 32'b0;
end
