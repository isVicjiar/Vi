// Main module of the project

module vi_core (
input		clock,
input		reset);

// Stage instruction
wire [31:0] fetch_instruction;
wire [31:0] dec_instruction;
wire [31:0] reg_instruction;
wire [31:0] alu_instruction;
wire [31:0] wb_instruction;

// Decode - Latch = DL
wire [4:0] dl_read_addr_a;
wire [4:0] dl_read_addr_b;

// Latch - Reg = LR
wire [4:0] lr_read_addr_a;
wire [4:0] lr_read_addr_b;

// Reg - Latch = RL
wire [63:0] rl_int_data_a;
wire [63:0] rl_int_data_b;
wire [31:0] rl_fp_data_a;
wire [31:0] rl_fp_data_b;

// Latch - Alu = LA
wire [63:0] la_int_data_a;
wire [63:0] la_int_data_b;
wire [31:0] la_fp_data_a;
wire [31:0] la_fp_data_b;

int_registers int_registers(
	.clock		(clock),
	.reset		(reset),
	.write_data	(),
	.read_addr_a	(lr_read_addr_a),
	.read_addr_b	(lr_read_addr_b),
	.write_addr	(),
	.write_enable	(),
	.read_data_a	(rl_int_data_a),
	.read_data_b	(rl_int_data_b)
);

fp_registers fp_registers(
	.clock		(clock),
	.reset		(reset),
	.write_data	(),
	.read_addr_a	(lr_read_addr_a),
	.read_addr_b	(lr_read_addr_b),
	.write_addr	(),
	.write_enable	(),
	.read_data_a	(rl_fp_data_a),
	.read_data_b	(rl_fp_data_b)
);

reg_alu_latch reg_alu_latch(
	.clock		(clock),
	.reset		(reset),
	.reg_int_data_a	(rl_int_data_a),
	.reg_int_data_b	(rl_int_data_b),
	.reg_fp_data_a	(rl_fp_data_a),
	.reg_fp_data_b	(rl_fp_data_b),
	.reg_instruction	(reg_instruction),
	.alu_int_data_a	(la_int_data_a),
	.alu_int_data_b	(la_int_data_b),
	.alu_fp_data_a	(la_fp_data_a),
	.alu_fp_data_b	(la_fp_data_b),
	.alu_instruction 	(alu_instruction)
);

alu alu(
	.clock		(clock),
	.reset		(reset),
	.instruction	(alu_instruction),
	.data_a		(la_int_data_a),
	.data_b		(la_int_data_b),
	.data_out	()
);

fp_alu fp_alu(
	.clock		(clock),
	.reset		(reset),
	.instruction	(alu_instruction),
	.data_a		(la_fp_data_a),
	.data_b		(la_fp_data_b),
	.data_out	()
);
