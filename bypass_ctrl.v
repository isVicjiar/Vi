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
output reg bypass_a_en_o,
output reg bypass_b_en_o,
output reg [31:0] bypass_data_a_o,
output reg [31:0] bypass_data_b_o,
output reg stall_core_o
);

// CASES:
/* EXE ADDR== + ENABLE + NOT LOAD
    C  ADDR== + ENABLE + HIT
    W  ADDR== + ENABLE
    MULT5 ADDR==
    
    if more than one, newest PC
    if load, if stage is ealrier than C, stall
    if mult, if stage is ealrier than M5, stall
*/
always @ (*) begin
    if (!rsn_i) begin
        bypass_a_en_o = 1'b0;
        bypass_b_en_o = 1'b0;
        bypass_data_a_o = 32'b0;
        bypass_data_b_o = 32'b0;
        stall_core_o = 1'b0;
    end
    else begin
        case ({exe_wr_en_i,mult1_wr_en_i,mult2_wr_en_i,mult3_wr_en_i,mult4_wr_en_i,mult5_wr_en_i,cache_wr_en_i,write_en_i})
            8'b10000000: begin
                
            end
            8'b01000000: begin
                
            end
            8'b00100000: begin
                
            end
            8'b00010000: begin
                
            end
            8'b00001000: begin
                
            end
            8'b00000100: begin
                
            end
            8'b00000010: begin
                
            end
            8'b00000001: begin
                
            end
            default: begin
                
            end
        endcase
    end
end
