`include "defines.h"

module mem_controller(
    /**全局接口*/
    input mc_clk_i,
    input mc_rst_i,

    /**CPU接口*/
    input mc_hello_i,
    input [`WORDSIZE-1:0] mc_data_i,
    input mc_we_i,
    input [`ADDRSIZE-1:0] mc_addr_i,
    output [`WORDSIZE-1:0] mc_data_o,
    output reg mc_ack_o

    /**RAM接口接口, 略，集成在内存控制器中*/
);

    reg[1:0] state;

    reg [`ADDRSIZE-1:0] addr;
    reg [`WORDSIZE-1:0] d_in;
    reg we;

    always@(posedge mc_clk_i or posedge mc_rst_i) begin
        if (mc_rst_i == 1) begin
            state <= `MEM_CTRL_STATE_IDEL;
            we <= 0;
        end else begin
            case (state)
                `MEM_CTRL_STATE_IDEL: begin
                    if (mc_hello_i == 1) begin
                        state <= `MEM_CTRL_STATE_ACCESS;
                        we <= mc_we_i;
                    end
                end
                `MEM_CTRL_STATE_ACCESS: begin
                    if (we == 0) begin
                        state <= `MEM_CTRL_STATE_DONE;
                    end else begin
                        state <= `MEM_CTRL_STATE_IDEL;
                    end
                end
                `MEM_CTRL_STATE_DONE: begin
                    state <= `MEM_CTRL_STATE_IDEL;
                end
            endcase
        end
    end

    always @(*) begin
        mc_ack_o = 0;
        case (state)
            `MEM_CTRL_STATE_ACCESS: begin
                if (we == 1)
                    mc_ack_o = 1;
            end
            `MEM_CTRL_STATE_DONE: begin
                mc_ack_o = 1;
            end
        endcase
    end

	altera_ram ram(
        .address(mc_addr_i),
        .clock(mc_clk_i),
        .data(mc_data_i),
        .wren(state == `MEM_CTRL_STATE_IDEL && mc_hello_i == 1 ? mc_we_i : 0),
        .q(mc_data_o)
    );


endmodule