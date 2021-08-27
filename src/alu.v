`include "defines.h"

module alu(
    input [`WORDSIZE-1:0] alu_a,
    input [`WORDSIZE-1:0] alu_b,
    input [`ALUOPSIZE-1:0]  alu_op,
    output reg [`WORDSIZE-1:0] alu_result,
    output              zero_flag
);

    always @(*) begin

        case (alu_op)
            `ALU_OP_ADD: begin
                alu_result = alu_a + alu_b;
            end

            `ALU_OP_SUB: begin
                alu_result = alu_a - alu_b;
            end

            `ALU_OP_AND: begin
                alu_result = alu_a & alu_b;
            end

            `ALU_OP_OR: begin
                alu_result = alu_a | alu_b;
            end
        endcase
    end

    assign zero_flag = alu_result == 0;
endmodule