//tlb
//2 entries
module tlb(
    input       clk_i,
    input       rsn_i,
    input       supervisor_i,
    input   [31:0]  v_addr_i,
    input       write_enable_i,
    input   [19:0]  new_physical_i,
    input   [31:0]  new_virutal_i,
    input       new_read_only_i,

    output  [19:0]  p_addr_o,
    output      tlb_hit_o,
    output      tlb_protected_o
);

reg [19:0] virtual_tags [1:0];
reg [7:0] physical_tags [1:0];
reg [1:0] valid_bit;
reg [1:0] read_only_array;

wire [11:0] offset;
assign offset = v_addr_i[11:0];

wire [19:0] addr_tag;
assign addr_tag = v_addr_i[19:0];

reg [7:0] page_num;
reg hit;
reg read_only;

reg sub_bit;
reg hit_bit;
reg lru;


always @(*) begin
    if(supervisor_i) begin
        page_num = addr_tag[7:0];
    end else begin
        if(valid_bit[0] & (virtual_tags[0] == addr_tag)) begin
            hit = 1;
            page_num = physical_tags[0];
            read_only = read_only_array[0];
            lru = 1;
        end
        else if(valid_bit[1] & (virtual_tags[1] == addr_tag)) begin
            hit = 1;
            page_num = physical_tags[1];
            read_only = read_only_array[1];
            lru = 0;
        end
        else begin
            hit = 0;
        end
    end
end

always @(posedge clk_i) begin
    if(write_enable_i) begin
        sub_bit = !valid_bit[0] ? 0 : 
                  !valid_bit[1] ? 1 : lru;
        physical_tags[sub_bit] = new_physical_i[19:12];
        virtual_tags[sub_bit] = new_virutal_i[31:12];
        read_only_array[sub_bit] = new_read_only_i;
        valid_bit[sub_bit] = 1;
        lru = ~sub_bit;
    end
end


assign p_addr_o = {page_num,offset};
assign tlb_hit_o = hit | supervisor_i;
assign tlb_protected_o = read_only;
endmodule
