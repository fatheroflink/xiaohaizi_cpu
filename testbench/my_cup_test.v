
`timescale 1ns/100ps
`include "../src/defines.h"

module my_cpu_test;

    reg key0;
    reg key1;
    reg key2;
    reg key3;
    reg clk;
    reg  [3:0]	key_in_y;		//用于外接矩阵键盘
    wire [3:0]	key_out_x;		//用于外接矩阵键盘
    wire [3:0] 	led;				//FPGA开发板上LED3~LED0
    wire [5:0]   seg_sel;			//用于6位数码管显示
    wire [7:0]	seg_data;		//用于6位数码管显示
    wire [15:0]	led_out;			//外接16个LED灯

    my_cpu u_mycpu
           (
               key0,				//FPGA开发板上RESET键，默认为逻辑1
               key1,				//FPGA开发板上KEY1键，默认为逻辑1
               key2,				//FPGA开发板上KEY2键，默认为逻辑1
               key3,				//FPGA开发板上KEY3键，默认为逻辑1
               clk,				//FPGA开发板上50M时钟信号
               key_in_y,		//用于外接矩阵键盘
               key_out_x,		//用于外接矩阵键盘
               led,				//FPGA开发板上LED3~LED0
               seg_sel,			//用于6位数码管显示
               seg_data,		//用于6位数码管显示
               led_out			//外接16个LED灯
               //output 			c_out
           );

    integer i;
    initial begin


        key0 = 1;key1 = 1;
        # 100;
        key0 = 0;
		  #100;
		  key0 = 1;
		  #100;
		  key1=0;
        #100;


        for (i = 0; i < 50; i=i+1) begin
            key1 =  ~key1;
            #100;
        end


//	#100;
//	for (i = 0; i < 24; i=i+1) begin
//		key3 =  ~key3;
//		#100;
//	end
//	addr = 0;
//	#100;
//	addr=1;
//	#100;
//	addr=2;
//	#100;
//	addr=3;
//	#100;

    end

endmodule
