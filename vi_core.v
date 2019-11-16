// Main module of the project

module vi_core (
input		clock,
input		reset);

// TEMPORARY WIRES
wire [63:0] int_alu_out;

// Stage instructions
wire [31:0] fetch_instruction;
wire [31:0] dec_instruction;
wire [31:0] reg_instruction;
wire [31:0] exe_instruction;
wire [31:0] wb_instruction;

// Decode - Latch = DL
wire [4:0] dl_read_addr_a;
wire [4:0] dl_read_addr_b;
wire [4:0] dl_write_addr;
wire	   dl_int_write_enable;

// Latch - Reg = LR
wire [4:0] lr_read_addr_a;
wire [4:0] lr_read_addr_b;
wire [4:0] lr_write_addr;
wire	   lr_int_write_enable;

// Reg - Latch = RL
wire [63:0] rl_int_data_a;
wire [63:0] rl_int_data_b;
wire [4:0]  rl_write_addr;
wire	    rl_int_write_enable;

// Latch - Alu = LA
wire [63:0] la_int_data_a;
wire [63:0] la_int_data_b;
wire [4:0]  la_write_addr;
wire 	    la_int_write_enable;

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
	.clock		(clock),
	.reset		(reset),
	.instruction	(dec_instruction),

	.read_addr_a	(dl_read_addr_a),
	.read_addr_b	(dl_read_addr_b),
	.write_addr	(dl_write_addr),
	.int_write_enable	(dl_int_write_enable)
);

dec_reg_latch dec_reg_latch(
	.clock		(clock),
	.reset		(reset),
	.dec_read_addr_a	(dl_read_addr_a),
	.dec_read_addr_b	(dl_read_addr_b),
	.dec_write_addr		(dl_write_addr),
	.dec_int_write_enable	(dl_int_write_enable),
	.dec_instruction	(dec_instruction),

	.reg_read_addr_a	(lr_read_addr_a),
	.reg_read_addr_b	(lr_read_addr_b),
	.reg_write_addr		(lr_write_addr),
	.reg_int_write_enable	(lr_int_write_enable),
	.reg_instruction	(reg_instruction)
);

int_registers int_registers(
	.clock		(clock),
	.reset		(reset),
	.write_data	(lw_int_write_data),
	.read_addr_a	(lr_read_addr_a),
	.read_addr_b	(lr_read_addr_b),
	.write_addr	(lw_write_addr),
	.write_enable	(lw_int_write_enable),

	.read_data_a	(rl_int_data_a),
	.read_data_b	(rl_int_data_b)
);

reg_exe_latch reg_exe_latch(
	.clock		(clock),
	.reset		(reset),
	.reg_int_data_a	(rl_int_data_a),
	.reg_int_data_b	(rl_int_data_b),
	.reg_int_write_enable	(rl_int_write_enable),
	.reg_write_addr		(rl_write_addr),
	.reg_instruction	(reg_instruction),

	.alu_int_data_a	(la_int_data_a),
	.alu_int_data_b	(la_int_data_b),
	.alu_int_write_enable	(la_int_write_enable),
	.exe_write_addr		(la_write_addr),
	.exe_instruction 	(exe_instruction)
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
