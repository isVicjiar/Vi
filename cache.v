//cache

module cache(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  read_addr_i,
    input       rqst_byte_i,
    input       write_enable_i,
    input   [31:0]  write_data_i,
    input   [19:0]  write_addr_i,
    input       mem_data_ready_i,
    input   [127:0] mem_data_i,
    input   [1:0]   read_hit_way_i,
    input   [1:0]   write_hit_way_i,
    input   [1:0]   lru_way_i,
    input       write_hit_i,
    input       read_miss_i,

    output  [31:0]  data_o
);

reg state;
localparam IDLE_STATE = 0;
localparam WAIT_STATE = 1;

reg [127:0] data_array [3:0];

wire [127:0] cache_line;
wire [3:0] read_addr_byte;
wire [1:0] read_addr_word;

wire [3:0] write_addr_byte;
wire [1:0] write_addr_word;

assign read_addr_byte = read_addr_i[3:0];
assign read_addr_word = read_addr_i[3:2];

assign write_addr_byte = write_addr_i[3:0];
assign write_addr_word = write_addr_i[3:2];

integer i , j;

always @(posedge clk_i)
begin
    case (state)
        IDLE_STATE: begin
            if (read_miss_i) begin
                state = WAIT_STATE;
            end
        end
        WAIT_STATE: begin
            if(mem_data_ready_i) begin
                data_array[lru_way_i] = mem_data_i;
                state = IDLE_STATE;
            end
        end
    endcase
end
always @(negedge clk_i)
begin
    if(write_hit_i && write_enable_i) begin
        if (rqst_byte_i) begin
            data_array[write_hit_way_i][write_addr_byte*8 +: 8] = write_data_i[7:0];
        end else begin
            data_array[write_hit_way_i][write_addr_word*32 +: 32] = write_data_i;
        end
    end
end

assign cache_line = data_array[read_hit_way_i];
assign data_o = rqst_byte_i ? {24'b0, cache_line[read_addr_byte*8 +: 8]} :
                              cache_line[read_addr_word*32 +: 32];


always @(negedge rsn_i)
begin
    state = IDLE_STATE;
end
endmodule
