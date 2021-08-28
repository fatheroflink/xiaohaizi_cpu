`include "defines.h"

/**
顶层模块
*/
module my_cpu_5
    (
        input 			key0,				//FPGA开发板上RESET键，默认为逻辑1
        input 			key1,				//FPGA开发板上KEY1键，默认为逻辑1
        input 			key2,				//FPGA开发板上KEY2键，默认为逻辑1
        input 			key3,				//FPGA开发板上KEY3键，默认为逻辑1
        input 			clk,				//FPGA开发板上50M时钟信号
        input  [3:0]	key_in_y,		    //用于外接矩阵键盘
        output [3:0]	key_out_x,		    //用于外接矩阵键盘
        output [3:0] 	led,			    //FPGA开发板上LED3~LED0
        output [5:0]   seg_sel,			    //用于6位数码管显示
        output [7:0]	seg_data,		    //用于6位数码管显示
        output [15:0]	led_out			    //外接16个LED灯
    );

    //矩阵键盘的16个按键
    wire [16:1] keys;
    key_converter u_key_converter(
        .clk(clk),
        .rst_n(key0),
        .key_in_y(key_in_y),
        .key_out_x(key_out_x),
        .keys(keys)
    );

    //LED显示屏
    wire [`WORDSIZE - 1 : 0] digit_in;
    digits_show u_digits_show(
        .in(digit_in),
        .clk(clk),
        .seg_sel(seg_sel),
        .seg_data(seg_data)
    );

    //用~key1作为时钟，方便观察
    wire clock;
    assign clock = ~key1;

    //用~key0作为复位信号，方便操作
    wire rst;
    assign rst = ~key0;


    wire [`WORDSIZE-1:0] cpu_data_i;
    wire cpu_we_o;
    wire [`ADDRSIZE-1:0] cpu_addr_o;
    wire [`WORDSIZE-1:0] cpu_data_o;
    wire cpu_hello_o;
    wire cpu_ack_i;

    //总线支持1主4从，将2个内存控制器mc0和mc1作为从设备连接到总线
    wire [`WORDSIZE-1:0] mc_data_i;
    wire mc_we_i;
    wire [`ADDRSIZE-1:0] mc_addr_i;

    wire [`WORDSIZE-1:0] mc0_data_o;
    wire mc0_hello_i;
    wire mc0_ack_o;

    wire [`WORDSIZE-1:0] mc1_data_o;
    wire mc1_hello_i;
    wire mc1_ack_o;

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

    bus bus_u(
        .m_data_i(cpu_data_o),
        .m_addr_i(cpu_addr_o),
        .m_we_i(cpu_we_o),
        .m_hello_i(cpu_hello_o),
        .m_data_o(cpu_data_i),
        .m_ack_o(cpu_ack_i),

        .s_data_o(mc_data_i),
        .s_addr_o(mc_addr_i),
        .s_we_o(mc_we_i),

        .s0_data_i(mc0_data_o),
        .s0_ack_i(mc0_ack_o),
        .s0_hello_o(mc0_hello_i),

        .s1_data_i(mc1_data_o),
        .s1_ack_i(mc1_ack_o),
        .s1_hello_o(mc1_hello_i)
    );



    mem_controller mc0(
        .mc_clk_i(clock),
        .mc_rst_i(rst),
        .mc_data_i(mc_data_i),
        .mc_addr_i(mc_addr_i),
        .mc_we_i(mc_we_i),
        .mc_data_o(mc0_data_o),
        .mc_hello_i(mc0_hello_i),
        .mc_ack_o(mc0_ack_o)
    );

    mem_controller mc1(
        .mc_clk_i(clock),
        .mc_rst_i(rst),
        .mc_data_i(mc_data_i),
        .mc_addr_i(mc_addr_i),
        .mc_we_i(mc_we_i),
        .mc_data_o(mc1_data_o),
        .mc_hello_i(mc1_hello_i),
        .mc_ack_o(mc1_ack_o)
    );

    //LED显示屏中展示CPU的数据输出
    assign digit_in = cpu_data_o;

    assign led[0] = key0;
    assign led[1] = key1;
    assign led[2] = ~key0;
    assign led[3] = ~key1;
endmodule