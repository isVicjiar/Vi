module store_buffer(
    input           clk_i,
    input           rsn_i,
    input   [19:0]  addr_i,
    input   [31:0]  data_i,
    input   [31:0]  write_pc_i,
    input           write_enable_i,
    input           write_byte_i,
    input           kill_i,
    input   [31:0]  kill_pc_i,
    input           read_i,
    input   [19:0]  read_addr_i,
    input           read_byte_i,
    input           do_write_i,

    output          full_o,
    output          data_in_buffer_o,
    output  [31:0]  data_read_o,
    output  [19:0]  addr_to_mem_o,
    output  [31:0]  data_to_mem_o,
    output          byte_to_mem_o,
    output          mem_write_o
);

reg [31:0] buffer_data [7:0];
reg [31:0] buffer_pc   [7:0];
reg [19:0] buffer_addr [7:0];
reg [7:0]  buffer_byte;
reg [3:0]  num_elements;

reg flushing;
reg data_in_buffer;
reg [31:0] data_read;

wire full;
wire empty;

reg [19:0] addr_to_mem;
reg [31:0] data_to_mem;
reg        byte_to_mem;
reg mem_write;

assign empty = num_elements == 0;
assign full = num_elements == 8;
assign full_o = full;
assign addr_to_mem_o = addr_to_mem;
assign data_to_mem_o = data_to_mem;
assign byte_to_mem_o = byte_to_mem;
assign mem_write_o = mem_write;
assign data_in_buffer_o = data_in_buffer;
assign data_read_o = data_read;

integer i,j,k,l;
always@(posedge clk_i) begin
    if(write_enable_i && !full) begin //write in buffer
        buffer_data[num_elements] = data_i;
        buffer_addr[num_elements] = addr_i;
        buffer_pc[num_elements] = write_pc_i;
        buffer_byte[num_elements] = write_byte_i;
        num_elements = num_elements+1;
    end
end

always@(posedge clk_i) begin
    data_in_buffer = 0;
    if(read_i) begin
        for(i = 0; i<num_elements; i = i+1) begin
            if(buffer_addr[i] == read_addr_i) begin //if the read is in buffer
                if(read_byte_i || read_byte_i == buffer_byte[i]) begin
                    data_in_buffer = 1;
                    data_read = buffer_data[i];
                end
            end
        end
    end
end

always@(posedge clk_i) begin
    mem_write = 0;
    if(do_write_i && !empty) begin //store can proceed
        mem_write = 1;
        addr_to_mem = buffer_addr[0];
        data_to_mem = buffer_data[0];
        byte_to_mem = buffer_byte[0];
        num_elements = num_elements - 1;
        for(j = 0; j<num_elements; j = j+1) begin
            buffer_data[j] = buffer_data[j+1]; 
            buffer_addr[j] = buffer_addr[j+1]; 
            buffer_byte[j] = buffer_byte[j+1];
            buffer_pc[j]   = buffer_pc[j+1]; 
        end
    end
end

always@(posedge clk_i) begin
    if (kill_i) begin
        for (k = 0; k<num_elements; k = k+1) begin
            if(buffer_pc[k] == kill_pc_i) begin
                num_elements = num_elements-1;
                for(l = k; l<num_elements; l = l+1) begin
                    buffer_data[l] = buffer_data[l+1]; 
                    buffer_addr[l] = buffer_addr[l+1]; 
                    buffer_byte[l] = buffer_byte[l+1];
                    buffer_pc[l]   = buffer_pc[l+1]; 
                end
            end
        end
    end
end

always@(negedge rsn_i) begin
    num_elements = 0;
end





endmodule
