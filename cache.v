// Instruction cache

//LRU
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
//4-way associative
//4 lines 128bits

module cache(
    input       clk_i,
    input       rsn_i,
    input   [19:0]  addr_i,
    input       read_rqst_i,
    input       write_rqst_i,
    input       rqst_byte_i,
    input       mem_data_ready_i,
    input   [127:0] mem_data_i,
    input   [19:0]  mem_addr_i,

    output  [31:0]  data_o,
    output      rqst_to_mem_o,
    output  [19:0]  addr_to_mem_o,
    output      unalign_o,
    output      hit_o,
    output      miss_o
);

reg [1:0] state;
reg [127:0] data_array [3:0];
reg [15:0]  tags_array [3:0];
reg [3:0]   valid_bit;

reg miss;
reg rqst_to_mem;
reg hit;

reg [1:0] set_hit;
reg [127:0] cache_line;
reg [3:0] lru_matrix [3:0];
reg [1:0] set_lru;

localparam [1:0] IDLE_STATE = 0;
localparam [1:0] READ_STATE = 1;
localparam [1:0] MEM_STATE  = 2;
localparam [1:0] UPDT_STATE = 3;

wire [3:0] hit_array;
wire [3:0] addr_byte;

assign hit_array[0] = valid_bit[0] & (addr_i[19:4] == tags_array[0]);
assign hit_array[1] = valid_bit[1] & (addr_i[19:4] == tags_array[1]);
assign hit_array[2] = valid_bit[2] & (addr_i[19:4] == tags_array[2]);
assign hit_array[3] = valid_bit[3] & (addr_i[19:4] == tags_array[3]);

assign addr_byte = addr_i[3:0];
assign addr_word = addr_i[3:2];


always @(posedge clk_i)
begin
    case (state) begin
        IDLE_STATE: begin
            if (read_rqst_i) begin
                state = READ_STATE;
            end
        end
        READ_STATE: begin
            if (miss) begin
                state = MEM_STATE;
            end else begin
                if (read_rqst_i) begin
                    state = READ_STATE;
                end else begin
                    state = IDLE_STATE;
                end
            end
            MEM_STATE: begin
                if (mem_data_ready_i) begin
                    state = UPDT_STATE;
                end
            end
            UPDT_STATE: begin
                if (read_rqst_i) begin
                    state = READ_STATE;
                end else begin
                    state = IDLE_STATE;
                end
            end
        endcase
    end

    always @(state) 
    begin
        case (state) begin
            IDLE_STATE: begin
                hit  = 0;
                miss = 0;
                if(write_rqst_i) begin
                    for(i = 0; i < 4; i = i + 1) begin
                        if(addr_i[19:0] == tags_array[i]) begin
                            valid_bit[i] = 0;
                            //After invalidating set as least recently used
                            for (j = 0; j < 4; j = j + 1) begin
                                lru_matrix[j][i] = 0;
                                lru_matrix[i][j] = 1;
                            end
                        end
                    end
                end
            end
            READ_STATE: begin
                hit  = (hit_array > 0);
                miss = !hit;

                if (hit) begin 
                    set_hit = hit_array[0] ? 0 : 
                             (hit_array[1] ? 1 :
                             (hit_array[2] ? 2 : 
                                             3));

                    cache_line = data_array[set_hit];

                    for (i = 0; i < 4; i = i + 1) begin
                        lru_matrix[set_hit][i] = 0;
                        lru_matrix[i][set_hit] = 1;
                    end
                end else begin
                    rqst_to_mem = 1;
                end
            end
            MEM_STATE: begin
                hit  = 0;
                miss = 1;
                rqst_to_mem = 0;
            end
            UPDT_STATE: begin
                if(mem_addr_i[19:4] == addr_i[19:4]) begin
                    hit  = 1;
                    miss = 0;
                    cache_line = mem_data_i;
                end else begin
                    hit  = 0;
                    miss = 1;
                end
                for (i=0; i<4; i = i +1) begin
                    if(lru_matrix[i][0] & lru_matrix[i][1] & lru_matrix[i][2] & lru_matrix[i][3]) begin
                        set_lru = i;
                    end
                end
                data_array[set_lru] = mem_data_i;
                tags_array[set_lru] = mem_addr_i[19:4];
                valid_bit[set_lru]  = 1;
                for (i=0; i<4; i = i +1) begin
                    lru_matrix[set_lru][i] = 0;
                    lru_matrix[i][set_lru] = 1;
                end
            end
        endcase
    end
    assign data_o = rqst_byte_i ? {24'b0, cache_line[7+addr_byte*8:8*addr_byte]}   :
                                  cache_line[31+addr_word*32:32*addr_word];
    assign unalign_o = rqst_byte_i ? 0 :
                       addr_i[1:0] ? 1 : 0;

    assign hit_o = hit;
    assign miss_o = miss;
    assign rqst_to_mem_o = rqst_to_mem;
    assign addr_to_mem_o = addr_i;


    always @(negedge rsn_i)
    begin
        state = IDLE_STATE;
        for (i=0; i<4; i = i +1) begin
            valid_bit[i] <= 0;
            for (j=0; j<4; j = j +1) begin
                lru_matrix[i][j] <= 1;
            end
        end
    end
    endmodule
