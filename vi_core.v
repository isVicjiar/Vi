// Main module of the project

module vi_core (
input		clk_i,
input		rsn_i,
input       mem_data_ready_i,
input   [127:0] mem_data_i,
input   [19:0]  mem_addr_i,

output      mem_read_o,
output  [19:0]  mem_read_addr_o,
output      mem_write_enable_o,
output      mem_write_byte_o,
output  [19:0]  mem_write_addr_o,
output  [31:0]  mem_write_data_o
);

//Memmory related outputs
wire i_mem_read;
wire d_mem_read;
wire [19:0] i_mem_read_addr;
wire [19:0] d_mem_read_addr;

assign mem_read_o = i_mem_read | d_mem_read;
assign mem_read_addr_o = i_mem_read ? i_mem_read_addr :
                                      d_mem_read_addr;

wire     sb_write_enable;
wire     sb_write_byte;
wire  [19:0]  sb_write_addr;
wire  [31:0]  sb_write_data;

assign mem_write_enable_o = sb_write_enable;
assign mem_write_addr_o = sb_write_addr;
assign mem_write_data_o = sb_write_data;
assign mem_write_byte_o = sb_write_byte;

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
wire [31:0] mult1_int_write_data;
wire [4:0] mult1_write_addr;
wire mult1_int_write_enable;
wire [31:0] mult2_instruction;
wire [31:0] mult2_pc;
wire [31:0] mult2_int_write_data;
wire [4:0] mult2_write_addr;
wire mult2_int_write_enable;
wire [31:0] mult3_instruction;
wire [31:0] mult3_pc;
wire [31:0] mult3_int_write_data;
wire [4:0] mult3_write_addr;
wire mult3_int_write_enable;
wire [31:0] mult4_instruction;
wire [31:0] mult4_pc;
wire [31:0] mult4_int_write_data;
wire [4:0] mult4_write_addr;
wire mult4_int_write_enable;
wire [31:0] mult5_instruction;
wire [31:0] mult5_pc;
wire [31:0] mult5_int_write_data;
wire [4:0] mult5_write_addr;
wire mult5_int_write_enable;

// Fetch
wire  [19:0] f_instr_addr;
wire f_itlb_hit;
wire f_itlb_read_only;
wire f_icache_miss;
wire fetch_stall;
wire itlb_supervisor;
//Branch predictor
wire [31:0] fbp_target_pc;
wire [31:0] bp_pred_pc;
wire bp_prediction;
wire bp_taken;
wire bp_error;


// Decode
wire [4:0] dec_read_addr_a;
wire [4:0] dec_read_addr_b;
wire [1:0] csr_addr;
wire [31:0] csr_data_read;
wire csr_read_en;
wire [31:0] reg_read_data_a;
wire [31:0] reg_read_data_b;
wire bypass_a_en;
wire bypass_b_en;
wire [31:0] bypass_data_a;
wire [31:0] bypass_data_b;
wire dec_stall_core;
wire bypass_stall_core;
wire [31:0] dec_dest_reg_value;
wire hf_stall_core;
wire hf_kill_instr;
wire [31:0] hf_kill_pc;
wire exc_occured;
wire write_mpriv_en;
wire [31:0] write_data_mpriv;
wire [31:0] exc_mepc;
wire [31:0] exc_mcause;
wire [31:0] exc_mtval;
wire [31:0] read_data_mpriv;
wire [31:0] read_data_mcause;
wire [31:0] read_data_mepc;
wire [31:0] read_data_mtval;
wire rec_write_en;
wire [4:0] rec_dest_reg;
wire [31:0] rec_dest_reg_value;
wire [31:0] reg_write_data;
wire [4:0] reg_write_addr;
wire reg_write_enable;
wire iret;
wire [31:0] pc_instr_addr;
wire jal;
wire [31:0] jal_pc;

// Latch - Decode = LD
wire [31:0]	    ld_exc_bits;

// Decode - Latch = DL
wire [31:0] dl_read_data_a;
wire [31:0] dl_read_data_b;
wire [4:0]  dl_write_addr;
wire	    dl_int_write_enable;
wire        dl_tlbwrite;
wire	    dl_idtlb_write;
wire [31:0] dl_pred_pc;
wire        dl_prediction;
wire        dl_taken;

