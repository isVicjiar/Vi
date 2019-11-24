// Main module of the project

module vi_core (
input		clk_i,
input		rsn_i);

// Stage instructions-pc
wire [31:0] fetch_instruction;
wire [31:0] fetch_pc;
wire [31:0] dec_instruction;
wire [31:0] dec_pc;
wire [31:0] exe_instruction;
wire [31:0] exe_pc;
wire [31:0] wb_instruction;
wire [31:0] wb_pc;

// Mult delay
wire [31:0] mult1_instruction;
wire [31:0] mult1_pc;
wire [31:0] mult1_int_data_out;
wire [4:0] mult1_write_addr;
wire mult1_int_write_enable;
wire [31:0] mult2_instruction;
wire [31:0] mult2_pc;
wire [31:0] mult2_int_data_out;
wire [4:0] mult2_write_addr;
wire mult2_int_write_enable;
wire [31:0] mult3_instruction;
wire [31:0] mult3_pc;
wire [31:0] mult3_int_data_out;
wire [4:0] mult3_write_addr;
wire mult3_int_write_enable;
wire [31:0] mult4_instruction;
wire [31:0] mult4_pc;
wire [31:0] mult4_int_data_out;
wire [4:0] mult4_write_addr;
wire mult4_int_write_enable;
wire [31:0] mult5_instruction;
wire [31:0] mult5_pc;
wire [31:0] mult5_int_data_out;
wire [4:0] mult5_write_addr;
wire mult5_int_write_enable;

// Decode
wire [4:0] dec_read_addr_a;
wire [4:0] dec_read_addr_b;
wire [31:0] reg_read_data_a;
wire [31:0] reg_read_data_b;
wire bypass_a_en;
wire bypass_b_en;
wire [31:0] bypass_data_a;
wire [31:0] bypass_data_b;
wire dec_stall_core;
	
// Decode - Latch = DL
wire [31:0] dl_read_data_a;
wire [31:0] dl_read_data_b;
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
wire [31:0] el_int_data_out;
	
// Latch - Write back = LW
wire [4:0]  lw_write_addr;
wire	    lw_int_write_enable;
wire [31:0] lw_int_write_data;

assign dl_read_data_a = (bypass_a_en) ? bypass_data_a : reg_read_data_a;
assign dl_read_data_b = (bypass_b_en) ? bypass_data_b : reg_read_data_b;

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

bypass_ctrl bypass_ctrl (
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.read_addr_a_i	(dec_read_addr_a),
	.read_addr_b_i	(dec_read_addr_b),
	.exe_data_i	(el_int_data_out),
	.exe_addr_i	(le_write_addr),
	.exe_wr_en_i	(le_int_write_enable),
	.mult1_data_i	(mult1_int_data_out),
	.mult1_addr_i	(mult1_write_addr),
	.mult1_wr_en_i	(mult1_int_write_enable),
	.mult2_data_i	(mult2_int_data_out),
	.mult2_addr_i	(mult2_write_addr),
	.mult2_wr_en_i	(mult2_int_write_enable),
	.mult3_data_i	(mult3_int_data_out),
	.mult3_addr_i	(mult3_write_addr),
	.mult3_wr_en_i	(mult3_int_write_enable),
	.mult4_data_i	(mult4_int_data_out),
	.mult4_addr_i	(mult4_write_addr),
	.mult4_wr_en_i	(mult4_int_write_enable),
	.mult5_data_i	(mult5_int_data_out),
	.mult5_addr_i	(mult5_write_addr),
	.mult5_wr_en_i	(mult5_int_write_enable),
	.cache_data_i	(cache_data_out),
	.cache_addr_i	(cache_write_addr),
	.cache_wr_en_i	(cache_write_enable),
	.write_data_i	(lw_int_write_data),
	.write_addr_i	(lw_write_addr),
	.write_en_i	(lw_int_wrie_enable),
	.bypass_a_en_o	(bypass_a_en),
	.bypass_b_en_o	(bypass_b_en),
	.bypass_data_a_o (bypass_data_a),
	.bypass_data_b_o (bypass_data_b),
	.stall_core_o	(dec_stall_core)
);

int_registers int_registers(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.write_data_i	(lw_int_write_data),
	.read_addr_a_i	(dec_read_addr_a),
	.read_addr_b_i	(dec_read_addr_b),
	.write_addr_i	(lw_write_addr),
	.write_enable_i	(lw_int_write_enable),
	.read_data_a_o	(reg_read_data_a),
	.read_data_b_o	(reg_read_data_b)
);
	
