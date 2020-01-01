// File for the bypass controller

module bypass_ctrl (
input clk_i,
input rsn_i,
input [4:0] dec_read_addr_a_i,
input [4:0] dec_read_addr_b_i,
input dec_wr_en_i,
input [4:0] dec_wr_addr_i,
input [31:0] dec_instr_i,
input [31:0] exe_data_i,
input [4:0] exe_addr_i,
input exe_wr_en_i,
input [31:0] exe_instr_i,
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
input [4:0] tl_addr_i,
input tl_wr_en_i,
input tl_cache_en_i,
input [31:0] cache_data_i,
input [4:0] cache_addr_i,
input cache_wr_en_i,
input cache_en_i,
input cache_hit_i,
input [31:0] write_data_i,
input [4:0] write_addr_i,
input write_en_i,
output reg bypass_a_en_o,
output reg bypass_b_en_o,
output reg [31:0] bypass_data_a_o,
output reg [31:0] bypass_data_b_o,
output stall_core_o
);
 
reg stall_core_a;
reg stall_core_b;
reg stall_core_w;
reg [8:0] wr_ens;
 
assign stall_core_o = stall_core_a || stall_core_b || stall_core_w;
 
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
    wr_ens = {exe_wr_en_i,mult1_wr_en_i,mult2_wr_en_i,mult3_wr_en_i,mult4_wr_en_i,mult5_wr_en_i,tl_wr_en_i,cache_wr_en_i,write_en_i};
    if (!rsn_i) begin
        bypass_a_en_o = 1'b0;
        bypass_b_en_o = 1'b0;
        bypass_data_a_o = 32'b0;
        bypass_data_b_o = 32'b0;
        stall_core_a = 1'b0;
        stall_core_b = 1'b0;
        stall_core_w = 1'b0;
    end
    else begin
	bypass_a_en_o = 1'b0;    
	bypass_b_en_o = 1'b0;    
        stall_core_a = 1'b0;
        stall_core_b = 1'b0;
        stall_core_w = 1'b0;
        if (dec_wr_en_i) begin 
            case (wr_ens)
                9'b100000000: stall_core_w = (exe_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b010000000: stall_core_w = (mult1_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b001000000: stall_core_w = (mult2_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b000100000: stall_core_w = (mult3_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b000010000: stall_core_w = (mult4_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b000001000: stall_core_w = (mult5_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b000000100: stall_core_w = (tl_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                9'b000000010: stall_core_w = (cache_addr_i == dec_wr_addr_i) ? 1'b1 : 1'b0;
                default: stall_core_w = 1'b0;
            endcase
            case (dec_instr_i[6:0])
                (7'b0110011): begin
                    if (exe_instr_i[31:25] != 7'b0000001) begin
                        if (tl_cache_en_i || mult4_wr_en_i || (cache_en_i && !cache_hit_i)) stall_core_w = 1'b1;
                    end
                end
                (7'b0000011): if (mult2_wr_en_i) stall_core_w = 1'b1;
                (7'b0100011): if (mult2_wr_en_i) stall_core_w = 1'b1;
                default: stall_core_w = 1'b0;
            endcase
        end        
        if (exe_wr_en_i) begin
            if (exe_addr_i == dec_read_addr_a_i) begin 
             if (exe_instr_i[6:0] == 7'b0000011 || (exe_instr_i[6:0] == 7'b0110011 && exe_instr_i[31:25] == 7'b0000001)) stall_core_a = 1'b1;
                else begin
                    bypass_a_en_o = 1'b1;
                    bypass_data_a_o = exe_data_i;
                    stall_core_a = 1'b0;
                end
            end
            if (exe_addr_i == dec_read_addr_b_i) begin 
                if (exe_instr_i[6:0] == 7'b0000011 || (exe_instr_i[6:0] == 7'b0110011 && exe_instr_i[31:25] == 7'b0000001)) stall_core_b = 1'b1;
                else begin
                    bypass_b_en_o = 1'b1;
                    bypass_data_b_o = exe_data_i;
                    stall_core_b = 1'b0;
                end
            end
        end        
        if (mult1_wr_en_i) begin
            if (mult1_addr_i == dec_read_addr_a_i) stall_core_a = 1'b1;
            if (mult1_addr_i == dec_read_addr_b_i) stall_core_b = 1'b1;
        end           
        if (mult2_wr_en_i) begin
            if (mult2_addr_i == dec_read_addr_a_i) stall_core_a = 1'b1;
            if (mult2_addr_i == dec_read_addr_b_i) stall_core_b = 1'b1;
        end           
        if (mult3_wr_en_i) begin
            if (mult3_addr_i == dec_read_addr_a_i) stall_core_a = 1'b1;
            if (mult3_addr_i == dec_read_addr_b_i) stall_core_b = 1'b1;
        end           
        if (mult4_wr_en_i) begin
            if (mult4_addr_i == dec_read_addr_a_i) stall_core_a = 1'b1;
            if (mult4_addr_i == dec_read_addr_b_i) stall_core_b = 1'b1;
        end        
        if (mult5_wr_en_i) begin
            if (mult5_addr_i == dec_read_addr_a_i) begin 
                bypass_a_en_o = 1'b1;
                bypass_data_a_o = mult5_data_i;
            end
            if (mult5_addr_i == dec_read_addr_b_i) begin 
                bypass_b_en_o = 1'b1;
                bypass_data_b_o = mult5_data_i;
            end
        end
        if (tl_wr_en_i) begin
            if (tl_addr_i == dec_read_addr_a_i) stall_core_a = 1'b1;
            if (tl_addr_i == dec_read_addr_b_i) stall_core_b = 1'b1;
        end 
        if (cache_wr_en_i) begin
            if (cache_addr_i == dec_read_addr_a_i) begin
                if (cache_hit_i) begin
                    bypass_a_en_o = 1'b1;
                    bypass_data_a_o = cache_data_i;
                end
                else stall_core_a = 1'b1;
            end
            if (cache_addr_i == dec_read_addr_b_i) begin
                if (cache_hit_i) begin
                    bypass_b_en_o = 1'b1;
                    bypass_data_b_o = cache_data_i;
                end
                else stall_core_b = 1'b1;
	    end
        end
        if (write_en_i) begin
            if (write_addr_i == dec_read_addr_a_i) begin 
                bypass_a_en_o = 1'b1;
                bypass_data_a_o = write_data_i;
            end
            if (write_addr_i == dec_read_addr_b_i) begin 
                bypass_b_en_o = 1'b1;
                bypass_data_b_o = write_data_i;
            end
        end
    end
end

endmodule
