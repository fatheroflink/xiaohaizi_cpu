`include "defines.h"

module ctrl_unit(
    input clk,                          //时钟信号
    input rst,                          //复位信号
    input [`OPCODESIZE-1:0] opcode,     //操作码
    input zf,                           //ALU结果是否为0
    output reg pc_sel,                  //PC的选择信号
    output reg pc_we,                   //PC的写使能信号
    output ram_addr_sel,                //RAM地址的选择信号
    output ram_we,                      //RAM的写使能信号
    output reg ir_we,                   //IR的写使能信号
    output reg zf_we,                   //ZF寄存器的写使能信号
    output reg [`ALUOPSIZE-1:0] alu_op, //ALU做何运算的控制信号
    output reg alu_a_sel,               //ALU的输入A的选择信号
    output reg alu_b_sel,               //ALU的输入B的选择信号
    output reg acc_we,                  //累加器的写使能信号
    output reg halt,                    //停止执行信号

    input ack,                          //数据是否已返回
    output reg hello,                   //是否要发起读/写操作

    output reg int_ins, //中断指令
    output reg not_exists_ins   //未知指令
);
    reg state;  //CPU状态寄存器

    /**内部信号*/
    reg access_ram_ins;
    reg acc_we_tmp;
    reg ram_we_tmp;

    //CPU状态寄存器的状态机
    always @(posedge clk or posedge rst) begin
        if (rst == 1)
            state <= `CPU_STATE_FETCH;
        else begin
            case (state)
                `CPU_STATE_FETCH: begin
                    if (ack == 1)
                        state <= `CPU_STATE_EXECUTE;
                end
                `CPU_STATE_EXECUTE: begin
                    if (access_ram_ins == 0) begin
                        state <= `CPU_STATE_FETCH;
                    end else begin
                        if (ack == 1) begin
                            state <= `CPU_STATE_FETCH;
                        end
                    end

                end
            endcase
        end
    end

    // assign pc_we = state;
    // assign ir_we = ~state;
    assign ram_addr_sel = state;
    // assign zf_we = state;

    //根据CPU状态，生成各种WE信号
    always @(*) begin
        ir_we = ~state;
        pc_we = state;
        zf_we = state;
        acc_we = state == 1 ? acc_we_tmp: 0;
        if (state == `CPU_STATE_FETCH && ack == 0)
            ir_we = 0;
        if (state == `CPU_STATE_EXECUTE && access_ram_ins == 1 && ack == 0) begin
            pc_we = 0;
            zf_we = 0;
            acc_we = 0;
        end
    end

    //根据CPU状态，生成hello信号
    always @(*) begin
        hello = 0;
        case (state)
            `CPU_STATE_FETCH: begin
                hello = 1;
            end
            `CPU_STATE_EXECUTE:begin
                if (access_ram_ins == 1)
                    hello = 1;
            end
        endcase

    end

    //指令解码器
    always @(*) begin
        pc_sel = 0;
        // pc_we = 0;
        // ram_addr_sel = 0;
        ram_we_tmp = 0;
        // ir_we = 0;
        // zf_we = 0;
        alu_op = 0;
        alu_a_sel = 0;
        alu_b_sel = 0;
        acc_we_tmp = 0;
        halt = 0;
        access_ram_ins = 0;
        int_ins = 0;
        not_exists_ins = 0;

        case (opcode)

            `ISA_ADD_M: begin
                acc_we_tmp = 1;
                alu_b_sel = 1;
                alu_op = `ALU_OP_ADD;
                access_ram_ins = 1;
            end
            `ISA_SUB_M: begin
                acc_we_tmp = 1;
                alu_b_sel = 1;
                alu_op = `ALU_OP_SUB;
                access_ram_ins = 1;
        end
            `ISA_AND_M: begin
                acc_we_tmp = 1;
                alu_b_sel = 1;
                alu_op = `ALU_OP_AND;
                access_ram_ins = 1;
            end
            `ISA_OR_M: begin
                acc_we_tmp = 1;
                alu_b_sel = 1;
                alu_op = `ALU_OP_OR;
                access_ram_ins = 1;
            end
            `ISA_HALT: begin
                halt = 1;
            end
            `ISA_STORE: begin
                ram_we_tmp = 1;
                access_ram_ins = 1;
            end
            `ISA_LOAD_M: begin
                acc_we_tmp = 1;
                alu_a_sel = 1;
                alu_b_sel = 1;
                alu_op = `ALU_OP_ADD;
                access_ram_ins = 1;
            end
            `ISA_JMP: begin
                pc_sel = 1;
                access_ram_ins = 1;
            end
            `ISA_JE: begin
                pc_sel = zf == 1 ? 1 : 0;
                access_ram_ins = 1;
            end
            `ISA_ADD_I: begin
                acc_we_tmp = 1;
                alu_op = `ALU_OP_ADD;
            end
            `ISA_SUB_I: begin
                acc_we_tmp = 1;
                alu_op = `ALU_OP_SUB;
            end
            `ISA_AND_I: begin
                acc_we_tmp = 1;
                alu_op = `ALU_OP_AND;
            end
            `ISA_OR_I: begin
                acc_we_tmp = 1;
                alu_op = `ALU_OP_OR;
            end
            `ISA_LOAD_I: begin
                acc_we_tmp = 1;
                alu_a_sel = 1;
                alu_op = `ALU_OP_ADD;
            end
            `ISA_INT: begin
                int_ins = 1;
            end
            defalut: begin
                not_exists_ins = 1;
            end

        endcase
    end

    assign ram_we = state == 1 ? ram_we_tmp: 0;

endmodule