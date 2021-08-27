`include "defines.h"

module bus(
    input clk,
    input rst,

    /**主设备信号*/
    input [`WORDSIZE-1:0] m_data_i,
    input [`ADDRSIZE-1:0] m_addr_i,
    input m_we_i,
    input m_hello_i,
    output reg [`WORDSIZE-1:0] m_data_o,
    output reg m_ack_o,

    /**从设备信号，共4个从设备*/

    /**从设备共用信号*/
    output [`WORDSIZE-1:0] s_data_o,
    output reg [`ADDRSIZE-1:0] s_addr_o,
    output [`WORDSIZE-1:0] s_we_o,

    input s0_ack_i,
    input s1_ack_i,
    input s2_ack_i,
    input s3_ack_i,

    input [`WORDSIZE-1:0] s0_data_i,
    input [`WORDSIZE-1:0] s1_data_i,
    input [`WORDSIZE-1:0] s2_data_i,
    input [`WORDSIZE-1:0] s3_data_i,


    output reg s0_hello_o,
    output reg s1_hello_o,
    output reg s2_hello_o,
    output reg s3_hello_o

);

    always @(*) begin
        s0_hello_o = 0;
        s1_hello_o = 0;
        s2_hello_o = 0;
        s3_hello_o = 0;

        m_ack_o = 0;
        if (m_addr_i < `S0_ADDR_MAX) begin              //第0号从设备地址
            s_addr_o = m_addr_i;
            s0_hello_o = m_hello_i;
            m_data_o = s0_data_i;
            m_ack_o = s0_ack_i;
        end else if (m_addr_i < `S1_ADDR_MAX) begin     //第1号从设备地址
            s_addr_o = m_addr_i - `S0_ADDR_MAX;
            s1_hello_o = m_hello_i;
            m_data_o = s1_data_i;
            m_ack_o = s1_ack_i;
        end else if (m_addr_i < `S2_ADDR_MAX) begin     //第2号从设备地址
            s_addr_o = m_addr_i - `S1_ADDR_MAX;
            s2_hello_o = m_hello_i;
            m_data_o = s2_data_i;
            m_ack_o = s2_ack_i;
        end else if (m_addr_i < `S3_ADDR_MAX) begin     //第3号从设备地址
            s_addr_o = m_addr_i - `S2_ADDR_MAX;
            s3_hello_o = m_hello_i;
            m_data_o = s3_data_i;
            m_ack_o = s3_ack_i;
        end
    end

    assign s_data_o = m_data_i;
    assign s_we_o = m_we_i;



endmodule