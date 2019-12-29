// Fetch file

module fetch(
input		clk_i,
input		rsn_i,
input	[31:0]	alu_pc_i,
input		stall_core_i,
input		iret_i,
input	[31:0]	exc_return_pc_i,
input		jal_i,
input	[31:0]	jal_pc_i,
input		exc_occured_i,
output	[31:0]	pc_o);

/************
Next PC logic
************/
reg [31:0] pc;
reg [31:0] exc_pc;

wire [31:0] next_pc;
wire [31:0] pc_add_4;

//Branch predictor wires
wire [31:0] pred_pc;
wire pred;
wire taken;

assign pc_add_4 = pc + 4;
//assign next_pc = dcsn_ok_i ? ((pred & taken) ? pred_pc : pc_add_4) : (dcsn_i ? restore_pc_i : alu_pc_i);
assign next_pc = pc_add_4;
assign pc_o = pc;
assign pred_o = pred;
assign taken_o = taken;
assign pred_pc_o = pred_pc;

always @(posedge rsn_i) pc = 32'h1000;

always @(posedge clk_i)
begin
	if (!rsn_i) begin
		pc = 32'h1000;
		exc_pc = 32'h2000;
	end
	else if (jal_i) begin
		pc = jal_pc_i + 4;
		if (stall_core_i) pc = jal_pc_i;	
	end
	else if (iret_i) begin
		pc = exc_return_pc_i + 4;
		if (stall_core_i) pc = exc_return_pc_i;
	end
	else if (exc_occured_i) begin
		pc = exc_pc;
	end
	else if (!stall_core_i) pc = next_pc;
end

endmodule