dec_exe_latch dec_exe_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.dec_read_data_a_i	(dl_read_data_a),
	.dec_read_addr_b_i	(dl_read_data_b),
	.dec_write_addr_i	(dl_write_addr),
	.dec_int_write_enable_i	(dl_int_write_enable),
	.dec_instruction_i	(dec_instruction),
	.dec_pc_i		(dec_pc),
	.exe_read_addr_a_o	(le_read_addr_a),
	.exe_read_addr_b_o	(le_read_addr_b),
	.exe_write_addr_o	(le_write_addr),
	.exe_int_write_enable_o	(le_int_write_enable),
	.exe_instruction_o	(exe_instruction),
	.exe_pc_o		(exe_pc)
);

int_alu int_alu(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.pc_i		(exe_pc),
	.instr_i	(exe_instruction),
	.data_a_i	(el_int_data_a),
	.data_b_i	(el_int_data_b),
	.data_out_o	(el_int_data_out)
);
	
exe_mult1_latch exe_mult1_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.exe_int_write_data_i	(el_int_data_out),
	.exe_write_addr_i	(le_write_addr),
	.exe_int_write_enable_i	(le_int_write_enable),
	.exe_instruction_i	(exe_instruction),
	.exe_pc_i		(exe_pc),
	.mult1_int_write_data_o	(mult1_int_write_data),
	.mult1_write_addr_o	(mult1_write_addr),
	.mult1_int_write_enable_o	(mult1_int_write_enable),
	.mult1_instruction_o	(mult1_instruction),
	.mult1_pc_o		(mult1_pc)
);	
	
mult1_mult2_latch mult1_mult2_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.mult1_int_write_data_i	(mult1_int_data_out),
	.mult1_write_addr_i	(mult1_write_addr),
	.mult1_int_write_enable_i	(mult1_int_write_enable),
	.mult1_instruction_i	(mult1_instruction),
	.mult1_pc_i		(mult1_pc),
	.mult2_int_write_data_o	(mult2_int_write_data),
	.mult2_write_addr_o	(mult2_write_addr),
	.mult2_int_write_enable_o	(mult2_int_write_enable),
	.mult2_instruction_o	(mult2_instruction),
	.mult2_pc_o		(mult2_pc)
);
		
mult2_mult3_latch mult2_mult3_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.mult2_int_write_data_i	(mult2_int_data_out),
	.mult2_write_addr_i	(mult2_write_addr),
	.mult2_int_write_enable_i	(mult2_int_write_enable),
	.mult2_instruction_i	(mult2_instruction),
	.mult2_pc_i		(mult2_pc),
	.mult3_int_write_data_o	(mult3_int_write_data),
	.mult3_write_addr_o	(mult3_write_addr),
	.mult3_int_write_enable_o	(mult3_int_write_enable),
	.mult3_instruction_o	(mult3_instruction),
	.mult3_pc_o		(mult3_pc)
);
		
mult3_mult4_latch mult3_mult4_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.mult3_int_write_data_i	(mult3_int_data_out),
	.mult3_write_addr_i	(mult3_write_addr),
	.mult3_int_write_enable_i	(mult3_int_write_enable),
	.mult3_instruction_i	(mult3_instruction),
	.mult3_pc_i		(mult3_pc),
	.mult4_int_write_data_o	(mult4_int_write_data),
	.mult4_write_addr_o	(mult4_write_addr),
	.mult4_int_write_enable_o	(mult4_int_write_enable),
	.mult4_instruction_o	(mult4_instruction),
	.mult4_pc_o		(mult4_pc)
);	
	
mult4_mult5_latch mult4_mult5_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.mult4_int_write_data_i	(mult4_int_data_out),
	.mult4_write_addr_i	(mult4_write_addr),
	.mult4_int_write_enable_i	(mult4_int_write_enable),
	.mult4_instruction_i	(mult4_instruction),
	.mult4_pc_i		(mult4_pc),
	.mult5_int_write_data_o	(mult5_int_write_data),
	.mult5_write_addr_o	(mult5_write_addr),
	.mult5_int_write_enable_o	(mult5_int_write_enable),
	.mult5_instruction_o	(mult5_instruction),
	.mult5_pc_o		(mult5_pc)
);
	
exe_write_latch exe_write_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.emc_int_write_data_i	(emc_int_data_out),
	.emc_write_addr_i	(emc_write_addr),
	.emc_int_write_enable_i	(emc_int_write_enable),
	.emc_instruction_i	(emc_instruction),
	.emc_pc_i		(emc_pc),
	.write_int_write_data_o	(lw_int_write_data),
	.write_write_addr_o	(lw_write_addr),
	.write_int_write_enable_o	(lw_int_write_enable),
	.write_instruction_o	(wb_instruction),
	.write_pc_o		(wb_pc)
);

endmodule
