// History file

module history_file (
input clk_i,
input rsn_i,
input stall_decode_i,
input [4:0] dec_dest_reg_i,
input [31:0] miss_addr_i,
input [31:0] dec_pc_i,
input [31:0] dec_dest_reg_value_i,
input [4:0] wb_dest_reg_i,
input [x:0] wb_exc_i,
output reg stall_decode_o,
output reg kill_instr_o);
  
reg [X:0] hf_queue [15:0]; // {Exceptions bits, @miss, PC, dec_dest_reg, dec_dest_reg_value}
reg [3:0] hf_head;
reg [3:0] hf_tail;
  
always @ (posedge clk_i) begin
	if (!stall_decode_i) begin
		hf_queue[hf_tail] = {dec_dest_reg_i, ...};
		if (hf_tail < 4'b1111) hf_tail = hf_tail + 1;
		else hf_tail = 4'b0;
	end
	if (WB_INST_FINISHING) begin
/*	Si té excepcions
 Bloquejar Decode
 Matar instruccions en vol
 Copiar en ordre invers (de TAIL a HEAD)
 El <Value,Dest> guardat al History Buffer al Banc de Registres
 Garanteix que els registres amb WAW recuperen el Value
correcte

 El PC “precís” està a HF[head].pc i el copiem a rm0
 L’@ de miss està a HF[head].@ i la copiem a rm1*/
		if (|wb_exc) begin
			stall_decode_o = 1'b1;
			kill_instr_o = 1'b1;
		end
		else begin 
			if (hf_head < 4'b1111) hf_head = hf_head + 1;
			else hf_head = 4'b0;			
		end
	end
end
