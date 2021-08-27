`include "defines.h"

module ctrl_unit(
    input clk,
    input rst,
    input [`OPCODESIZE-1:0] opcode,
    input zf,
    output reg pc_sel,
    output reg pc_we,
    output ram_addr_sel,
    output ram_we,
    output reg ir_we,
    output reg zf_we,
    output reg [`ALUOPSIZE-1:0] alu_op,
    output reg alu_a_sel,
    output reg alu_b_sel,
    output reg acc_we,
    output reg halt,

    input ack,
    output reg hello,

    output reg int_ins, //中断指令
    output reg not_exists_ins   //未知指令
);
    reg state;

    /**内部信号*/
    reg access_ram_ins;
    reg acc_we_tmp;
    reg ram_we_tmp;

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
    // assign acc_we = state == 1 ? acc_we_tmp: 0;

endmodule