// Instruction cache
// Direct mapping
//4 lines 128bits

module cache(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  addr_i,
    input       read_rqst_i,
    input       mem_data_ready_i,
    input   [127:0] mem_data_i,
    input   [19:0]  mem_addr_i,

    output  [31:0]  data_o,
    output      rqst_to_mem_o,
    output  [19:0]  addr_to_mem_o,
    output      hit_o,
    output      miss_o
);

reg [127:0] data_array [3:0];
reg [15:0]  tags_array [3:0];
reg [3:0]   valid_bit;

reg rqst_to_mem;

wire [127:0] cache_line;


wire [1:0]  addr_word;
wire [1:0]  addr_idx;
wire [14:0] addr_tag;
assign addr_word = addr_i[3:2];
assign addr_tag = addr_i[19:6]; 
assign addr_idx = addr_i[5:4];

assign cache_line = data_array[addr_idx];
assign hit_o = valid_bit[addr_idx] && tags_array[addr_idx] == addr_tag;
assign data_o = cache_line[addr_word*32 +: 32];

always @(posedge clk_i)
begin
    if(mem_data_ready_i && mem_addr_i[19:6] == addr_tag) begin
        data_array[addr_idx] = mem_data_i;
        tags_array[addr_idx] = mem_addr_i[19:6];
        valid_bit[addr_idx] = 1;
    end
end


always @(negedge rsn_i)
begin
    valid_bit = 0;
end
endmodule
