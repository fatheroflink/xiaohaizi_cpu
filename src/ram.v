`include "defines.h"

module ram(
    input ram_clk_i,
    input ram_rst_i,
    input [`WORDSIZE-1:0] ram_data_i,
    input ram_we_i,
    input [`ADDRSIZE-1:0] ram_addr_i,
    output [`WORDSIZE-1:0] ram_data_o
);
    regfile regfile_0(
        .clk(ram_clk_i),
        .rst(ram_rst_i),
        .addr(ram_addr_i),
        .we(ram_we_i),
        .d_in(ram_data_i),
        .d_out(ram_data_o)
    );

endmodule