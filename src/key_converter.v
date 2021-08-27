/**
*	用于将外接矩阵键盘的输入信号转换为16位的keys信号，外接设备自带代码，无需关心
*/

module key_converter(
	input 			clk,              // 开发板上输入时钟: 50Mhz
	input				rst_n,            // 开发板上复位按键
	input	 [3:0]	key_in_y,         // 输入矩阵键盘的列信号(KEY0~KEY3)
	output reg [3:0]	key_out_x,        // 输出矩阵键盘的行信号(KEY4~KEY7)							
	output reg [16:1] 	keys
);

//寄存器定义
reg [19:0] count;

//==============================================
// 输出矩阵键盘的行信号，20ms扫描矩阵键盘一次,采样频率小于按键毛刺频率，相当于滤除掉了高频毛刺信号。
//==============================================
always @(posedge clk or negedge rst_n)     //检测时钟的上升沿和复位的下降沿
begin
   if(!rst_n) begin               //复位信号低有效
      count <= 20'd0;        //计数器清0
      key_out_x <= 4'b1111;  
   end		
   else begin
	       if(count == 20'd0)           //0ms扫描第一行矩阵键盘
            begin
               key_out_x <= 4'b1110;   //开始扫描第一行矩阵键盘,第一行输出0
					count <= count + 20'b1; //计数器加1
            end
         else if(count == 20'd249_999) //5ms扫描第二行矩阵键盘,5ms计数(50M/200-1=249_999)
            begin
               key_out_x <= 4'b1101;   //开始扫描第二行矩阵键盘,第二行输出0
					count <= count + 20'b1; //计数器加1
            end				
			else if(count ==20'd499_999)   //10ms扫描第三行矩阵键盘,10ms计数(50M/100-1=499_999)
            begin
               key_out_x <= 4'b1011;   //扫描第三行矩阵键盘,第三行输出0
					count <= count + 20'b1; //计数器加1
            end	
			else if(count ==20'd749_999)   //15ms扫描第四行矩阵键盘,15ms计数(50M/67.7-1=749_999)
            begin
               key_out_x <= 4'b0111;   //扫描第四行矩阵键盘,第四行输出0
					count <= count + 20'b1; //计数器加1
            end				
         else if(count ==20'd999_999)  //20ms计数(50M/50-1=999_999)
			   begin
               count <= 0;             //计数器为0
            end	
	      else
				count <= count + 20'b1;    //计数器加1
			
     end
end
//====================================================
// 采样列的按键信号
//====================================================
reg [3:0] key_h1_scan;    //第一行按键扫描值KEY
reg [3:0] key_h1_scan_r;  //第一行按键扫描值寄存器KEY
reg [3:0] key_h2_scan;    //第二行按键扫描值KEY
reg [3:0] key_h2_scan_r;  //第二行按键扫描值寄存器KEY
reg [3:0] key_h3_scan;    //第三行按键扫描值KEY
reg [3:0] key_h3_scan_r;  //第三行按键扫描值寄存器KEY
reg [3:0] key_h4_scan;    //第四行按键扫描值KEY
reg [3:0] key_h4_scan_r;  //第四行按键扫描值寄存器KEY
always @(posedge clk)
	begin
		if(!rst_n) begin               //复位信号低有效
			key_h1_scan <= 4'b1111;     
			key_h2_scan <= 4'b1111;          
			key_h3_scan <= 4'b1111;          
			key_h4_scan <= 4'b1111;        
		end		
		else begin
		  if(count == 20'd124_999)           //2.5ms扫描第一行矩阵键盘值
			   key_h1_scan<=key_in_y;         //扫描第一行的矩阵键盘值
		  else if(count == 20'd374_999)      //7.5ms扫描第二行矩阵键盘值
			   key_h2_scan<=key_in_y;         //扫描第二行的矩阵键盘值
		  else if(count == 20'd624_999)      //12.5ms扫描第三行矩阵键盘值
			   key_h3_scan<=key_in_y;         //扫描第三行的矩阵键盘值
		  else if(count == 20'd874_999)      //17.5ms扫描第四行矩阵键盘值
			   key_h4_scan<=key_in_y;         //扫描第四行的矩阵键盘值 
		end
end


always @(posedge clk)
	begin
		if (!rst_n)	
			begin
				keys <= 0;
			end
		else	
			begin
				keys[1] <= ~key_h1_scan[0];
				keys[2] <= ~key_h1_scan[1];
				keys[3] <= ~key_h1_scan[2];
				keys[4] <= ~key_h1_scan[3];
				keys[5] <= ~key_h2_scan[0];
				keys[6] <= ~key_h2_scan[1];
				keys[7] <= ~key_h2_scan[2];
				keys[8] <= ~key_h2_scan[3];
				keys[9] <= ~key_h3_scan[0];
				keys[10] <= ~key_h3_scan[1];
				keys[11] <= ~key_h3_scan[2];
				keys[12] <= ~key_h3_scan[3];
				keys[13] <= ~key_h4_scan[0];
				keys[14] <= ~key_h4_scan[1];
				keys[15] <= ~key_h4_scan[2];
				keys[16] <= ~key_h4_scan[3];
			end
	end
	

endmodule