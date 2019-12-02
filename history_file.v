// History file

module history_file (
input clk_i,
input rsn_i,
input stall_decode_i,
input [4:0] dec_dest_reg_i,
input [31:0] miss_addr_i,
input [31:0] dec_pc_i,
input [31:0] dec_dest_reg_value_i,
input [31:0] wb_pc_i,
input [4:0] wb_dest_reg_i,
input [x:0] wb_exc_i,
output reg stall_decode_o,
output reg kill_instr_o);
  
reg [X:0] hf_queue [15:0]; // {Finished, Exceptions bits, @miss, PC, dec_dest_reg, dec_dest_reg_value}
reg [3:0] hf_head;
reg [3:0] hf_tail;
reg recovery_inflight;
reg [3:0] recovery_case;
reg [3:0] recovery_index;
  
always @ (posedge clk_i) begin
	reg [4:0] hf_index;
	hf_index = 5'b10000;
	if (!stall_decode_i) begin
		hf_queue[hf_tail] = {dec_dest_reg_i, ...};
		if (hf_tail < 4'b1111) hf_tail = hf_tail + 1;
		else hf_tail = 4'b0;
	end
	if (recovery_inflight) begin
		rec_dest_reg_value_o = hf_queue[recovery_index][31:0];
		rec_dest_reg_o = hf_queue[recovery_index][36:32];
		if (recovery_index < 4'b1111) recovery_index = recovery_index + 1;
		else recovery_index = 4'b0;	
	end
	else begin
		for (int i=0; i<16; i++) begin
			if (hf_queue[i][68:37] == wb_pc_i && !hf_queue[i][X]) begin
				hf_index = i;	
				hf_index[4] = 1'b0;
			end
		end
		if (!hf_index[4]) begin 
			hf_queue[i][X] = 1'b1;	//TODO X is the bit (should be the highest) indicating that has finished
			if (hf_index[3:0] == hf_head) begin
				if (|wb_exc) begin
					stall_decode_o = 1'b1;
					kill_instr_o = 1'b1;
					exc_pc_o = hf_queue[hf_head][68:37];
					exc_miss_addr_o = hf_queue[hf_head][100:69];
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
