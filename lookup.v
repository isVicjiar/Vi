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

module lookup(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  read_addr_i,
    input   [19:0]  write_addr_i,
    input       read_rqst_i,
    input       write_enable_i,
    input       rqst_byte_i,
    input       mem_data_ready_i,
    input   [19:0]  mem_addr_i,
    input       kill_i,

    output  [1:0] read_hit_way_o,
    output  [1:0] write_hit_way_o,
    output  [1:0] lru_way_o,
    output      rqst_to_mem_o,
    output  [19:0]  addr_to_mem_o,
    output      unalign_o,
    output      write_hit_o,
    output      read_miss_o
);

reg state;
localparam IDLE_STATE = 0;
localparam WAIT_STATE = 1;

reg [15:0]  tags_array [3:0];
reg [3:0]   read_hit_array;
reg [3:0]   write_hit_array;
reg [3:0]   valid_bit;

reg read_hit;
reg write_hit;
reg rqst_to_mem;

reg [1:0] set_hit;
reg [1:0] set_write;
reg [1:0] set_lru;
reg [3:0] lru_matrix [3:0];


integer i;

always @(*)
begin
    read_hit_array[0] = valid_bit[0] & (read_addr_i[19:4] == tags_array[0]);
    read_hit_array[1] = valid_bit[1] & (read_addr_i[19:4] == tags_array[1]);
    read_hit_array[2] = valid_bit[2] & (read_addr_i[19:4] == tags_array[2]);
    read_hit_array[3] = valid_bit[3] & (read_addr_i[19:4] == tags_array[3]);

    set_hit = read_hit_array[0] ? 0 : 
             (read_hit_array[1] ? 1 :
             (read_hit_array[2] ? 2 : 
                             3));

    case (state)
        IDLE_STATE: begin
            rqst_to_mem = 0;
            if(read_rqst_i) begin
                read_hit = (read_hit_array == 0) ? 0 : 1;
                if (read_hit) begin 
                    for (i = 0; i < 4; i = i + 1) begin
                        lru_matrix[set_hit][i] = 0;
                        lru_matrix[i][set_hit] = 1;
                    end
                end else begin
                    rqst_to_mem = 1;
                    state = WAIT_STATE;
                end
            end
        end
        WAIT_STATE: begin
            read_hit  = 0;
            for (i=0; i<4; i = i +1) begin
                if(lru_matrix[i][0] & lru_matrix[i][1] & lru_matrix[i][2] & lru_matrix[i][3]) begin
                    set_lru = i;
                end
            end
            if(kill_i) begin
                state = IDLE_STATE;
            end else if(mem_data_ready_i & mem_addr_i[19:4] == read_addr_i[19:4]) begin
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

always@(posedge clk_i) begin
    for(i = 0; i<4; i = i + 1) begin
        write_hit_array[i] = valid_bit[i] & (write_addr_i[19:4] == tags_array[i]);
    end
    set_write = write_hit_array[0] ? 0 : 
               (write_hit_array[1] ? 1 :
               (write_hit_array[2] ? 2 : 
                                     3));

    if(write_enable_i && (write_hit_array !=0)) begin
        write_hit = (write_hit_array == 0) ? 0 : 1;
        if (write_hit) begin 
            for (i = 0; i < 4; i = i + 1) begin
                lru_matrix[set_write][i] = 0;
                lru_matrix[i][set_write] = 1;
            end
        end
    end
    else begin
        write_hit = 0;
    end
end

assign unalign_o = rqst_byte_i ? 0 :
                   &read_addr_i[1:0] ? 1 : 0;

assign write_hit_o = write_hit;
assign read_miss_o = ~read_hit & read_rqst_i;
assign read_hit_way_o = set_hit;
assign write_hit_way_o = set_write;
assign lru_way_o = set_lru;
assign rqst_to_mem_o = rqst_to_mem;
assign addr_to_mem_o = read_addr_i;


always @(negedge rsn_i)
begin
    state = IDLE_STATE;
    valid_bit = 0;
    rqst_to_mem = 0;
    read_hit = 0;
    write_hit = 0;
    lru_matrix[0] = 4'b1111;
    lru_matrix[1] = 4'b1111;
    lru_matrix[2] = 4'b1111;
    lru_matrix[3] = 4'b1111;
end
endmodule
