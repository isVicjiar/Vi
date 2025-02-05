// Instruction cache
// Direct mapping
//4 lines 128bits

module instruction_cache(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  addr_i,
    input       mem_data_ready_i,
    input   [127:0] mem_data_i,
    input   [19:0]  mem_addr_i,
    input       cancel_wait_i,

    output  [31:0]  data_o,
    output      rqst_to_mem_o,
    output  [19:0]  addr_to_mem_o,
    output      miss_o,
    output	fetch_stall_o
);

reg [127:0] data_array [3:0];
reg [15:0]  tags_array [3:0];
reg [3:0]   valid_bit;

reg fetch_stall;
reg rqst_to_mem;

wire [127:0] cache_line;

reg state;
localparam IDLE_STATE = 0;
localparam WAIT_STATE = 1;

wire [1:0]  addr_word;
wire [1:0]  addr_idx;
wire [14:0] addr_tag;
assign addr_word = addr_i[3:2];
assign addr_tag = addr_i[19:6]; 
assign addr_idx = addr_i[5:4];

assign addr_to_mem_o = addr_i;
assign rqst_to_mem_o = rqst_to_mem;

assign cache_line = data_array[addr_idx];
assign miss_o = ~(valid_bit[addr_idx] && tags_array[addr_idx] == addr_tag);
assign data_o = cache_line[addr_word*32 +: 32];
assign fetch_stall_o = ~(valid_bit[addr_idx] && tags_array[addr_idx] == addr_tag);

always @(posedge clk_i)
begin
    case(state)
        IDLE_STATE: begin
            rqst_to_mem = 0;
            if ((tags_array[addr_idx] != addr_tag) || ~valid_bit[addr_idx]) begin
                rqst_to_mem = 1'b1;
                state = WAIT_STATE;
                fetch_stall = 1'b1;
            end
        end
        WAIT_STATE: begin
            if(mem_data_ready_i && mem_addr_i[19:6] == addr_tag) begin
                data_array[addr_idx] = mem_data_i;
                tags_array[addr_idx] = mem_addr_i[19:6];
                valid_bit[addr_idx] = 1;
                state = IDLE_STATE;
                fetch_stall = 1'b0;
            end
        end
    endcase
end


always @(posedge rsn_i)
begin
    valid_bit = 0;
    state = IDLE_STATE;
    rqst_to_mem = 0;
    fetch_stall = 1'b1;
end
endmodule
