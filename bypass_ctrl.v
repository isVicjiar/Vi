// File for the bypass controller

module bypass_ctrl (
input clk_i,
input rsn_i,
input [4:0] dec_read_addr_a_i,
input [4:0] dec_read_addr_b_i,
input dec_wr_en_i,
input [4:0] dec_wr_addr_i,
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
/* EXE ADDR== + ENABLE + NOT LOAD/MULT
    C  ADDR== + ENABLE + HIT
    W  ADDR== + ENABLE
    MULT5 ADDR==
    
    if more than one, newest PC
    if load, if stage is ealrier than C, stall
    if mult, if stage is ealrier than M5, stall
*/
always @ (*) begin
    logic [31:0] newest_pc_a;
    logic [31:0] newest_pc_b;
    logic [7:0] wr_ens;
    wr_ens = {exe_wr_en_i,mult1_wr_en_i,mult2_wr_en_i,mult3_wr_en_i,mult4_wr_en_i,mult5_wr_en_i,cache_wr_en_i,write_en_i};
    if (!rsn_i) begin
        bypass_a_en_o = 1'b0;
        bypass_b_en_o = 1'b0;
        bypass_data_a_o = 32'b0;
        bypass_data_b_o = 32'b0;
        stall_core_o = 1'b0;
    end
    else begin
        if (dec_wr_en_i) begin
            if ((write_en_i && write_addr_i == dec_wr_addr_i) || !(|wr_ens[7:1])) stall_core = 1'b0;
            else begin
                
            end
        end
        else begin
            case ()
                8'b10000000: begin
                    bypass_a_en_o = 
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
        
        if (exe_wr_en_i) begin
            if (exe_addr_i == read_addr_a_i) begin 
                if (load || mult) stall_core_a = 1'b1;
                else begin
                    bypass_a_en_o = 1'b1;
                    bypass_data_a_o = exe_data_i;
                    newest_pc_a = exe_pc_i;
                    stall_core_a = 1'b0;
                end
            end
            if (exe_addr_i == read_addr_b_i) begin 
                if (load || mult) stall_core_b = 1'b1;
                else begin
                    bypass_b_en_o = 1'b1;
                    bypass_data_b_o = exe_data_i;
                    newest_pc_b = exe_pc_i;
                    stall_core_b = 1'b0;
                end
            end
        end
        
        //exe_wr_en_i,mult1_wr_en_i,mult2_wr_en_i,mult3_wr_en_i,mult4_wr_en_i,mult5_wr_en_i,cache_wr_en_i,write_en_i
          
    end
end
