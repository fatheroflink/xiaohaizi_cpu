`include "defines.h"

module cpu(
    input cpu_clk_i,
    input cpu_rst_i,
    input [`WORDSIZE-1:0] cpu_data_i,
    output cpu_we_o,
    output [`ADDRSIZE-1:0] cpu_addr_o,
    output [`WORDSIZE-1:0] cpu_data_o,

    /**内存控制器接口*/
    input cpu_ack_i,
    output cpu_hello_o,

    /**外部中断请求*/
    input cpu_int_i
);

    wire rst;
    assign rst = cpu_rst_i;

    wire halt;
    wire pc_sel;
    wire pc_we;
    wire ram_addr_sel;
    wire ram_we;
    wire ir_we;
    wire zf_we;
    wire [`ALUOPSIZE-1:0] alu_op;
    wire alu_a_sel;
    wire alu_b_sel;
    wire acc_we;

    wire int_ins;
    wire not_exists_ins;
    wire [`ADDRSIZE-1:0] new_pc;
    wire exception;

    reg[`ADDRSIZE-1:0] exception_ret_addr;

    assign exception = int_ins | not_exists_ins | cpu_int_i;

    wire clock;
    assign clock = halt == 1 ? 0 :cpu_clk_i;

    reg[`ADDRSIZE-1:0] pc;

    wire [`ADDRSIZE-1:0] jmp_addr;

    always @(*) begin
        if (int_ins == 1) begin
            new_pc = 64;
        end else if (not_exists_ins == 1) begin
            new_pc = 64 + 8;
        end else if (cpu_int_i == 1) begin
            new_pc = 64 + 16;
        end
    end

    always@(posedge clk or posedge rst) begin
        if (rst == 1) begin
            exception_ret_addr <= 0;
        end else if (exception == 1) begin
            if (pc_sel == 0)
                exception_ret_addr <= pc + 1;
            else
                exception_ret_addr <= jmp_addr;
        end
    end

    always @(posedge clock or posedge rst) begin
        if (rst == 1) begin
            pc <= 0;
        end else begin
            if (pc_we == 1) begin
                if (exception == 1) begin
                    pc <= new_pc;
                end else if (pc_sel == 0)
                    pc <= pc + 1;56666
                else
                    pc <= jmp_addr;
            end
        end
    end

    wire [`ADDRSIZE-1:0] operand_addr;
    wire [`ADDRSIZE-1:0] addr;
    assign addr = ram_addr_sel == 0 ? pc : operand_addr;

    reg [`WORDSIZE-1:0] acc;

    wire [`WORDSIZE-1:0] ram_out;

    assign cpu_we_o = ram_we;
    assign cpu_addr_o = addr;
    assign ram_out = cpu_data_i;
    assign cpu_data_o = acc;
    // regfile ram(
    //     .clk(clock),
    //     .we(ram_we),
    //     .rst(rst),
    //     .addr(addr),
    //     .d_in(acc),
    //     .d_out(ram_out)
    // );

    assign jmp_addr = ram_out[`ADDRSIZE-1:0];

    wire [`WORDSIZE-1:0] alu_b_value;
    assign alu_b_value = ram_out;

    reg [`WORDSIZE-1:0] ir;

    always @(posedge clock or posedge rst) begin
        if (rst == 1)
            ir <= 0;
        else begin
            if (ir_we == 1)
                ir <= ram_out;
        end
    end

    wire [`OPCODE_RANGE] opcode;
    wire [`IMMSIZE-1:0] operand_imm;

    assign opcode = ir[`OPCODE_RANGE];
    assign operand_addr = ir[`ADDRSIZE-1:0];
    assign operand_imm = ir[`IMMSIZE-1:0];

    wire [`WORDSIZE-1:0] sign_extented_operand_imm;
    assign sign_extented_operand_imm = {{`IMMEXTSIZE{operand_imm[`IMMSIZE-1]}}, operand_imm};

    reg zf;
    wire [`WORDSIZE-1:0] alu_a;
    wire [`WORDSIZE-1:0] alu_b;
    wire [`WORDSIZE-1:0] alu_result;
    wire alu_zf;

    always @(posedge clock or posedge rst) begin
        if (rst == 1)
            acc <= 0;
        else begin
            if (acc_we == 1)
                acc <= alu_result;
        end
    end

    assign alu_a = alu_a_sel == 0 ? acc:0;
    assign alu_b = alu_b_sel == 0 ? sign_extented_operand_imm : alu_b_value;

    alu alu(
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .alu_result(alu_result),
        .zero_flag(alu_zf)
    );

    always @(posedge clock or posedge rst) begin
        if (rst == 1)
            zf <= 0;
        else begin
            if (zf_we == 1)
                zf <= alu_zf;
        end
    end

    ctrl_unit ctrl_unit(
        .clk(clock),
        .rst(rst),
        .opcode(opcode),
        .zf(alu_zf),
        .pc_sel(pc_sel),
        .pc_we(pc_we),
        .ram_addr_sel(ram_addr_sel),
        .ram_we(ram_we),
        .ir_we(ir_we),
        .zf_we(zf_we),
        .alu_op(alu_op),
        .alu_a_sel(alu_a_sel),
        .alu_b_sel(alu_b_sel),
        .acc_we(acc_we),
        .halt(halt),
        .hello(cpu_hello_o),
        .ack(cpu_ack_i),
        .int_ins(int_ins),
        .not_exists_ins(not_exists_ins)
    );
endmodule