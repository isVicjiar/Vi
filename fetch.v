// Fetch file

module fetch(
input		clk_i,
input		rsn_i,
input		dcsn_ok_i,
input		dcsn_i,
input	[31:0]	restore_pc,
input	[31:0]	alu_pc,

output	[31:0]	pc_o,
output		pred_o,
output		taken_o,
output	[31:0]	pred_pc_o,
output	[31:0]	instr_o);

/************
Next PC logic
************/
reg [31:0] pc;

wire [31:0] next_pc;
wire [31:0] pc_add_4;

//Branch predictor wires
wire [31:0] pred_pc;
wire pred;
wire taken;

assign pc_add_4 = pc + 4;
assign next_pc = dcsn_ok_i ? ((pred & taken) ? pred_pc : pc_add_4) 
                           : (dcsn_i ? restore_pc : alu_pc);
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
    pc = next_pc;
end

branch_predictor branch_predictor(
    .pc_i   (pc),

    .pred_pc_o  (pred_pc),
    .pred_o     (pred),
    .taken_o    (taken)
);

/********
Acces IC
********/
reg [31:0] fetched_inst;
assign instr_o = fetched_inst;


always @(negedge rsn_i)
begin
	fetched_inst = 32'b0;
end
endmodule
