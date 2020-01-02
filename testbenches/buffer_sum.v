module buffer_sum;

reg clk;
reg rsn;

reg [127:0] memory [25'hFFFF:0];
reg tmp_mem_data_ready;
reg [127:0] tmp_mem_data;
reg [19:0] tmp_mem_addr;

wire mem_data_ready;
wire [127:0] mem_data;
wire [19:0] mem_addr;
wire mem_read;
wire [19:0] mem_read_addr;
wire mem_write_enable;
wire [19:0] mem_write_addr;
wire [31:0] mem_write_data;
wire mem_write_byte;

assign mem_data_ready = tmp_mem_data_ready;
assign mem_data = tmp_mem_data;
assign mem_addr = tmp_mem_addr;

vi_core vi_core(
	.clk_i	(clk),
	.rsn_i	(rsn),
	.mem_data_ready_i (mem_data_ready),
	.mem_data_i	  (mem_data),
	.mem_addr_i	  (mem_addr),
	.mem_read_o	  (mem_read),
	.mem_read_addr_o  (mem_read_addr),
	.mem_write_enable_o	(mem_write_enable),
	.mem_write_byte_o	(mem_write_byte),
	.mem_write_addr_o	(mem_write_addr),
	.mem_write_data_o	(mem_write_data)
);

always begin
	#5 clk = !clk;	
end

initial begin
	rsn = 1'b0;
	clk = 1'b1;
	#20
	tmp_mem_data = 128'b0;
	tmp_mem_addr = 20'b0;
	tmp_mem_data_ready = 1'b0;
	// 1000 8-bit element /  
	
	// 0001001 rs2 rs1 000 00000 1110011 (itlbwrite invented as sfence.vma)
	// 0001001 rs2 rs1 001 00000 1110011 (dtlbwrite invented as sfence.vma)
	//itlbwrite x1,x2
	//0001 0010 0010 0000 1000 0000 0111 0011
	//12208073
	//dtlbwrite x1,x2
	//0001 0010 0010 0000 1001 0000 0111 0011
	//12209073

	// Initialize memory with os at 0x1000	// 0001 0000 0000 |0000 000	
	memory[25'h100] = {32'h00311133, 32'h00F00193, 32'h00108113, 32'h001000B3};
	memory[25'h101] = {32'h00000000, 32'h00000000, 32'h30200073, 32'h12208073};
	// Initialize exc handler at 0x2000	// 0010 0000 0|000 0000
	memory[25'h200] = {32'h00000f33, 32'h01ef9fb3, 32'h00b00f13, 32'h00100f93};
	memory[25'h201] = {32'h004fa623, 32'h003fa423, 32'h002fa223, 32'h001fa023};
	memory[25'h202] = {32'h008fae23, 32'h007fac23, 32'h006faa23, 32'h005fa823};
	memory[25'h203] = {32'h00100113, 32'h342020f3, 32'h02afa223, 32'h029fa023};
	memory[25'h204] = {32'h003112b3, 32'h00400193, 32'h00311233, 32'h00200193};
	memory[25'h205] = {32'h003113b3, 32'h00c00193, 32'h00311333, 32'h00600193};
	memory[25'h206] = {32'h003114b3, 32'h00f00193, 32'h00311433, 32'h00d00193};
	memory[25'h207] = {32'h02608c63, 32'h02508863, 32'h02408463, 32'h02208063};
	memory[25'h208] = {32'h0a0000ef, 32'h08908063, 32'h06808063, 32'h04708063};
	memory[25'h209] = {32'h0aa00f13, 32'h094000ef, 32'h00000f93, 32'h0aa00f13};
	memory[25'h20a] = {32'h00400f93, 32'h0aa00f13, 32'h088000ef, 32'h00200f93};
	memory[25'h20b] = {32'h070000ef, 32'h00600f93, 32'h0aa00f13, 32'h07c000ef};
	memory[25'h20c] = {32'h00311133, 32'h00f00193, 32'h00100113, 32'h341020f3};
	memory[25'h20d] = {32'h00c00f93, 32'h0aa00f13, 32'h12208073, 32'h00208133};
	memory[25'h20e] = {32'h01000193, 32'h00100113, 32'h341020f3, 32'h04c000ef};
	memory[25'h20f] = {32'h0aa00f13, 32'h12209073, 32'h00208133, 32'h00311133};
	memory[25'h210] = {32'h00100113, 32'h341020f3, 32'h028000ef, 32'h00d00f93};
	memory[25'h211] = {32'h12209073, 32'h00208133, 32'h00311133, 32'h01000193};
	memory[25'h212] = {32'h00100513, 32'h004000ef, 32'h00f00f93, 32'h0aa00f13};
	memory[25'h213] = {32'h00452103, 32'h00052083, 32'h00951533, 32'h00b00493};
	memory[25'h214] = {32'h01452303, 32'h01052283, 32'h00c52203, 32'h00852183};
	memory[25'h215] = {32'h02452503, 32'h02052483, 32'h01c52403, 32'h01852383};
	memory[25'h216] = {32'h00000000, 32'h00000000, 32'h00000000, 32'h30200073};
	// Initialize USER CODE at 0x8000 // 1000 0000 0000 |0000 000
	// x1 i
	// x2 max 128
	// x3 sum val
	// x4 a addr
	// x5 sum addr
	// x6 temp
	//0  0000 0000 0000 0000 0000 0000 1001 0011 |addi x1 x0 0
	//4  0000 1000 0000 0000 0000 0001 0001 0011 |addi x2 x0 128
    //8  0010 0000 0000 0000 0000 0010 0001 0011 |addi x4 x0 0x200
    //c  0000 0000 0100 0000 0000 0011 0001 0011 |addi x6 x0 0x4
	//
	//10 0000 0000 0110 0010 0001 0010 0011 0011 |sll x4 x4 x6
    //14 0010 0000 0000 0010 0000 0010 1001 0011 |addi x5 x4 128*4
    //18 0000 0000 0000 0010 1000 0001 1000 0011 |ldw x3, 0(x5)
    //1c 0000 0000 0010 0000 1000 1100 0110 0011 |beq x1 x2 24
    //
    //20 0000 0000 0000 0010 0000 0011 0000 0011 |ldw x6, 0(x4)
    //24 0000 0000 0110 0001 1000 0001 1011 0011 |add x3 x3 x6
    //28 0000 0000 0100 0010 0000 0010 0001 0011 |addi x4 x4 4
    //2c 0000 0000 0001 0000 1000 0000 1001 0011 |addi x1 x1 1
    //
    //30 1111 1110 0000 0000 0000 0110 1110 0011 |beq x0 x0 -20
    //34 0000 0000 0011 0010 1000 0000 0010 0011 |sw x3 0(x5)
	//38 0000 0000 0000 0000 1000 0000 1001 0011 |addi x1 x1 0             
	//3c 1111 1110 0000 0000 0000 1110 1110 0011 |beq x0 x0 -4
	memory[25'h800] = {32'h00400313, 32'h20000213, 32'h08000113, 32'h00000093};
	memory[25'h801] = {32'h00208c63, 32'h00028183, 32'h20020293, 32'h00621233};
	memory[25'h802] = {32'h00108093, 32'h00420213, 32'h006181b3, 32'h00020303};
	memory[25'h803] = {32'hfe000ee3, 32'h00008093, 32'h00328023, 32'hfe0006e3};
	memory[25'h804] = {32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000};
	//
	// Initialize USER DATA at 0x12000 //0001 0010 0000 0000 |0000 000
	memory[25'h1200] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1201] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1202] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1203] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1204] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1205] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1206] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1207] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1208] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1209] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h120a] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h120b] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h120c] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h120d] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h120e] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h120f] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1210] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1211] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1212] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1213] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1214] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1215] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1216] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1217] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h1218] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h1219] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h121a] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h121b] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h121c] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h121d] = {32'd8,32'd2,32'd1,32'd3};
	memory[25'h121e] = {32'd6,32'd3,32'd5,32'd4};
	memory[25'h121f] = {32'd8,32'd2,32'd1,32'd3};

	memory[25'h1220] = {32'd0};
	rsn = 1'b1;
end

always @ (posedge clk) begin
	if (mem_read) begin
		tmp_mem_data = memory[mem_read_addr[19:4]];
		tmp_mem_addr = mem_read_addr;
		tmp_mem_data_ready = 1'b1;
	end
	else tmp_mem_data_ready = 1'b0;
	if (mem_write_enable) begin
        if(mem_write_byte) begin
            memory[mem_write_addr[19:4]][mem_write_addr[3:0]*8 +: 8] = mem_write_data[7:0];
        end else begin
            memory[mem_write_addr[19:4]][mem_write_addr[3:2]*32 +: 32] = mem_write_data[31:0];
        end
	end
end

endmodule
