module cache_write_latch(
    input clk_i,
    input rsn_i,
    input stall_core_i,
    input kill_i,
    input [31:0] c_data_i,
    input c_reg_write_enable_i,
    input [31:0] c_write_addr_i,
    output [31:0] w_data_o,
    output w_reg_write_enable_o,
    output [31:0] w_write_addr_o
);

reg [31:0] data;
reg reg_write_enable;
reg [31:0] write_addr;

assign w_data_o = data;
assign w_reg_write_enable_o = reg_write_enable;
assign w_write_addr_o = write_addr;

always @(posedge clk_i)
begin
    if(!rsn_i || kill_i) begin
        data <= 32'b0;
        reg_write_enable <= 1'b0;
        write_addr <= 32'b0;
    end

    if(!stall_core_i) begin
        data <= c_data_i;
        reg_write_enable <= c_reg_write_enable_i;
        write_addr <= c_write_addr_i;
    end
end
endmodule
