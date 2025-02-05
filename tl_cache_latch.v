module tl_cache_latch(
input 		clk_i,
input 		rsn_i,
input		kill_i, 
input 		stall_core_i,
input	[19:0] 	tl_addr_i,
input       	tl_rqst_byte_i,
input  	[1:0] 	tl_hit_way_i,
input  	[1:0] 	tl_lru_way_i,
input  		tl_miss_i,
input       	tl_buffer_hit_i,
input  	[31:0] 	tl_buffer_data_i,
input       	tl_int_write_enable_i,
input  	[4:0] 	tl_write_addr_i,
input		tl_cache_enable_i,
input	[31:0]	tl_v_cache_addr_i,
input		tl_misaligned_ld_i,
input		tl_misaligned_st_i,
input		tl_load_fault_exc_i,
input		tl_store_fault_exc_i,
input	[31:0]	tl_exc_bits_i,
input	[31:0]	tl_instruction_i,
input  	[31:0] 	tl_pc_i,
output 	[19:0] 	c_addr_o,
output     	c_rqst_byte_o,
output 	[1:0]   c_hit_way_o,
output 	[1:0]   c_lru_way_o,
output     	c_miss_o,
output      	c_buffer_hit_o,
output 	[31:0] 	c_buffer_data_o,
output      	c_int_write_enable_o,
output 	[4:0] 	c_write_addr_o,
output		c_cache_enable_o,
output	[31:0]	c_v_cache_addr_o,
output	[31:0]	c_exc_bits_o,
output	[31:0]	c_instruction_o,
output 	[31:0] 	c_pc_o
);

reg   [19:0]  	addr;
reg       	rqst_byte;
reg   [1:0]	hit_way;
reg   [1:0]   	lru_way;
reg      	miss;
reg          	buffer_hit;
reg  [31:0]  	buffer_data;
reg          	int_write_enable;
reg  [31:0]  	write_addr;
reg		c_cache_enable;
reg  [31:0]	c_v_cache_addr;
reg  [31:0]	c_exc_bits;
reg  [31:0]  	c_instruction;
reg  [31:0]  	pc;

assign c_addr_o = addr;
assign c_rqst_byte_o = rqst_byte;
assign c_hit_way_o = hit_way;
assign c_lru_way_o = lru_way;
assign c_miss_o = miss;
assign c_buffer_hit_o = buffer_hit;
assign c_buffer_data_o = buffer_data;
assign c_int_write_enable_o = int_write_enable;
assign c_write_addr_o = write_addr;
assign c_cache_enable_o = c_cache_enable;
assign c_v_cache_addr_o = c_v_cache_addr;
assign c_exc_bits_o = c_exc_bits;
assign c_instruction_o = c_instruction;
assign c_pc_o = pc;

always @(posedge clk_i)
begin
    if(!rsn_i || kill_i) begin
        addr        = 20'b0;
        rqst_byte   =  1'b0;
        hit_way     =  2'b0;
        lru_way     =  2'b0;
        miss        =  1'b0;
        buffer_hit  =  1'b0;
        buffer_data = 32'b0;
        int_write_enable = 1'b0;
        write_addr  = 32'b0;
        c_cache_enable = 1'b0;
        c_v_cache_addr = 32'b0;
        c_exc_bits = 32'b0;
        c_instruction = 32'b0;
        pc          = 32'b0;
    end
    if(!stall_core_i)begin
        addr = tl_addr_i;
        rqst_byte = tl_rqst_byte_i;
        hit_way = tl_hit_way_i;
        lru_way = tl_lru_way_i;
        miss = tl_miss_i;
        buffer_hit  =  tl_buffer_hit_i;
        buffer_data = tl_buffer_data_i;
        int_write_enable = tl_int_write_enable_i;
        write_addr  = tl_write_addr_i;
        c_cache_enable = tl_cache_enable_i;
        c_v_cache_addr = tl_v_cache_addr_i;
        c_instruction = tl_instruction_i;
        pc          = tl_pc_i;
        c_exc_bits[4] = tl_misaligned_ld_i;
        c_exc_bits[6] = tl_misaligned_st_i;
        c_exc_bits[13] = tl_load_fault_exc_i;
        c_exc_bits[15] = tl_store_fault_exc_i;
    end
end


endmodule
