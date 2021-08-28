`include "defines.h"

/**
CPU模块
*/
module cpu(
    input cpu_clk_i,                        //时钟信号
    input cpu_rst_i,                        //复位信号
    input [`WORDSIZE-1:0] cpu_data_i,       //CPU数据输入
    output cpu_we_o,                        //CPU写使能输出
    output [`ADDRSIZE-1:0] cpu_addr_o,      //CPU地址输出
    output [`WORDSIZE-1:0] cpu_data_o,      //CPU数据输出

    input cpu_ack_i,                        //被访问设备已返回数据的信号
    output cpu_hello_o,                     //发起读/写操作的信号

    /**外部中断请求*/
    input cpu_int_i
);

    wire rst;
    assign rst = cpu_rst_i;

    wire halt;                      //停止运行信号
    wire pc_sel;                    //PC前的数据选择器的选择信号
    wire pc_we;                     //PC的写使能信号
    wire ram_addr_sel;              //RAM地址前的数据选择器的选择信号
    wire ram_we;                    //RAM的写使能信号
    wire ir_we;                     //IR的写使能信号
    wire zf_we;                     //ZF寄存器的写使能信号
    wire [`ALUOPSIZE-1:0] alu_op;   //ALU做什么运算的控制信号
    wire alu_a_sel;                 //ALU的输入A前的数据选择器的选择信号
    wire alu_b_sel;                 //ALU的输入B前的数据选择器的选择信号
    wire acc_we;                    //累加器的写使能信号

    wire int_ins;                   //该指令是否是软件中断指令
    wire not_exists_ins;            //该指令是否是非法指令
    wire [`ADDRSIZE-1:0] new_pc;    //下一条应该执行的指令的地址
    wire exception;                 //是否应该进行异常处理

    reg[`ADDRSIZE-1:0] exception_ret_addr;  //异常返回地址

    assign exception = int_ins | not_exists_ins | cpu_int_i;    //外部中断、非法指令、软件中断都会引起异常处理

    wire clock;
    assign clock = halt == 1 ? 0 :cpu_clk_i;    //halt信号为逻辑1时令CPU停止运行

    reg[`ADDRSIZE-1:0] pc;          //程序计数器

    wire [`ADDRSIZE-1:0] jmp_addr;  //跳转地址

    //异常处理跳转地址选择
    always @(*) begin
        if (int_ins == 1) begin
            new_pc = 64;
        end else if (not_exists_ins == 1) begin
            new_pc = 64 + 8;
        end else if (cpu_int_i == 1) begin
            new_pc = 64 + 16;
        end
    end

    //异常返回地址选择
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

    //下一条指令地址选择
    always @(posedge clock or posedge rst) begin
        if (rst == 1) begin
            pc <= 0;
        end else begin
            if (pc_we == 1) begin
                if (exception == 1) begin
                    pc <= new_pc;
                end else if (pc_sel == 0)
                    pc <= pc + 1;
                else
                    pc <= jmp_addr;
            end
        end
    end

    wire [`ADDRSIZE-1:0] operand_addr;  //指令中的数据地址
    wire [`ADDRSIZE-1:0] addr;          //真正访问RAM的地址
    assign addr = ram_addr_sel == 0 ? pc : operand_addr;    //从PC和operand_addr中选一个作为RAM地址

    reg [`WORDSIZE-1:0] acc;    //累加器

    wire [`WORDSIZE-1:0] ram_out;   //RAM输出

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

    assign jmp_addr = ram_out[`ADDRSIZE-1:0];   //跳转地址

    wire [`WORDSIZE-1:0] alu_b_value;   //ALU的输入B的值
    assign alu_b_value = ram_out;

    reg [`WORDSIZE-1:0] ir;     //指令寄存器

    always @(posedge clock or posedge rst) begin
        if (rst == 1)
            ir <= 0;
        else begin
            if (ir_we == 1)
                ir <= ram_out;
        end
    end

    wire [`OPCODE_RANGE] opcode;        //操作码
    wire [`IMMSIZE-1:0] operand_imm;    //立即数操作数

    assign opcode = ir[`OPCODE_RANGE];
    assign operand_addr = ir[`ADDRSIZE-1:0];
    assign operand_imm = ir[`IMMSIZE-1:0];

    wire [`WORDSIZE-1:0] sign_extented_operand_imm; //符号扩展后的立即数
    assign sign_extented_operand_imm = {{`IMMEXTSIZE{operand_imm[`IMMSIZE-1]}}, operand_imm};

    reg zf;     //ZF寄存器
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

    //控制单元
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