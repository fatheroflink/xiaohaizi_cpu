`include "defines.h"

module my_cpu
(
	input 			key0,				//FPGA开发板上RESET键，默认为逻辑1
	input 			key1,				//FPGA开发板上KEY1键，默认为逻辑1
	input 			key2,				//FPGA开发板上KEY2键，默认为逻辑1
	input 			key3,				//FPGA开发板上KEY3键，默认为逻辑1
	input 			clk,				//FPGA开发板上50M时钟信号
	input  [3:0]	key_in_y,		//用于外接矩阵键盘
	output [3:0]	key_out_x,		//用于外接矩阵键盘
	output [3:0] 	led,				//FPGA开发板上LED3~LED0
	output [5:0]   seg_sel,			//用于6位数码管显示
   output [7:0]	seg_data,		//用于6位数码管显示
	output [15:0]	led_out			//外接16个LED灯
	//output 			c_out


);

	wire [16:1] keys;	//矩阵键盘的16个按键
	key_converter u_key_converter(
		.clk(clk),
		.rst_n(key0),
		.key_in_y(key_in_y),
		.key_out_x(key_out_x),
		.keys(keys)
	);

	wire [`WORDSIZE - 1 : 0] digit_in;
	digits_show u_digits_show(
		.in(digit_in),
		.clk(clk),
		.seg_sel(seg_sel),
		.seg_data(seg_data)
	);


	wire rst;
	assign rst = ~key0;

	wire halt;
	wire pc_sel;
	wire pc_we;
	wire ram_addr_sel;
	wire ram_we;
	wire ir_we;
	wire zf_we;
	wire [`ALUOPSIZE-1:0] alu_op;
	wire alu_a_sel;
	wire alu_b_sel;
	wire acc_we;

	wire clock;
	assign clock = halt == 1 ? 0 :~key1;

	reg[`ADDRSIZE-1:0] pc;

	wire [`ADDRSIZE-1:0] jmp_addr;

	always @(posedge clock or posedge rst) begin
		if (rst == 1) begin
			pc <= 0;
		end else begin
			if (pc_we == 1) begin
				if (pc_sel == 0)
					pc <= pc + 1;
				else
					pc <= jmp_addr;
			end
		end
	end

	wire [`ADDRSIZE-1:0] operand_addr;
	wire [`ADDRSIZE-1:0] addr;
	assign addr = ram_addr_sel == 0 ? pc : operand_addr;

	reg [`WORDSIZE-1:0] acc;

	wire [`WORDSIZE-1:0] ram_out;
	regfile ram(
		.clk(clock),
		.we(ram_we),
		.rst(rst),
		.addr(addr),
		.d_in(acc),
		.d_out(ram_out)
	);

	assign jmp_addr = ram_out[`ADDRSIZE-1:0];

	wire [`WORDSIZE-1:0] alu_b_value;
	assign alu_b_value = ram_out;

	reg [`WORDSIZE-1:0] ir;

	always @(posedge clock or posedge rst) begin
		if (rst == 1)
			ir <= 0;
		else begin
			if (ir_we == 1)
				ir <= ram_out;
		end
	end

	wire [`OPCODE_RANGE] opcode;
	wire [`IMMSIZE-1:0] operand_imm;

	assign opcode = ir[`OPCODE_RANGE];
	assign operand_addr = ir[`ADDRSIZE-1:0];
	assign operand_imm = ir[`IMMSIZE-1:0];

	wire [`WORDSIZE-1:0] sign_extented_operand_imm;
	assign sign_extented_operand_imm = {{`IMMEXTSIZE{operand_imm[`IMMSIZE-1]}}, operand_imm};

	reg zf;
	wire [`WORDSIZE-1:0] alu_a;
	wire [`WORDSIZE-1:0] alu_b;
	wire [`WORDSIZE-1:0] alu_result;
	wire alu_zf;

	always @(posedge clock or posedge rst) begin
		if (rst == 1)
			acc <= 0;
		else begin
			if (acc_we == 1)
				acc <= alu_result;
		end
	end

	assign alu_a = alu_a_sel == 0 ? acc:0;
	assign alu_b = alu_b_sel == 0 ? sign_extented_operand_imm : alu_b_value;

	alu alu(
		.alu_a(alu_a),
		.alu_b(alu_b),
		.alu_op(alu_op),
		.alu_result(alu_result),
		.zero_flag(alu_zf)
	);

	always @(posedge clock or posedge rst) begin
		if (rst == 1)
			zf <= 0;
		else begin
			if (zf_we == 1)
				zf <= alu_zf;
		end
	end

	ctrl_unit ctrl_unit(
		.clk(clock),
		.rst(rst),
		.opcode(opcode),
		.zf(alu_zf),
		.pc_sel(pc_sel),
		.pc_we(pc_we),
		.ram_addr_sel(ram_addr_sel),
		.ram_we(ram_we),
		.ir_we(ir_we),
		.zf_we(zf_we),
		.alu_op(alu_op),
		.alu_a_sel(alu_a_sel),
		.alu_b_sel(alu_b_sel),
		.acc_we(acc_we),
		.halt(halt)
	);
	
	assign digit_in = alu_result;
	
	assign led[0] = key0;
	assign led[1] = key1;
	assign led[2] = ~key0;
	assign led[3] = ~key1;
endmodule