// Latch - Exe = LE
wire [31:0] le_read_data_a;
wire [31:0] le_read_data_b;
wire [4:0]  le_write_addr;
wire 	    le_int_write_enable;
wire [31:0] le_exc_bits;

// Exe - Latch = EL
wire [31:0] el_int_data_out;

//Exe
wire [31:0] exe_pred_pc;
wire        exe_prediction;
wire        exe_taken;
	
// Latch - Write back = LW
wire [4:0]  lw_write_addr;
wire	    lw_int_write_enable;
wire [31:0] lw_int_write_data;
wire [31:0] lw_exc_bits;
wire [31:0] lw_miss_addr;

// Latch - TL
wire 	tl_cache_enable;
wire	tl_store;
wire	[31:0] tl_cache_addr;
wire	[4:0]  tl_write_addr;
wire	tl_write_enable;
wire	[31:0] tl_store_data;
wire	tl_tlbwrite;
wire	tl_idtlb;
wire	[31:0] tl_read_data_a;
wire	[31:0] tl_read_data_b;
wire	[31:0] tl_exc_bits;

// dTLB - Lookup = TL
wire [19:0] tl_addr;
wire tl_dtlb_hit;
wire tl_dtlb_read_only;

// TransLookup - Latch = TLL
wire [1:0]  tll_hit_way;
wire [1:0]  tll_lru_way;
wire        tll_misalign_exc;
wire        tll_miss_stall;
wire        tll_miss;
wire        tll_update_cache;
wire        tll_buffer_hit;
wire [31:0] tll_buffer_data;

// Latch - Cache = LC
wire [19:0] lc_addr;
wire        lc_rqst_byte;
wire [1:0]  lc_hit_way;
wire [1:0]  lc_lru_way;
wire        lc_miss;
wire        lc_buffer_hit;
wire [31:0] lc_buffer_data;
wire        lc_write_enable;
wire [4:0]  lc_write_addr;
wire	    lc_cache_enable;
wire [31:0] lc_v_cache_addr;
wire [31:0] lc_exc_bits;
wire [31:0] c_data;

// Cache - Latch = CL
wire [31:0] cl_data;
assign cl_data = lc_buffer_hit ? lc_buffer_data : c_data;

//Write = w
wire w_write_hit;
wire [1:0] w_hit_way;

assign csr_data_read = (csr_addr[1]) ? ((csr_addr[0]) ? read_data_mpriv : read_data_mcause) : ((csr_addr[0]) ? read_data_mtval : read_data_mepc);
assign dl_read_data_a = (csr_read_en) ? csr_data_read : ((bypass_a_en) ? bypass_data_a : reg_read_data_a);
assign dl_read_data_b = (bypass_b_en) ? bypass_data_b : reg_read_data_b;
assign reg_write_data = (rec_write_en) ? rec_dest_reg_value : lw_int_write_data;
assign reg_write_addr = (rec_write_en) ? rec_dest_reg : lw_write_addr;
assign reg_write_enable = (rec_write_en) ? 1'b1 : lw_int_write_enable;
assign dec_stall_core = bypass_stall_core || hf_stall_core;
assign write_mpriv_en = (iret || exc_occured) ? 1'b1 : 1'b0;
assign write_data_mpriv = (iret) ? 1'b0 : ((exc_occured) ? 1'b1 : write_data_mpriv);
assign fetch_pc = (iret) ? read_data_mepc : ((jal) ? jal_pc : pc_instr_addr);
assign itlb_supervisor = (iret) ? 1'b0 : read_data_mpriv[0];
assign tll_miss_stall = (tll_miss & !tll_buffer_hit)& tl_dtlb_hit && tl_cache_enable && tl_instruction[6:0]==7'b0000011;

