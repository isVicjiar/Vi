// Main module of the project

module vi_core (
input		clk_i,
input		rsn_i);

// TEMPORARY WIRES
wire [31:0] int_alu_out;

// Stage instructions
wire [31:0] fetch_instruction;
wire [31:0] dec_instruction;
wire [31:0] exe_instruction;
wire [31:0] wb_instruction;

// Decode - Latch = DL
wire [4:0] dl_read_addr_a;
wire [4:0] dl_read_addr_b;
wire [4:0] dl_write_addr;
wire	   dl_int_write_enable;

// Latch - Exe = LE
wire [31:0] le_int_data_a;
wire [31:0] le_int_data_b;
wire [4:0]  le_write_addr;
wire 	    le_int_write_enable;

// Exe - Latch = EL
wire [4:0]  el_write_addr;
wire	    el_int_write_enable;
wire [31:0] el_int_write_data;
	
// Latch - Write back = LW
wire [4:0]  lw_write_addr;
wire	    lw_int_write_enable;
wire [63:0] lw_int_write_data;


fetch fetch(
	.clock		(clock),
	.reset		(reset),

	.instruction	(fetch_instruction)
);

fetch_dec_latch fetch_dec_latch(
	.clock		(clock),
	.reset		(reset),
	.fetch_instruction	(fetch_instruction),

	.dec_instruction	(dec_instruction)
);

decoder decoder(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.instruction_i	(dec_instruction),

	.read_addr_a_o	(dec_read_addr_a),
	.read_addr_b_o	(dec_read_addr_b),
	.write_addr_o	(dl_write_addr),
	.int_write_enable_o	(dl_int_write_enable)
);

int_registers int_registers(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.write_data_i	(lw_int_write_data),
	.read_addr_a_i	(dec_read_addr_a),
	.read_addr_b_i	(dec_read_addr_b),
	.write_addr_i	(lw_write_addr),
	.write_enable_i	(lw_int_write_enable),

	.read_data_a_o	(dl_read_data_a),
	.read_data_b_o	(dl_read_data_b)
);
	
dec_exe_latch dec_exe_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.dec_read_data_a_i	(dl_read_data_a),
	.dec_read_addr_b_i	(dl_read_data_b),
	.dec_write_addr_i	(dl_write_addr),
	.dec_int_write_enable_i	(dl_int_write_enable),
	.dec_instruction_i	(dec_instruction),

	.exe_read_addr_a_o	(le_read_addr_a),
	.exe_read_addr_b_o	(le_read_addr_b),
	.exe_write_addr_o	(le_write_addr),
	.exe_int_write_enable_o	(le_int_write_enable),
	.exe_instruction_o	(exe_instruction)
);

int_alu int_alu(
	.clock		(clock),
	.reset		(reset),
	.instruction	(exe_instruction),
	.data_a		(la_int_data_a),
	.data_b		(la_int_data_b),

	.data_out	(int_alu_out)
);

exe_wb_latch exe_wb_latch(
	.clock		(clock),
	.reset		(reset),
	.exe_int_write_data	(exe_int_write_data),
	.exe_write_addr		(exe_write_addr),
	.exe_int_write_enable	(exe_int_write_enable),
	.exe_instruction	(exe_instruction),

	.wb_int_write_data	(lw_int_write_data),
	.wb_write_addr		(lw_write_addr),
	.wb_int_write_enable	(lw_int_write_enable),
	.wb_instruction		(wb_instruction)
);

endmodule
