// Fetch file

module fetch(
input		clk_i,
input		rsn_i,
input		stall_core_i,
input		iret_i,
input	[31:0]	exc_return_pc_i,
input		jal_i,
input	[31:0]	jal_pc_i,
input		exc_occured_i,
input   [31:0]  bp_pred_pc_i,
input       bp_prediction_i,      
input       bp_taken_i,
input       bp_error_i,
input       alu_branch_i,
input       alu_jumps_i,
input	[31:0]	alu_pc_jmp_i,
input	[31:0]	alu_pc_no_jmp_i,
output	[31:0]	pc_o,
output	[31:0]	next_pc_o);

/************
Next PC logic
************/
reg [31:0] pc;
reg [31:0] exc_pc;

wire [31:0] next_pc;
wire [31:0] pc_add_4;


assign pc_add_4 = pc + 4;
assign next_pc = bp_error_i ?
                (alu_branch_i & alu_jumps_i ? alu_pc_jmp_i : alu_pc_no_jmp_i) :
                (bp_prediction_i & bp_taken_i ? bp_pred_pc_i : pc_add_4);
assign pc_o = pc;
assign next_pc_o = next_pc;

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
	else if (!stall_core_i || bp_error_i) pc = next_pc;
end

endmodule
