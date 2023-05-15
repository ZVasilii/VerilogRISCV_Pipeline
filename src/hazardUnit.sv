`include "constants.sv"

module hazardUnit(
    // Forwarding
    input RegWrite_MEM, RegWrite_WB,
    input[4:0] RS1_EX,
    input[4:0] RS2_EX,
    input[4:0] RD_MEM,
    input[4:0] RD_WB,
    output logic[1:0] FW_RS1_EX, FW_RS2_EX,

    // STALLs
    input MemToReg_EX,
    input [4:0]RS1_ID, RS2_ID, RD_EX,
    output FLUSH_EX, STALL_ID, STALL_IF,

    //Control hazards
    input BranchIsTaken_EX

);


//STALLS in controll hazard
wire STALL = MemToReg_EX & ((RS1_ID == RD_EX) || (RS2_ID == RD_EX)) || BranchIsTaken_EX;
assign FLUSH_EX = STALL, STALL_ID = STALL, STALL_IF = STALL;

//FORWARDING
    //   10 - forward from MEM
    //   01 - forward from WB
    //   00 - no forward
assign FW_RS1_EX = {2{(RS1_EX != 5'h0)}}
    & ((RegWrite_MEM & (RD_MEM == RS1_EX)) ? `FW_MEM
    : ((RegWrite_WB & (RD_WB == RS1_EX)) ?  `FW_WB : `NO_FW ));

assign FW_RS2_EX = {2{(RS2_EX != 5'h0)}}
    & ((RegWrite_MEM & (RD_MEM == RS2_EX)) ? `FW_MEM
    : ((RegWrite_WB & (RD_WB == RS2_EX)) ?  `FW_WB : `NO_FW ));


endmodule
