`include "defines.h"

module regfile(
    input clk,
    input we,
    input rst,
    input [`ADDRSIZE-1:0] addr,
    input [`WORDSIZE-1:0] d_in,
    output [`WORDSIZE-1:0] d_out

);

//    reg [15:0]     regs[64];
    reg [`WORDSIZE-1:0]     regs[`RAMSIZE-1:0];
    integer i;

    assign d_out = regs[addr];

    always @(posedge clk or posedge rst) begin
        if (rst == 1) begin
				regs[0] <= `WORDSIZE'h0905;

            regs[1] <= `WORDSIZE'h0906;

            regs[2] <= `WORDSIZE'h0907;

            regs[3] <= `WORDSIZE'h0908;
            regs[4] <= `WORDSIZE'h0400;
            // for (i = 0; i < s`RAMSIZE; i = i + 1) begin
            //     regs[i]	<= `WORD_DATA_W'h0;
            // end
        end else begin
            if (we == 1) begin
                regs[addr] <= d_in;
            end
        end
    end

endmodule