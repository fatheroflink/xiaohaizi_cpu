/**
*	6位数码管显示
*/

`include "defines.h"

module digits_show(
	input  [`WORDSIZE - 1 : 0] in,
	input 							clk,
	output reg [5:0] 					seg_sel,
	output reg [7:0] 					seg_data
);	

wire[3:0] out0, out1, out2, out3, out4, out5;
wire[6:0] seg0, seg1, seg2, seg3, seg4, seg5;

binary2bcd u_binary2bcd(
	.in(in),
	.out0(out0),
	.out1(out1),
	.out2(out2),
	.out3(out3),
	.out4(out4),
	.out5(out5)
);

seg_decoder u_seg_decoder0(
	.bin_data(out0),
	.seg_data(seg0)
);

seg_decoder u_seg_decoder1(
	.bin_data(out1),
	.seg_data(seg1)
);

seg_decoder u_seg_decoder2(
	.bin_data(out2),
	.seg_data(seg2)
);

seg_decoder u_seg_decoder3(
	.bin_data(out3),
	.seg_data(seg3)
);

seg_decoder u_seg_decoder4(
	.bin_data(out4),
	.seg_data(seg4)
);

seg_decoder u_seg_decoder5(
	.bin_data(out5),
	.seg_data(seg5)
);

reg[31:0] counter;
reg[3:0] seg_num;

always@(posedge clk)
begin
		if (counter < 50*1024*1024/25/25)
			counter = counter + 1;
		else 
			begin
				counter <= 0;
				if (seg_num > 5) 
					seg_num <= 0;
				else
					seg_num <= seg_num + 1;
			end
			
end

always@(posedge clk) 
	begin
		case(seg_num)
		
		4'd0:
			begin
				seg_sel = 6'b01_1111;
				seg_data = {1'b1, seg0};
			end
			4'd1:
			begin
				seg_sel <= 6'b10_1111;
				seg_data <= {1'b1, seg1};
			end
			//...
			4'd2:
			begin
				seg_sel <= 6'b11_0111;
				seg_data <= {1'b1, seg2};
			end
			4'd3:
			begin
				seg_sel <= 6'b11_1011;
				seg_data <= {1'b1, seg3};
			end
			4'd4:
			begin
				seg_sel <= 6'b11_1101;
				seg_data <= {1'b1, seg4};
			end
			4'd5:
			begin
				seg_sel <= 6'b11_1110;
				seg_data <= {1'b1, seg5};
			end
			default:
			begin
				seg_sel <= 6'b11_1111;
				seg_data <= 8'hff;
			end
		endcase
	end
endmodule