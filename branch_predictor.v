// Branch predictor
module branch_predictor(
input   [31:0] pc_i,

output  [31:0] pred_pc_o,
output      pred_o,
output      taken_o);

assign pred_pc_o = pc_i;
assign pred_o = 0;
assign taken = 0;
endmodule

