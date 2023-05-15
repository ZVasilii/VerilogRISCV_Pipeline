//~~~~NEXT_PC_CALCULATION~~~//
`define PC_IF 2'b00
`define PC_EX 2'b01
`define PC_REG 2'b11
//~~~~~~~~~~~~~~~~~~~~~~~~~~//

//~~~~INSTR~~~TYPES~~~~~~~//
`define R_TYPE 7'b0110011
`define I_TYPE 7'b0010011
`define STORE  7'b0100011
`define LOAD   7'b0000011
`define BRANCH 7'b1100011
`define JALR   7'b1100111
`define JAL    7'b1101111
`define AUIPC  7'b0010111
`define LUI    7'b0110111
`define ZERO   7'b0000000
//~~~~~~~~~~~~~~~~~~~~~~~~~~//

//~~~FORWARDING~~~//
`define FW_MEM 2'b10
`define FW_WB  2'b01
`define NO_FW  2'b00
//~~~~~~~~~~~~~~~~//