fetch fetch(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.stall_core_i		(fetch_stall || dec_stall_core || tll_miss_stall),
	.iret_i			(iret),
	.exc_return_pc_i 	(read_data_mepc),
	.jal_i			(jal),
	.jal_pc_i		(jal_pc),
	.exc_occured_i		(exc_occured),
 	.bp_pred_pc_i       	(bp_pred_pc),
	.bp_prediction_i    	(bp_prediction),      
	.bp_taken_i         	(bp_taken),
	.bp_error_i         	(bp_error),
	.alu_branch_i       	(exe_instruction[6:0] == 7'b1100011),
	.alu_jumps_i        	(el_int_data_out != exe_pc),
	.alu_pc_jmp_i       	(el_int_data_out),
	.alu_pc_no_jmp_i	(exe_pc+4),
	.pc_o			(pc_instr_addr),
	.next_pc_o		(fbp_target_pc)
);

branch_predictor branch_predictor(
	.clk_i      		(clk_i),
	.rsn_i      		(rsn_i),
	.pc_i       		(pc_instr_addr),
	.target_pc_i    	(fbp_target_pc),
	.alu_branch_i   	(exe_instruction[6:0] == 7'b1100011),
	.alu_jumps_i    	(el_int_data_out != exe_pc),
	.alu_prediction_i   	(exe_prediction),
	.alu_taken_i        	(exe_taken),
	.alu_pc_ok_i        	(exe_pred_pc == el_int_data_out),
	.alu_branch_pc_i    	(exe_pc),
	.pred_pc_o      	(bp_pred_pc),
	.prediction_o   	(bp_prediction),
	.taken_o        	(bp_taken),
	.bp_error_o     	(bp_error)
);

tlb itlb(
	.clk_i      		(clk_i),
	.rsn_i      		(rsn_i),
	.supervisor_i   	(itlb_supervisor),
	.v_addr_i       	(fetch_pc),
	.write_enable_i     	(le_tlbwrite && !le_idtlb),
	.new_physical_i     	(le_read_data_b[19:0]),
	.new_virtual_i      	(le_read_data_a), 
	.new_read_only_i    	(le_tlbwrite && !le_idtlb),
	.p_addr_o       	(f_instr_addr),
	.tlb_hit_o      	(f_itlb_hit),
	.tlb_protected_o    	(f_itlb_read_only)
);

instruction_cache   instruction_cache(
	.clk_i      		(clk_i),
	.rsn_i      		(rsn_i),
	.addr_i     		(f_instr_addr),
	.mem_data_ready_i   	(mem_data_ready_i),
	.mem_data_i         	(mem_data_i),
	.mem_addr_i         	(mem_addr_i),
	.cancel_wait_i      (bp_error),
	.data_o     		(fetch_instruction),
	.rqst_to_mem_o      	(i_mem_read),
	.addr_to_mem_o      	(i_mem_read_addr),
	.miss_o     		(f_icache_miss),
	.fetch_stall_o		(fetch_stall)
);

fetch_dec_latch fetch_dec_latch(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.stall_core_i		(dec_stall_core || tll_miss_stall),
	.kill_i     		(bp_error || hf_kill_instr),
	.stall_fetch_i 		(fetch_stall),
	.fetch_misaligned_instr_exc_i (|fetch_pc[1:0]),
	.fetch_instr_fault_exc_i (!f_itlb_hit),
	.fetch_instr_i		(fetch_instruction),
	.fetch_pc_i		(fetch_pc),
	.fetch_pred_pc_i    	(bp_pred_pc),
	.fetch_prediction_i 	(bp_prediction),
	.fetch_taken_i        	(bp_taken),
	.dec_pred_pc_o  	(dl_pred_pc),
	.dec_prediction_o 	(dl_prediction),
	.dec_taken_o    	(dl_taken),
	.dec_exc_bits_o		(ld_exc_bits),
	.dec_null_val_o     (ld_null_val),
	.dec_instr_o		(dec_instruction),
	.dec_pc_o		(dec_pc)
);

decoder decoder(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.instr_i		(dec_instruction),
	.pc_i			(dec_pc),
	.read_addr_a_o		(dec_read_addr_a),
	.read_addr_b_o		(dec_read_addr_b),
	.write_addr_o		(dl_write_addr),
	.int_write_enable_o	(dl_int_write_enable),
	.tlbwrite_o		(dl_tlbwrite),
	.idtlb_write_o		(dl_idtlb_write),
	.csr_addr_o		(csr_addr),
	.csr_read_en_o		(csr_read_en),
	.iret_o			(iret),
	.jal_o			(jal),
	.jal_pc_o		(jal_pc)
);

bypass_ctrl bypass_ctrl (
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.dec_read_addr_a_i	(dec_read_addr_a),
	.dec_read_addr_b_i	(dec_read_addr_b),
	.dec_wr_en_i		(dl_int_write_enable),
	.dec_wr_addr_i		(dl_write_addr),
	.dec_instr_i		(dec_instruction),
	.exe_data_i		(el_int_data_out),
	.exe_addr_i		(le_write_addr),
	.exe_wr_en_i		(le_int_write_enable),
	.exe_instr_i		(exe_instruction),
	.mult1_data_i		(mult1_int_write_data),
	.mult1_addr_i		(mult1_write_addr),
	.mult1_wr_en_i		(mult1_int_write_enable),
	.mult2_data_i		(mult2_int_write_data),
	.mult2_addr_i		(mult2_write_addr),
	.mult2_wr_en_i		(mult2_int_write_enable),
	.mult3_data_i		(mult3_int_write_data),
	.mult3_addr_i		(mult3_write_addr),
	.mult3_wr_en_i		(mult3_int_write_enable),
	.mult4_data_i		(mult4_int_write_data),
	.mult4_addr_i		(mult4_write_addr),
	.mult4_wr_en_i		(mult4_int_write_enable),
	.mult5_data_i		(mult5_int_write_data),
	.mult5_addr_i		(mult5_write_addr),
	.mult5_wr_en_i		(mult5_int_write_enable),
	.tl_addr_i		(tl_write_addr),
	.tl_wr_en_i		(tl_write_enable),
	.tl_cache_en_i		(tl_cache_enable),
	.cache_data_i		(cl_data),
	.cache_addr_i		(lc_write_addr),
	.cache_wr_en_i		(lc_write_enable),
	.cache_en_i		(lc_cache_enable),
	.cache_hit_i		(!lc_miss),
	.write_data_i		(lw_int_write_data),
	.write_addr_i		(lw_write_addr),
	.write_en_i		(lw_int_write_enable),
	.bypass_a_en_o		(bypass_a_en),
	.bypass_b_en_o		(bypass_b_en),
	.bypass_data_a_o 	(bypass_data_a),
	.bypass_data_b_o 	(bypass_data_b),
	.stall_core_o		(bypass_stall_core)
);

int_registers int_registers(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.write_data_i		(reg_write_data),
	.write_exc_en_i		(exc_occured),
	.write_data_mepc_i	(exc_mepc),
	.write_data_mtval_i	(exc_mtval),
	.write_data_mcause_i	(exc_mcause),
	.write_data_mpriv_i	(write_data_mpriv),
	.write_mpriv_en_i	(write_mpriv_en),
	.read_addr_a_i		(dec_read_addr_a),
	.read_addr_b_i		(dec_read_addr_b),
	.dec_write_addr_i 	(dl_write_addr),
	.write_addr_i		(reg_write_addr),
	.write_enable_i		(reg_write_enable),
	.read_data_a_o		(reg_read_data_a),
	.read_data_b_o		(reg_read_data_b),
	.read_data_mepc_o	(read_data_mepc),
	.read_data_mtval_o	(read_data_mtval),
	.read_data_mcause_o	(read_data_mcause),
	.read_data_mpriv_o	(read_data_mpriv),
	.dec_dest_reg_value_o 	(dec_dest_reg_value)
);
	
history_file history_file(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.stall_decode_i		(dec_stall_core || tll_miss_stall),
	.dec_null_val_i     	(ld_null_val),
	.dec_dest_reg_i		(dl_write_addr),
	.dec_dest_reg_value_i	(dec_dest_reg_value),
	.dec_int_write_enable_i	(dl_int_write_enable),
	.dec_pc_i		(dec_pc),
	.wb_pc_i		(wb_pc),
	.wb_dest_reg_i		(lw_write_addr),
	.wb_exc_i		(lw_exc_bits),
	.wb_miss_addr_i		(lw_miss_addr),
	.stall_decode_o		(hf_stall_core),
	.kill_instr_o		(hf_kill_instr),
	.kill_pc_o		(hf_kill_pc),
	.rec_dest_reg_value_o	(rec_dest_reg_value),
	.rec_dest_reg_o		(rec_dest_reg),
	.rec_write_en_o		(rec_write_en),
	.exc_occured_o		(exc_occured),
	.exc_mtval_o		(exc_mtval),
	.exc_mepc_o		(exc_mepc),
	.exc_mcause_o		(exc_mcause)
);
	
dec_exe_latch dec_exe_latch(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.stall_core_i		(hf_stall_core || tll_miss_stall),
	.decode_stall_i  (dec_stall_core),
	.kill_i			(hf_kill_instr || bp_error),
	.dec_read_data_a_i	(dl_read_data_a),
	.dec_read_data_b_i	(dl_read_data_b),
	.dec_write_addr_i	(dl_write_addr),
	.dec_int_write_enable_i	(dl_int_write_enable),
	.dec_tlbwrite_i		(dl_tlbwrite),
	.dec_idtlb_i		(dl_idtlb_write),
	.dec_exc_bits_i		(ld_exc_bits),
	.dec_instruction_i	(dec_instruction),
	.dec_pc_i		(dec_pc),
	.dec_pred_pc_i      	(dl_pred_pc),
	.dec_prediction_i   	(dl_prediction),
	.dec_taken_i        	(dl_taken),
	.exe_read_data_a_o	(le_read_data_a),
	.exe_read_data_b_o	(le_read_data_b),
	.exe_write_addr_o	(le_write_addr),
	.exe_int_write_enable_o	(le_int_write_enable),
	.exe_tlbwrite_o		(le_tlbwrite),
	.exe_idtlb_o		(le_idtlb),
	.exe_pred_pc_o      	(exe_pred_pc),
	.exe_prediction_o   	(exe_prediction),
	.exe_taken_o        	(exe_taken),
	.exe_exc_bits_o		(le_exc_bits),
	.exe_instruction_o	(exe_instruction),
	.exe_pc_o		(exe_pc)
);

int_alu int_alu(
	.clk_i			(clk_i),
	.rsn_i			(rsn_i),
	.pc_i			(exe_pc),
	.instr_i		(exe_instruction),
	.data_a_i		(le_read_data_a),
	.data_b_i		(le_read_data_b),
	.data_out_o		(el_int_data_out),
	.illegal_inst_o 	(el_illegal_inst)
);

exe_tl_latch exe_tl_latch (
	.clk_i 				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
	.stall_core_i			(tll_miss_stall),
	.exe_cache_addr_i 		(el_int_data_out),
	.exe_write_addr_i		(le_write_addr),
	.exe_int_write_enable_i		(le_int_write_enable),
	.exe_store_data_i		(le_read_data_b),
	.exe_tlbwrite_i			(le_tlbwrite),
	.exe_idtlb_i			(le_idtlb),
	.exe_read_data_a_i		(le_read_data_a),
	.exe_read_data_b_i		(le_read_data_b),
	.exe_exc_bits_i			(le_exc_bits),
	.exe_instruction_i		(exe_instruction),
	.exe_pc_i			(exe_pc),
	.tl_cache_enable_o		(tl_cache_enable),
	.tl_cache_addr_o		(tl_cache_addr),
	.tl_write_addr_o		(tl_write_addr),
	.tl_int_write_enable_o		(tl_write_enable),
	.tl_store_o			(tl_store),
	.tl_store_data_o		(tl_store_data),
	.tl_tlbwrite_o			(tl_tlbwrite),
	.tl_idtlb_o			(tl_idtlb),
	.tl_read_data_a_o		(tl_read_data_a),
	.tl_read_data_b_o		(tl_read_data_b),
	.tl_exc_bits_o			(tl_exc_bits),
	.tl_instruction_o		(tl_instruction),
	.tl_pc_o			(tl_pc)
);

tlb dtlb(
    .clk_i      	(clk_i),
    .rsn_i      	(rsn_i),
    .supervisor_i   	(read_data_mpriv[0]),
    .v_addr_i       	(tl_cache_addr),
    .write_enable_i     (le_tlbwrite && le_idtlb),
    .new_physical_i     (le_read_data_b[19:0]),
    .new_virtual_i      (le_read_data_a), 
    .new_read_only_i    (1'b0),
    .p_addr_o       	(tl_addr),
    .tlb_hit_o      	(tl_dtlb_hit),
    .tlb_protected_o    (tl_dtlb_read_only)
);

lookup lookup(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .read_addr_i        (tl_addr),
    .write_addr_i       (sb_write_addr),
    .read_rqst_i        (tl_cache_enable & tl_write_enable),        
    .write_enable_i     (sb_write_enable),
    .rqst_byte_i        (tl_instruction[12]),   
    .mem_data_ready_i   (mem_data_ready_i),
    .mem_addr_i         (mem_addr_i),
    .kill_i             (hf_kill_instr),
    .read_hit_way_o     (tll_hit_way),
    .write_hit_way_o    (w_hit_way),
    .lru_way_o          (tll_lru_way),
    .rqst_to_mem_o      (d_mem_read),
    .addr_to_mem_o      (d_mem_read_addr),
    .unalign_o          (tll_misalign_exc),
    .write_hit_o        (w_write_hit),
    .read_miss_o        (tll_miss),
    .update_cache_o     (tll_update_cache)
);

store_buffer store_buffer(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .addr_i             (tl_addr),
    .data_i             (tl_store_data),
    .write_pc_i         (tl_pc),
    .write_enable_i     (tl_instruction[6:0] == 7'b0100011 && tl_cache_enable),
    .write_byte_i       (tl_instruction[12]),   
    .kill_i             (hf_kill_instr),
    .kill_pc_i          (hf_kill_pc),
    .read_i             (tl_cache_enable & tl_write_enable),        
    .read_addr_i        (tl_addr),
    .read_byte_i        (tl_instruction[12]),
    .do_write_i         (wb_instruction[6:0] == 7'b0100011 && !lw_exc_bits),

    .full_o             (store_buffer_full),
    .data_in_buffer_o   (tll_buffer_hit),
    .data_read_o        (tll_buffer_data),
    .addr_to_mem_o      (sb_write_addr),
    .data_to_mem_o      (sb_write_data),
    .byte_to_mem_o      (sb_write_byte),
    .mem_write_o        (sb_write_enable)
);

tl_cache_latch tl_cache_latch(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .kill_i		(hf_kill_instr),
    .stall_core_i       (tll_miss_stall),
    .tl_addr_i          (tl_addr),
    .tl_rqst_byte_i     (tl_instruction[12]),
    .tl_hit_way_i       (tll_hit_way),
    .tl_lru_way_i       (tll_lru_way),
    .tl_miss_i          (tll_miss),
    .tl_buffer_hit_i    (tll_buffer_hit),
    .tl_buffer_data_i   (tll_buffer_data),
    .tl_int_write_enable_i    (tl_write_enable),
    .tl_write_addr_i    (tl_write_addr),
    .tl_cache_enable_i	(tl_cache_enable),
    .tl_v_cache_addr_i	(tl_cache_addr),
    .tl_misaligned_ld_i	(tl_instruction[6:0] == 7'b0000011 && tll_misalign_exc),
    .tl_misaligned_st_i	(tl_instruction[6:0] == 7'b0100011 && tll_misalign_exc),
    .tl_load_fault_exc_i(!tl_dtlb_hit && tl_instruction[6:0] == 7'b0000011),
    .tl_store_fault_exc_i(!tl_dtlb_hit && tl_instruction[6:0] == 7'b0100011),
    .tl_exc_bits_i	(tl_exc_bits),
    .tl_instruction_i	(tl_instruction),
    .tl_pc_i            (tl_pc),
    .c_addr_o           (lc_addr),
    .c_rqst_byte_o      (lc_rqst_byte),
    .c_hit_way_o        (lc_hit_way),
    .c_lru_way_o        (lc_lru_way),
    .c_miss_o           (lc_miss),
    .c_buffer_hit_o     (lc_buffer_hit),
    .c_buffer_data_o    (lc_buffer_data),
    .c_int_write_enable_o    (lc_write_enable),
    .c_write_addr_o     (lc_write_addr),
    .c_cache_enable_o	(lc_cache_enable),
    .c_v_cache_addr_o	(lc_v_cache_addr),
    .c_exc_bits_o	(lc_exc_bits),
    .c_instruction_o	(cache_instruction),
    .c_pc_o             (cache_pc)
);

cache cache(
    .clk_i              (clk_i),
    .rsn_i              (rsn_i),
    .read_addr_i        (lc_addr),
    .rqst_byte_i        (lc_rqst_byte),
    .write_enable_i     (sb_write_enable),
    .write_data_i       (sb_write_data),
    .write_addr_i       (sb_write_addr),
    .write_byte_i       (sb_write_byte),
    .mem_data_ready_i   (tll_update_cache),
    .mem_data_i         (mem_data_i),
    .read_hit_way_i     (lc_hit_way),
    .write_hit_way_i    (w_hit_way),
    .lru_way_i          (lc_lru_way),
    .write_hit_i        (w_write_hit),
    .read_miss_i        (tll_miss),
    .data_o             (c_data)
);
	
exe_mult1_latch exe_mult1_latch(
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
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
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
	.mult1_int_write_data_i		(mult1_int_write_data),
	.mult1_write_addr_i		(mult1_write_addr),
	.mult1_int_write_enable_i	(mult1_int_write_enable),
	.mult1_instruction_i		(mult1_instruction),
	.mult1_pc_i			(mult1_pc),
	.mult2_int_write_data_o		(mult2_int_write_data),
	.mult2_write_addr_o		(mult2_write_addr),
	.mult2_int_write_enable_o	(mult2_int_write_enable),
	.mult2_instruction_o		(mult2_instruction),
	.mult2_pc_o			(mult2_pc)
);
		
mult2_mult3_latch mult2_mult3_latch(
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
	.mult2_int_write_data_i		(mult2_int_write_data),
	.mult2_write_addr_i		(mult2_write_addr),
	.mult2_int_write_enable_i	(mult2_int_write_enable),
	.mult2_instruction_i		(mult2_instruction),
	.mult2_pc_i			(mult2_pc),
	.mult3_int_write_data_o		(mult3_int_write_data),
	.mult3_write_addr_o		(mult3_write_addr),
	.mult3_int_write_enable_o	(mult3_int_write_enable),
	.mult3_instruction_o		(mult3_instruction),
	.mult3_pc_o			(mult3_pc)
);
		
mult3_mult4_latch mult3_mult4_latch(
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
	.mult3_int_write_data_i		(mult3_int_write_data),
	.mult3_write_addr_i		(mult3_write_addr),
	.mult3_int_write_enable_i	(mult3_int_write_enable),
	.mult3_instruction_i		(mult3_instruction),
	.mult3_pc_i			(mult3_pc),
	.mult4_int_write_data_o		(mult4_int_write_data),
	.mult4_write_addr_o		(mult4_write_addr),
	.mult4_int_write_enable_o	(mult4_int_write_enable),
	.mult4_instruction_o		(mult4_instruction),
	.mult4_pc_o			(mult4_pc)
);	
	
mult4_mult5_latch mult4_mult5_latch(
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
	.mult4_int_write_data_i		(mult4_int_write_data),
	.mult4_write_addr_i		(mult4_write_addr),
	.mult4_int_write_enable_i	(mult4_int_write_enable),
	.mult4_instruction_i		(mult4_instruction),
	.mult4_pc_i			(mult4_pc),
	.mult5_int_write_data_o		(mult5_int_write_data),
	.mult5_write_addr_o		(mult5_write_addr),
	.mult5_int_write_enable_o	(mult5_int_write_enable),
	.mult5_instruction_o		(mult5_instruction),
	.mult5_pc_o			(mult5_pc)
);

exe_write_latch exe_write_latch(
	.clk_i				(clk_i),
	.rsn_i				(rsn_i),
	.kill_i				(hf_kill_instr),
	.exe_int_write_data_i		(el_int_data_out),
	.exe_write_addr_i		(le_write_addr),
	.exe_int_write_enable_i		(le_int_write_enable),
	.exe_illegal_inst_exc_i		(el_illegal_inst),
	.exe_exc_bits_i			(le_exc_bits),
	.exe_instruction_i		(exe_instruction),
	.exe_pc_i			(exe_pc),
	.mult5_int_write_data_i		(mult5_int_write_data),
	.mult5_write_addr_i		(mult5_write_addr),
	.mult5_int_write_enable_i	(mult5_int_write_enable),
	.mult5_instruction_i		(mult5_instruction),
	.mult5_pc_i			(mult5_pc),
	.cache_int_write_data_i		(cl_data),
	.cache_write_addr_i		(lc_write_addr),
	.cache_int_write_enable_i	(lc_write_enable),
	.cache_cache_enable_i		(lc_cache_enable),
	.cache_exc_bits_i		(lc_exc_bits),
	.cache_miss_addr_i		(lc_v_cache_addr),
	.cache_instruction_i		(cache_instruction),
	.cache_pc_i			(cache_pc),
	.write_int_write_data_o		(lw_int_write_data),
	.write_write_addr_o		(lw_write_addr),
	.write_int_write_enable_o	(lw_int_write_enable),
	.write_exc_bits_o		(lw_exc_bits),
	.write_miss_addr_o		(lw_miss_addr),
	.write_instruction_o		(wb_instruction),
	.write_pc_o			(wb_pc)
);

endmodule
