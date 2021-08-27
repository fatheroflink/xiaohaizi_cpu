/**
*	将一个二进制数转换为6位BCD码
*/

`include "defines.h"

module adder3(x, y);
input [3 : 0] x;
output reg [3 : 0] y;

always @ (x) begin
    case (x) 
        4'b0000 : y <= 4'b0000;
        4'b0001 : y <= 4'b0001;
        4'b0010 : y <= 4'b0010;
        4'b0011 : y <= 4'b0011;
        4'b0100 : y <= 4'b0100;
        4'b0101 : y <= 4'b1000;
        4'b0110 : y <= 4'b1001;
        4'b0111 : y <= 4'b1010;
        4'b1000 : y <= 4'b1011;
        4'b1001 : y <= 4'b1100;
        default : y <= 4'b0000;
    endcase
end
endmodule

module binary2bcd(
	input  [`WORDSIZE - 1 : 0] in,
	output [3:0] out5,
	output [3:0] out4,
	output [3:0] out3,
	output [3:0] out2,
	output [3:0] out1,
	output [3:0] out0
);

wire [3 : 0] t1, t2, t3, t4, t5, t6, t7;

adder3 add1(
    .x({1'b0, in[7 : 5]}),
    .y(t1[3 : 0])
);
adder3 add2(
    .x({t1[2 : 0], in[4]}),
    .y(t2[3 : 0])
);
adder3 add3(
    .x({t2[2 : 0], in[3]}),
    .y(t3[3 : 0])
);
adder3 add4(
    .x({1'b0, t1[3], t2[3], t3[3]}),
    .y(t4[3 : 0])
);
adder3 add5(
    .x({t3[2 : 0], in[2]}),
    .y(t5[3 : 0])
);
adder3 add6(
    .x({t4[2 : 0], t5[3]}),
    .y(t6[3 : 0])
);
adder3 add7(
    .x({t5[2 : 0], in[1]}),
    .y(t7[3 : 0])
);

assign out5 = 0;
assign out4 = 0;
assign out3 = 0;
assign out2 = {2'b0, t4[3], t6[3]};
assign out1 = {t6[2:0], t7[3]};
assign out0 = {t7[2:0], in[0]};

endmodule

