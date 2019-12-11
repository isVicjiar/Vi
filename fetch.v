// Fetch file

module fetch(
input		clk_i,
input		rsn_i,
input		dcsn_ok_i,
input		dcsn_i,
input	[31:0]	restore_pc_i,
input	[31:0]	alu_pc_i,
input		stall_core_i,
input		iret_i,
input	[31:0]	exc_return_pc_i,
input		exc_occured_i,
output	[31:0]	pc_o,
output		pred_o,
output		taken_o,
output	[31:0]	pred_pc_o,
output	[31:0]	instr_o);

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
assign next_pc = dcsn_ok_i ? ((pred & taken) ? pred_pc : pc_add_4) : (dcsn_i ? restore_pc_i : alu_pc_i);
assign next_pc = pc_add_4;
assign pc_o = pc;
assign pred_o = pred;
assign taken_o = taken;
assign pred_pc_o = pred_pc;

always @(negedge rsn_i)
begin
    pc = 32'h1000;
end

always @(posedge clk_i)
begin
	if (!stall_core_i) begin
		if (iret_i) begin
			pc = exc_return_pc_i + 4;
		end
		else begin
			if (exc_occured_i) begin
				pc = exc_pc;
			end
			else pc = next_pc;
		end
	end
end

branch_predictor branch_predictor(
    .pc_i   (pc),

    .pred_pc_o  (pred_pc),
    .pred_o     (pred),
    .taken_o    (taken)
);

endmodule
