// History file

module history_file (
input clk_i,
input rsn_i,
input [4:0] dec_dest_reg_i,
input [31:0] miss_addr_i,
input [31:0] dec_pc_i,
input [31:0] dec_dest_reg_value_i,
input [4:0] wb_dest_reg_i,
input wb_exc_i);
