// File for the bypass controller

module bypass_ctrl (
input clk_i,
input rsn_i,
input [4:0] read_addr_a_i,
input [4:0] read_addr_b_i,
input [31:0] exe_data_i,
input [4:0] exe_addr_i,
input exe_wr_en_i,
input [31:0] mult1_data_i,
input [4:0] mult1_addr_i,
input mult1_wr_en_i,
input [31:0] mult2_data_i,
input [4:0] mult2_addr_i,
input mult2_wr_en_i,
input [31:0] mult3_data_i,
input [4:0] mult3_addr_i,
input mult3_wr_en_i,
input [31:0] mult4_data_i,
input [4:0] mult4_addr_i,
input mult4_wr_en_i,
input [31:0] mult5_data_i,
input [4:0] mult5_addr_i,
input mult5_wr_en_i,
input [31:0] cache_data_i,
input [4:0] cache_addr_i,
input tl_hit_i,
input cache_wr_en_i,
input [31:0] write_data_i,
input [4:0] write_addr_i,
input write_en_i,
output bypass_a_en_o,
output bypass_b_en_o,
output [31:0] bypass_data_a_o,
output [31:0] bypass_data_b_o,
output stall_core_o
);

reg [31:0] bypass_data_a;
reg [31:0] bypass_data_b;
 
assign stall_core_o = () ?  x : 0;
assign bypass_data_a_o = (exe_wr_en_i && exe_addr_i == read_addr_a_i) ? exe_data_i : 32'b0;
  assign bypass_a_en_o = (exe_wr_en_i && exe_addr_i == read_addr_a_i) ? 1'b1 : 1'b0;
