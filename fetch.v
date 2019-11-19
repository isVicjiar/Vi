// Fetch file

module fetch(
input		clk_i,
input		rsn_i,
input       old_pred_ok_i,
input       old_pred_i,
input   [31:0]  restore_pc,
input   [31:0]  alu_pc,

output  [31:0]  pc_o,
output	[31:0]	instr_o);

/************
Next PC logic
************/
reg [31:0] pc;

wire [31:0] next_pc;
wire [31:0] pc_add_4;

//Branch predictor wires
wire [31:0] predicted_pc;
wire predicted_jump;

assign pc_add_4 = pc + 4;
assign next_pc = old_pred_ok_i ? (predicted_jump ? predicted_pc : pc_add_4) :
                                 (old_pred_i     ? restore_pc   : alu_pc);
assign pc_o = pc;
always @(negedge rsn_i)
begin
    pc = 32'h1000;
end

always @(posedge clk_i)
begin
    pc = next_pc;
end

/****************
Fetch instruction
****************/
reg [31:0] fetched_inst;
assign instr_o = fetched_inst;


always @(negedge rsn_i)
begin
	fetched_inst = 32'b0;
end
