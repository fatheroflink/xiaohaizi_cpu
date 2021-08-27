`define WORDSIZE 16
`define ADDRSIZE 8
`define RAMSIZE 64
`define IMMSIZE 8
`define OPCODESIZE 4
`define IMMEXTSIZE 8

`define ALUOPSIZE 2
`define ALU_OP_ADD 0
`define ALU_OP_SUB 1
`define ALU_OP_AND 2
`define ALU_OP_OR  3

`define OPCODE_RANGE 11:8

`define ISA_ADD_M 0
`define ISA_SUB_M 1
`define ISA_AND_M 2
`define ISA_OR_M 3
`define ISA_HALT 4
`define ISA_STORE 5
`define ISA_LOAD_M 6
`define ISA_JMP 7
`define ISA_JE 8
`define ISA_ADD_I 9
`define ISA_SUB_I 10
`define ISA_AND_I 11
`define ISA_OR_I 12
`define ISA_LOAD_I 13
`define ISA_INT 14

`define MEM_CTRL_STATE_IDEL 0
`define MEM_CTRL_STATE_ACCESS 1
`define MEM_CTRL_STATE_DONE 2

`define CPU_STATE_FETCH     0
`define CPU_STATE_EXECUTE   1

`define S0_ADDR_MAX 64
`define S1_ADDR_MAX 64*2
`define S2_ADDR_MAX 64*3
`define S3_ADDR_MAX 64*4
