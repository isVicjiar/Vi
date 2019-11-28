//LRU is like a matrix where x>y meaning entry x is older than y
/* |   | 0 | 1 | 2 | 3 |
*  | 0 | 1 |0>1|0>2|0>3|
*  | 1 |0<1| 1 |1>2|1>3|
*  | 2 |0<2|1<2| 1 |2>3|
*  | 3 |0<3|1<3|2<3| 1 |
*  Then the vector LRU is the AND of each row
*  setting the row to 0 and column to 1 is setting as 
*  most recent
*  being LRU[i] == 1 the oldest entry */ 

module cache(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  addr_i,
    input       read_rqst_i,
    input       write_rqst_i,
    input       rqst_byte_i,
    input       mem_data_ready_i,
    input   [19:0]  mem_addr_i,

    output  [1:0] hit_way_o,
    output  [1:0] lru_way_o,
    output      rqst_to_mem_o,
    output  [19:0]  addr_to_mem_o,
    output      unalign_o,
    output      hit_o,
    output      miss_o
);

reg state;
localparam IDLE_STATE = 0;
localparam WAIT_STATE = 1;

reg [127:0] data_array [3:0];
reg [15:0]  tags_array [3:0];
reg [3:0]   hit_array;
reg [3:0]   valid_bit;

reg hit;
reg miss;
reg rqst_to_mem;

reg [1:0] set_hit;
reg [1:0] set_lru;
reg [3:0] lru_matrix [3:0];


integer i;

always @(posedge clk_i)
begin
    for(i = 0; i<4; i = i + 1) begin
        hit_array[i] = valid_bit[i] & (addr_i[19:4] == tags_array[i]);
    end
    set_hit = hit_array[0] ? 0 : 
        (hit_array[1] ? 1 :
        (hit_array[2] ? 2 : 
        3));


    case (state)
        IDLE_STATE: begin
            if(read_rqst_i) begin
                hit = (hit_array == 0) ? 0 : 1;
                miss = ~hit;
                if (hit) begin 
                    for (i = 0; i < 4; i = i + 1) begin
                        lru_matrix[set_hit][i] = 0;
                        lru_matrix[i][set_hit] = 1;
                    end
                end else begin
                    rqst_to_mem = 1;
                    state = WAIT_STATE;
                end
            end else begin 
                if(write_rqst_i && (hit_array !=0)) begin
                    valid_bit[set_hit] = 0;
                    for (i = 0; i < 4; i = i + 1) begin
                        lru_matrix[i][set_hit] = 0;
                        lru_matrix[set_hit][i] = 1;
                    end
                end
                hit = 0;
                miss = 0;
            end
        end
        WAIT_STATE: begin
            hit  = 0;
            miss = 1;
            rqst_to_mem = 0;
            if (!mem_data_ready_i) begin
                for (i=0; i<4; i = i +1) begin
                    if(lru_matrix[i][0] & lru_matrix[i][1] & lru_matrix[i][2] & lru_matrix[i][3]) begin
                        set_lru = i;
                    end
                end
            end else if(mem_addr_i[19:4] == addr_i[19:4]) begin
                state = IDLE_STATE;
                tags_array[set_lru] = mem_addr_i[19:4];
                valid_bit[set_lru]  = 1;
                for (i=0; i<4; i = i +1) begin
                    lru_matrix[set_lru][i] = 0;
                    lru_matrix[i][set_lru] = 1;
                end
            end 

        end
    endcase
end

assign unalign_o = rqst_byte_i ? 0 :
                   addr_i[1:0] ? 1 : 0;

assign hit_o = hit;
assign miss_o = miss;
assign hit_way_o = set_hit;
assign lru_way_o = set_lru;
assign rqst_to_mem_o = rqst_to_mem;
assign addr_to_mem_o = addr_i;


always @(negedge rsn_i)
begin
    state = IDLE_STATE;
    valid_bit = 0;
    lru_matrix[0] = 0;
    lru_matrix[1] = 0;
    lru_matrix[2] = 0;
    lru_matrix[3] = 0;
end
endmodule
