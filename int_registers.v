// Register file

module int_registers(
input		clk_i,
input		rsn_i,
input	[31:0]	write_data_i,
input		write_exc_en_i,
input 	[31:0] 	write_data_mepc_i,	
input 	[31:0] 	write_data_mtval_i,
input 	[31:0] 	write_data_mcause_i,
input 	[31:0] 	write_data_mpriv_i,
input 		write_mpriv_en_i,
input	[4:0]	read_addr_a_i,	
input	[4:0]	read_addr_b_i,
input	[4:0] 	dec_write_addr_i,
input	[4:0]	write_addr_i,
input		write_enable_i,
output	[31:0]	read_data_a_o,
output	[31:0]	read_data_b_o,
output	[31:0]	read_data_mepc_o,
output	[31:0]	read_data_mtval_o,
output	[31:0]	read_data_mcause_o,
output	[31:0]	read_data_mpriv_o,
output 	[31:0] 	dec_dest_reg_value_o);

reg [31:0] registers [31:0];

reg [31:0] mepc; // rm1
reg [31:0] mtval; // rm2
reg [31:0] mcause; // rm3
reg [31:0] mpriv; // rm4
	
/*
0x341MRW mepc Machine exception program counter.
0x343MRW mtval Machine bad address or instruction.
0x342MRW mcause Machine trap cause.
*/

// Read data
assign read_data_a_o = registers[read_addr_a_i];
assign read_data_b_o = registers[read_addr_b_i];
assign read_data_mepc_o = mepc;
assign read_data_mtval_o = mtval;
assign read_data_mcause_o = mcause;
assign read_data_mpriv_o = mpriv;
assign dec_dest_reg_value_o = registers[dec_write_addr_i];

integer i;
// Write
always @(posedge(clk_i))
begin
	if (!rsn_i) for (i=0; i<32; i=i+1) registers[i]=0;	
	else begin
		if (write_enable_i && write_addr_i > 5'b00000) registers[write_addr_i] = write_data_i;
	end
end
	
// Write special
always @(posedge(clk_i))
begin
	if (!rsn_i) begin
		mepc = 32'b0;
		mtval = 32'b0;
		mcause = 32'b0;
		mpriv = 32'b1;
	end
	else begin
		if (write_exc_en_i) begin
			mepc = (write_data_mcause_i[12] || write_data_mcause_i[13] || write_data_mcause_i[15]) ? write_data_mepc_i : (write_data_mepc_i + 32'h4);
			mtval = write_data_mtval_i;
			mcause = write_data_mcause_i;
		end
		if (write_mpriv_en_i) mpriv = write_data_mpriv_i;
	end
end
	
endmodule	
