// Branch predictor
module branch_predictor(
    input           clk_i,
    input           rsn_i,
    input   [31:0]  pc_i,
    input   [31:0]  target_pc_i,
    input           alu_branch_i,
    input           alu_jumps_i,
    input           alu_prediction_i,
    input           alu_taken_i,
    input           alu_pc_ok_i,
    input   [31:0]  alu_branch_pc_i,

    output  [31:0]  pred_pc_o,
    output          prediction_o,
    output          taken_o,
    output          bp_error_o);

reg [31:0] branch_pc_array[15:0];
reg [31:0] target_pc_array[15:0];
reg [1:0]  taken_array[15:0];

reg [31:0] pred_pc;
reg taken;
reg prediction;

wire error;
assign pred_pc_o = pred_pc;
assign taken_o = taken;
assign prediction_o = predictor;
assign error = (!alu_branch_i & alu_prediction_i & alu_taken_i) |
               (alu_prediction_i & alu_taken_i & !alu_pc_ok_i)  |
               (alu_branch_i & alu_jumps_i & !alu_prediction_i) |
               (alu_branch_i & alu_jumps_i & !alu_pc_ok_i);
assign bp_error_o = error;           

wire [3:0]  pc_map;
wire [3:0]  branch_pc_map;
assign pc_map = pc_i[5:2];
assign branch_pc_map = alu_branch_pc_i[5:2];

always @(posedge clk_i)
begin
    taken <= (taken_array[pc_map] > 1);
    prediction <= branch_pc_array[pc_map] == pc_i;
    pred_pc <= target_pc_array[pc_map];
end

wire [1:0]  taken_value;
assign taken_value = taken_array[branch_pc_map];


integer i;
always @(posedge clk_i)
begin
    if(!rsn_i)
    begin
        prediction <= 1'b0;
        taken <= 1'b0;
        pred_pc <= 32'b0;
        for(i = 0; i<16; i = i+1) begin
            branch_pc_array[i] <= 32'b0;
            target_pc_array[i] <= 32'b0;
            taken_array[i] <= 32'b0;
        end
    end
    if(error)
    begin
        if (branch_pc_array[branch_pc_map] == alu_branch_pc_i & target_pc_array[branch_pc_map] == target_pc_i) 
        begin
            taken_array[branch_pc_map] <= alu_jumps_i ? 
                                          (taken_value == 2'b11 ? 2'b11 : taken_value + 1) : 
                                          (taken_value == 2'b00 ? 2'b00 : taken_value - 1);  

        end else begin
            taken_array[branch_pc_map] <= 2'b10;
            branch_pc_array[branch_pc_map] <= alu_branch_pc_i;
            target_pc_array[branch_pc_map] <= target_pc_i;
        end
    end
end


endmodule

