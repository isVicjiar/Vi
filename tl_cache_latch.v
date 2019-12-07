module tl_cache_latch(
    input 		clk_i,
    input 		rsn_i,
    input		kill_i, 
    input 		stall_core_i,
    input  [19:0]  tl_addr_i,
    input  [31:0]  tl_data_i,
    input       tl_rqst_byte_i,
    input       tl_rqst_write_i,
    input  [1:0] tl_hit_way_i,
    input  [1:0] tl_lru_way_i,
    input     tl_hit_i,
    input     tl_miss_i,

    output   [19:0]  c_addr_o,
    output   [31:0]  c_data_o,
    output       c_rqst_byte_o,
    output       c_rqst_write_o,
    output   [1:0]   c_hit_way_o,
    output   [1:0]   c_lru_way_o,
    output      c_hit_o,
    output      c_miss_o
);

reg   [19:0]  addr;
reg   [31:0]  data;
reg       rqst_byte;
reg       rqst_write;
reg   [1:0]   hit_way;
reg   [1:0]   lru_way;
reg      hit;
reg      miss;

assign c_addr_o = addr;
assign c_data_o = data;
assign c_rqst_byte_o = rqst_byte;
assign c_rqst_write_o = rqst_write;
assign c_hit_way_o = hit_way;
assign c_lru_way_o = lru_way;
assign c_hit_o = hit;
assign c_miss_o = miss;

always @(posedge clk_i)
begin
    if(!rsn_i || kill_i) begin
        addr        <= 20'b0;
        data        <= 32'b0;
        rqst_byte   <=  1'b0;
        rqst_write  <=  1'b0;
        hit_way     <=  2'b0;
        lru_way     <=  2'b0;
        hit         <=  1'b0;
        miss        <=  1'b0;
    end
    if(!stall_core_i)begin
        addr <= tl_addr_i;
        data <= tl_data_i;
        rqst_byte <= tl_rqst_byte_i;
        rqst_write <= tl_rqst_write_i;
        hit_way <= tl_hit_way_i;
        lru_way <= tl_lru_way_i;
        hit <= tl_hit_i;
        miss <= tl_miss_i;
    end
end


endmodule
