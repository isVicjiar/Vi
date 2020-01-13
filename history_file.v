// History file

module history_file (
input 		clk_i,
input 		rsn_i,
input 		stall_decode_i,
input       dec_null_val_i,
input 	[4:0] 	dec_dest_reg_i,
input 	[31:0] 	dec_pc_i,
input 	[31:0] 	dec_dest_reg_value_i,
input		dec_int_write_enable_i,
input 	[31:0] 	wb_pc_i,
input 	[4:0] 	wb_dest_reg_i,
input 	[31:0] 	wb_exc_i,
input 	[31:0] 	wb_miss_addr_i,
output reg 	stall_decode_o,
output reg 	kill_instr_o,
output reg [31:0] kill_pc_o,
output reg 	[31:0] 	rec_dest_reg_value_o,
output reg 	[4:0] 	rec_dest_reg_o,
output reg	rec_write_en_o,
output reg	exc_occured_o,
output reg 	[31:0] exc_mtval_o,
output reg 	[31:0] exc_mepc_o,
output reg 	[31:0] exc_mcause_o
);
//	([134] write_en) + ([133] finished) + ([132:101] exc_bits) + ([100:69] @miss address)
//	+ ([68:37] pc) + ([36:32] dec_dest_Reg) + ([31:0] dec_dest_reg_value)
reg [133:0] hf_queue [15:0];
reg [3:0] hf_head;
reg [3:0] hf_tail;
reg recovery_inflight;
reg [3:0] recovery_index;
integer i;	
reg [4:0] hf_index;

assign dec_null_val = (dec_null_val_i===1'bx) ? 1 : dec_null_val_i;

always @ (posedge clk_i) begin 
	hf_index = 5'b10000;
	rec_write_en_o = 1'b0;
	stall_decode_o = 1'b0;
	kill_instr_o = 1'b0;
	exc_occured_o = 1'b0;
	if (!rsn_i) begin
		recovery_inflight = 1'b0;
		hf_index = 5'b10000;
		rec_write_en_o = 1'b0;
		stall_decode_o = 1'b0;
		kill_instr_o = 1'b0;
		exc_occured_o = 1'b0;
		hf_head = 4'b0;
		hf_tail = 4'b0;
	end
	else begin
		if (recovery_inflight) begin
			rec_dest_reg_value_o = hf_queue[recovery_index][31:0];
			rec_dest_reg_o = hf_queue[recovery_index][36:32];
			rec_write_en_o = (hf_queue[recovery_index][134]) ? 1'b1 : 1'b0;
			stall_decode_o = 1'b1;
			if (recovery_index != hf_head) begin
				if (recovery_index > 4'b0000) recovery_index = recovery_index - 1;
				else recovery_index = 4'b1111;	
			end
			else begin
				recovery_inflight = 1'b0;
				hf_tail = hf_head;
				exc_mtval_o = hf_queue[recovery_index][100:69];
				exc_mepc_o = hf_queue[recovery_index][68:37];
				exc_mcause_o = hf_queue[recovery_index][132:101];
				exc_occured_o = 1'b1;
			end
		end
		else begin
			if (!stall_decode_i && !dec_null_val) begin
				hf_queue[hf_tail] = {dec_int_write_enable_i, 1'b0, 32'b0, 32'b0, dec_pc_i, dec_dest_reg_i, dec_dest_reg_value_i};
				if (hf_tail < 4'b1111) hf_tail = hf_tail + 1;
				else hf_tail = 4'b0;
				hf_queue[hf_tail] = 135'b0;
            		end
			for (i=0; i<16; i = i + 1) begin
				if (hf_queue[i][68:37] == wb_pc_i && !hf_queue[i][133]) begin
					hf_index = i;	
					hf_index[4] = 1'b0;
				end
			end
			if (!hf_index[4]) begin 
				hf_queue[hf_index[3:0]][133] = 1'b1;
				hf_queue[hf_index[3:0]][132:101] = wb_exc_i;
				hf_queue[hf_index[3:0]][100:69] = wb_miss_addr_i;
				if (hf_index[3:0] == hf_head) begin
					if (|wb_exc_i) begin // Exc occured with this instruction (head)
						stall_decode_o = 1'b1;
						kill_instr_o = 1'b1;
						kill_pc_o = hf_queue[hf_head][68:37];
						//recovery_index = (hf_tail==4'b0000) ? 4'b1111 : hf_tail-1;
						recovery_index = hf_tail;
						recovery_inflight = 1'b1;
					end
					else begin // No exception occured for head, iterate until all newer insts are dequeued or exception found
						if (hf_head < 4'b1111) hf_head = hf_head + 1;
						else hf_head = 4'b0;
						while(hf_queue[hf_head][133] && !recovery_inflight && hf_head!=hf_tail) begin
							if (|hf_queue[hf_head][132:101]) begin // Exc occured with this instruction (head)
									stall_decode_o = 1'b1;
									kill_instr_o = 1'b1;
									kill_pc_o = hf_queue[hf_head][68:37];
									//recovery_index = (hf_tail==4'b0000) ? 4'b1111 : hf_tail-1;
									recovery_index = hf_tail;
									recovery_inflight = 1'b1;
							end
							else begin
								if (hf_head < 4'b1111) hf_head = hf_head + 1;
								else hf_head = 4'b0;
							end
						end
					end
				end
			end
		end
	end
end

endmodule
