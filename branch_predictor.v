// Branch predictor
module branch_predictor(
    input          clk_i,
    input          rsn_i,
    input   [31:0] pc_i,

    output  [31:0] pred_pc_o,
    output         branch_o);

reg [31:0] pc_array[15:0];
reg [31:0] pc_branch_array[15:0];
reg [1:0] conf_array[15:0];

reg [31:0] pred_pc;
reg branch;

assign pred_pc_o = pred_pc;
assign branch_o = branch;


integer i;
always @(posedge clk_i)
begin
    for(i = 0; i<16; i = i+1) begin
        if(pc_array[i] == pc_i) begin
            branch <= (conf_array[i] > 1);
            pred_pc <= pc_branch_array[i];
            i = 16;
        end
    end
end


endmodule

