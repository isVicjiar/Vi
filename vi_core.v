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
wire [31:0] tl_instruction;
wire [31:0] tl_pc;
wire [31:0] cache_instruction;
wire [31:0] cache_pc;
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

// Fetch
wire  [19:0] f_instr_addr;
wire f_itlb_hit;
wire f_itlb_read_only;
wire f_icache_hit;
wire f_icache_miss;

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
wire bypass_stall_core;
wire hf_stall_core;
wire [31:0] reg_write_data;
wire [4:0] reg_write_addr;
wire reg_write_enable;
	
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

// dTLB - Lookup = TL
wire [19:0] tl_addr;
wire tl_dtlb_hit;
wire tl_dtlb_read_only;

// TransLookup - Latch = TLL
wire [1:0]  tll_hit_way;
wire [1:0]  tll_lru_way;
wire        tll_missalign_exc;
wire        tll_hit;
wire        tll_miss;

// Latch - Cache = LC
wire [19:0] lc_addr;
wire        lc_rqst_byte;
wire [1:0]  lc_hit_way;
wire [1:0]  lc_lru_way;
wire        lc_hit;
wire        lc_miss;

// Cache - Latch = CL
wire [31:0] cl_data;

assign dl_read_data_a = (bypass_a_en) ? bypass_data_a : reg_read_data_a;
assign dl_read_data_b = (bypass_b_en) ? bypass_data_b : reg_read_data_b;
assign reg_write_data = (rec_write_en) ? rec_dest_reg_value : lw_int_write_data;
assign reg_write_addr = (rec_write_en) ? rec_dest_reg : lw_write_addr;
assign reg_write_enable = (rec_write_en) ? 1'b1 : lw_int_write_enable;
assign dec_stall_core = bypass_stall_core || hf_stall_core;
	
fetch fetch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.stall_core_i	(dec_stall_core),
	.pc_o	(fetch_pc)
);

itlb tlb(
    .clk_i      (clk_i),
    .rsn_i      (rsn_i),
    .supervisor_i   (supervisor_mode),
    .v_addr_i       (fetch_pc),
    .write_enable_i     (update_itlb),
    .new_physical_i     (update_itlb_p),
    .new_virutal_i      (update_itlb_v), 
    .new_read_only_i    (update_itlb_r),
    .p_addr_o       (f_instr_addr),
    .tlb_hit_o      (f_itlb_hit),
    .tlb_protected_o    (f_itlb_read_only)
);

instruction_cache   instruction_cache(
    .clk_i      (clk_i),
    .rsn_i      (rsn_i),
    .addr_i     (f_instr_addr),
    //missing memory .mem_data_ready_i,
    //missing memory .mem_data_i,
    //missing memory .mem_addr_i,
    .data_o     (fetch_instruction),
    //missing memory .rqst_to_mem_o,
    //missing memory .addr_to_mem_o,
    .hit_o      (f_icache_hit),
    .miss_o     (f_icache_miss)
);

fetch_dec_latch fetch_dec_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.stall_core_i	(dec_stall_core),
	.fetch_instr_i	(fetch_instruction),
	
	.dec_instr_o	(dec_instruction)
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
	.dec_wr_en_i	(dec_write_enable),
	.dec_wr_addr_i	(dec_write_addr),
	.exe_data_i	(el_int_data_out),
	.exe_addr_i	(le_write_addr),
	.exe_wr_en_i	(le_int_write_enable),
	.exe_instr_i	(exe_instruction),
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
	.tl_addr_i	(tl_write_addr),
	.tl_wr_en_i	(tl_int_write_enable),
	.cache_data_i	(cache_data_out),
	.cache_addr_i	(cache_write_addr),
	.cache_wr_en_i	(cache_write_enable),
	.cache_hit_i	(cache_hit),
	.write_data_i	(lw_int_write_data),
	.write_addr_i	(lw_write_addr),
	.write_en_i	(lw_int_wrie_enable),
	.bypass_a_en_o	(bypass_a_en),
	.bypass_b_en_o	(bypass_b_en),
	.bypass_data_a_o (bypass_data_a),
	.bypass_data_b_o (bypass_data_b),
	.stall_core_o	(bypass_stall_core)
);

int_registers int_registers(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.write_data_i	(reg_write_data),
	.read_addr_a_i	(dec_read_addr_a),
	.read_addr_b_i	(dec_read_addr_b),
	.dec_write_addr_i (dl_write_addr),
	.write_addr_i	(reg_write_addr),
	.write_enable_i	(reg_write_enable),
	.read_data_a_o	(reg_read_data_a),
	.read_data_b_o	(reg_read_data_b),
	.dec_dest_reg_value_o (dec_dest_reg_value)
);
	
history_file history_file(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.stall_decode_i	(dec_stall_core),
	.dec_dest_reg_i	(dl_write_addr),
	.dec_dest_reg_value_i	(dec_dest_reg_value),
	.dec_pc_i	(dec_pc),
	.wb_pc_i	(wb_pc),
	.wb_dest_reg_i	(wb_write_addr),
	.wb_exc_i	(wb_exc_bits),
	.wb_miss_addr_i	(wb_miss_addr),
	.stall_decode_o	(hf_stall_decode),
	.kill_instr_o	(hf_kill_instr),
	.rec_dest_reg_value_o	(rec_dest_reg_value),
	.rec_dest_reg_o	(rec_dest_reg),
	.rec_write_en_o	(rec_write_en)		
);
	
