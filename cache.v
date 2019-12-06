//cache

module cache(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  addr_i,
    input   [31:0]  data_i,
    input       rqst_byte_i,
    input       rqst_write_i,
    input       mem_data_ready_i,
    input   [127:0] mem_data_i,
    input   [1:0]   hit_way_i,
    input   [1:0]   lru_way_i,
    input       hit_i,
    input       miss_i,

    output  [31:0]  data_o
);

reg state;
localparam IDLE_STATE = 0;
localparam WAIT_STATE = 1;

reg [127:0] data_array [3:0];

wire [127:0] cache_line;
wire [3:0] addr_byte;
wire [1:0] addr_word;

assign addr_byte = addr_i[3:0];
assign addr_word = addr_i[3:2];

integer i , j;

always @(posedge clk_i)
begin
    case (state)
        IDLE_STATE: begin
            if (hit_i && rqst_write_i) begin
                if (rqst_byte_i) begin
                    data_array[hit_way_i][addr_byte*8 +: 8] = data_i[7:0];
                end else begin
                    data_array[hit_way_i][addr_word*32 +: 32] = data_i;
                end
            end else if (miss_i) begin
                state = WAIT_STATE;
            end
        end
        WAIT_STATE: begin
            data_array[lru_way_i] = mem_data_i;
        end
    endcase
end
assign cache_line = data_array[hit_way_i];
assign data_o = rqst_byte_i ? {24'b0, cache_line[addr_byte*8 +: 8]} :
                              cache_line[addr_word*32 +: 32];


always @(negedge rsn_i)
begin
    state = IDLE_STATE;
end
endmodule
