`include "defines.h"

module my_cpu_4
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

	wire clock;
	assign clock = ~key1;

	wire rst;
	assign rst = ~key0;

	wire [`WORDSIZE-1:0] cpu_data_i;
	wire cpu_we_o;
	wire [`ADDRSIZE-1:0] cpu_addr_o;
	wire [`WORDSIZE-1:0] cpu_data_o;
	wire cpu_hello_o;
	wire cpu_ack_i;

	cpu cpu_u(
		.cpu_clk_i(clock),
		.cpu_rst_i(rst),
		.cpu_data_i(cpu_data_i),
		.cpu_we_o(cpu_we_o),
		.cpu_addr_o(cpu_addr_o),
		.cpu_data_o(cpu_data_o),
		.cpu_hello_o(cpu_hello_o),
		.cpu_ack_i(cpu_ack_i)
	);

	mem_controller mc(
		.mc_clk_i(clock),
		.mc_rst_i(rst),
		.mc_data_i(cpu_data_o),
		.mc_addr_i(cpu_addr_o),
		.mc_we_i(cpu_we_o),
		.mc_data_o(cpu_data_i),
		.mc_hello_i(cpu_hello_o),
		.mc_ack_o(cpu_ack_i)
	);

	assign digit_in = cpu_data_o;
	
	assign led[0] = key0;
	assign led[1] = key1;
	assign led[2] = ~key0;
	assign led[3] = ~key1;
endmodule