dec_exe_latch dec_exe_latch(
	.clk_i		(clk_i),
	.rsn_i		(rsn_i),
	.stall_core_i	(dec_stall_core),
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

exe_tl_latch exe_tl_latch (
	.clk_i 				(clk_i),
	.rsn_i				(rsn_i),
	.stall_core_i			(tl_stall_core),
	.exe_cache_addr_i 		(el_int_data_out),
	.exe_write_addr_i		(le_write_addr),
	.exe_int_write_enable_i		(le_int_write_enable),
	.exe_store_data_i		(el_int_data_b),
	.exe_instruction_i		(exe_instruction),
	.exe_pc_i			(exe_pc),
	.tl_cache_enable_o		(tl_cache_enable),
	.tl_cache_addr_o		(tl_cache_addr),
	.tl_write_addr_o		(tl_write_addr),
	.tl_write_enable_o		(tl_write_enable),
	.tl_store_data_o		(tl_store_data),
	.tl_instruction_o		(tl_instruction),
	.tl_pc_o			(tl_pc)
);

dtlb tlb(
    .clk_i      (clk_i),
    .rsn_i      (rsn_i),
    .supervisor_i   (supervisor_mode),
    .v_addr_i       (tl_cache_addr),
    .write_enable_i     (update_dtlb),
    .new_physical_i     (update_dtlb_p),
    .new_virutal_i      (update_dtlb_v), 
    .new_read_only_i    (update_dtlb_r),
    .p_addr_o       (tl_addr),
    .tlb_hit_o      (tl_dtlb_hit),
    .tlb_protected_o    (tl_dtlb_read_only)
);

lookup lookup(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .addr_i             (tl_addr),
    .read_rqst_i        (tl_cache_enable & ~tl_write_enable),        
    .write_rqst_i       (tl_cache_enable & tl_write_enable),
    // missing .rqst_byte_i,   
    // missing memory .mem_data_ready_i,
    // missing memory .mem_addr_i,
    .hit_way_o,         (tll_hit_way),
    .lru_way_o,         (tll_lru_way),
    // missing memory .rqst_to_mem_o,
    // missing memory .addr_to_mem_o,
    .unalign_o          (tll_missalign_exc),
    .hit_o              (tll_hit),
    .miss_o             (tll_miss)
);

tl_cache_latch tl_cache_latch(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .stall_core_i       (lc_stall_core),
    .tl_addr_i          (tl_addr),
    //missing .tl_rqst_byte_i,
    .tl_hit_way_i       (tll_hit_way),
    .tl_lru_way_i       (tll_lru_way),
    .tl_hit_i           (tll_hit),
    .tl_miss_i          (tll_miss),
    .c_addr_o           (lc_addr),
    .c_rqst_byte_o      (lc_rqst_byte),
    .c_hit_way_o        (lc_hit_way),
    .c_lru_way_o        (lc_lru_way),
    .c_hit_o            (lc_hit),
    .c_miss_o           (lc_miss)
);

cache cache(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .addr_i             (lc_addr),
    .rqst_byte_i        (lc_rqst_byte),
    //missing memory .mem_data_ready_i   (),
    //missing memory .mem_data_i,
    .hit_way_i          (lc_hit_way),
    .lru_way_i          (lc_lru_way),
    .hit_i              (lc_hit),
    .miss_i             (lc_miss),
    .data_o             (cl_data)
);
	
exe_mult1_latch exe_mult1_latch(
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.exe_int_write_data_i		(el_int_data_out),
	.exe_write_addr_i		(le_write_addr),
	.exe_int_write_enable_i		(le_int_write_enable),
	.exe_instruction_i		(exe_instruction),
	.exe_pc_i			(exe_pc),
	.mult1_int_write_data_o		(mult1_int_write_data),
	.mult1_write_addr_o		(mult1_write_addr),
	.mult1_int_write_enable_o	(mult1_int_write_enable),
	.mult1_instruction_o		(mult1_instruction),
	.mult1_pc_o			(mult1_pc)
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
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.exe_int_write_data_i		(el_int_data_out),
	.exe_write_addr_i		(le_write_addr),
	.exe_int_write_enable_i		(le_int_write_enable),
	.exe_instruction_i		(exe_instruction),
	.exe_pc_i			(exe_pc),
	.mult5_int_write_data_i		(mult5_int_data_out),
	.mult5_write_addr_i		(mult5_write_addr),
	.mult5_int_write_enable_i	(mult5_int_write_enable),
	.mult5_instruction_i		(mult5_instruction),
	.mult5_pc_i			(mult5_pc),
	.cache_int_write_data_i		(cache_int_data_out),
	.cache_write_addr_i		(cache_write_addr),
	.cache_int_write_enable_i	(cache_int_write_enable),
	.cache_instruction_i		(cache_instruction),
	.cache_pc_i			(cache_pc),
	.write_int_write_data_o		(lw_int_write_data),
	.write_write_addr_o		(lw_write_addr),
	.write_int_write_enable_o	(lw_int_write_enable),
	.write_instruction_o		(wb_instruction),
	.write_pc_o			(wb_pc)
);

endmodule
