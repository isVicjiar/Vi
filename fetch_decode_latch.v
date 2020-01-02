// Latch between fetch and decode

module fetch_dec_latch(
input			clk_i,
input			rsn_i,
input 			stall_core_i,
input			kill_i,
input           stall_fetch_i,
input			fetch_misaligned_instr_exc_i,
input			fetch_instr_fault_exc_i,
input  [31:0]   fetch_instr_i,
input  [31:0]   fetch_pc_i,
input  [31:0]   fetch_pred_pc_i,
input           fetch_prediction_i, 
input           fetch_taken_i,
output [31:0]   dec_pred_pc_o,
output  		dec_prediction_o,
output  		dec_taken_o,
output [31:0]	dec_exc_bits_o, 
output [31:0]	dec_instr_o,
output [31:0]	dec_pc_o);

reg [31:0]	dec_pred_pc;
reg  		dec_prediction;
reg  		dec_taken;
reg [31:0]	dec_exc_bits;
reg [31:0]	dec_instr;
reg [31:0]	dec_pc;

reg sc;
assign dec_pred_pc_o =  dec_pred_pc;
assign dec_prediction_o =  dec_prediction;
assign dec_taken_o =  dec_taken;
assign dec_exc_bits_o =  dec_exc_bits;
assign dec_instr_o =  dec_instr;
assign dec_pc_o =  dec_pc;
// Latch 
always @(posedge clk_i)
begin
	if (!rsn_i || kill_i || (stall_fetch_i & !stall_core_i)) begin
		sc = 0;
		dec_pred_pc = 32'b0;
		dec_prediction = 1'b0;
		dec_taken = 1'b0;
		dec_exc_bits = 32'b0;
		dec_pc = 32'b0;
		dec_instr = 32'b0;
	end
	else begin
		if (!stall_core_i) begin
            dec_pred_pc = fetch_pred_pc_i;
            dec_prediction = fetch_prediction_i;
            dec_taken = fetch_taken_i;
			dec_exc_bits = {19'b0,fetch_instr_fault_exc_i,11'b0,fetch_misaligned_instr_exc_i};
			dec_instr = fetch_instr_i;
			dec_pc = fetch_pc_i;
		end
		sc = stall_core_i;
	end
end
endmodule	
