`include "constants.sv"
module core(input logic clk, input logic rst, output logic [31:0] pc_out, Imm_out,
                                    output logic [4:0] RS1_out, RS2_out, RD_out, output logic Exception, valid_out,
                                    output logic RegWrite_out);

// FORWARDING
logic RegWrite_MEM, RegWrite_WB;
logic [4:0] RS1_EXCT, RS2_EXCT, RD_MEM, RD_WB;
logic [1:0] FW_RS1_EXCT, FW_RS2_EXCT;
// STALLS
logic MemToReg_EXCT;
logic [4:0] RS1_DISP, RS2_DISP, RD_EXCT;
logic FLUSH_EXCT, STALL_DISP, STALL_FETCH;
// BRANCH HAZARD
logic BranchIsTaken_EXCT;
// EXCEPTION
logic Exception_WB;
assign Exception = Exception_WB;
assign RegWrite_out = RegWrite_WB;

// FETCH
logic [31:0] pc_FETCH;
logic [31:0] pc_EXCT;
logic [31:0] Imm32_EXCT, RS1_val_EXCT;
logic [1:0] PCMux_EXCT;
logic [1:0] TakenPCMux_EXCT = (BranchIsTaken_EXCT) ? PCMux_EXCT : 2'b00;
logic PCEn = !STALL_FETCH & !Exception_WB;
logic [31:0] instr_FETCH;
logic [31:0] pc_DISP, instr_DISP;
logic Enable_DISP = !STALL_DISP & !Exception_WB;
logic rst_DISP = rst | BranchIsTaken_EXCT;

programCounter programCounter1(clk, PCEn, TakenPCMux_EXCT, pc_EXCT, Imm32_EXCT, RS1_val_forwarded_EXCT, pc_FETCH);
memory #(.N(17))instrMemory(clk, 0 /*we*/, pc_FETCH >> 2, 3'b010 /*32w*/, 0, instr_FETCH);

// FETCH~~~~~~~DECODE
pipelineLatch #(.width(64))latch_DISP(clk, rst_DISP, Enable_DISP, {pc_FETCH, instr_FETCH}, {pc_DISP, instr_DISP});
//~~~~~~~~~~~~~~~~~~~

// DECODE
logic [31:0] Result_WB;
logic [4:0] RD_DISP;
logic [31:0] RS1_val_DISP, RS2_val_DISP, Imm32_DISP;
logic [3:0] alu_op_DISP;
logic [2:0] mem_width_DISP;
logic MemToReg_DISP, MemWrite_DISP, ALUSrc1_DISP, RegWrite_DISP, Branch_DISP, InvertBranchTriger_DISP, Jump_DISP,
    Exception_DISP, valid_DISP;
logic [1:0] ALUSrc2_DISP, PCMux_DISP;
logic [2:0] mem_width_EXCT;
logic [3:0] alu_op_EXCT;
logic [31:0] RS2_val_EXCT;
logic MemWrite_EXCT, ALUSrc1_EXCT, RegWrite_EXCT, Branch_EXCT, InvertBranchTriger_EXCT, Jump_EXCT, Exception_EXCT,
    valid_EXCT;
logic [1:0] ALUSrc2_EXCT;
logic PipeRegRst_EXCT = rst | FLUSH_EXCT | BranchIsTaken_EXCT;
logic PipeRegEn_EXCT = !Exception_WB;

dispatcher dispatcher(instr_DISP, RS1_DISP, RS2_DISP, RD_DISP, Imm32_DISP, mem_width_DISP, alu_op_DISP, MemToReg_DISP,
                      MemWrite_DISP, ALUSrc1_DISP, ALUSrc2_DISP, RegWrite_DISP, Branch_DISP, InvertBranchTriger_DISP,
                      Jump_DISP, PCMux_DISP, Exception_DISP, valid_DISP);
registerFile registerFile1(clk, RegWrite_WB, RS1_DISP, RS2_DISP, RD_WB, Result_WB, RS1_val_DISP, RS2_val_DISP);

// DECODE~~~~~~~EXCTECUTE
pipelineLatch #(.width(150))latch_EXECT1(clk, PipeRegRst_EXCT, PipeRegEn_EXCT,
                                          {pc_DISP, RS1_val_DISP, RS2_val_DISP, Imm32_DISP, RS1_DISP, RS2_DISP, RD_DISP,
                                           alu_op_DISP, mem_width_DISP},
                                          {pc_EXCT, RS1_val_EXCT, RS2_val_EXCT, Imm32_EXCT, RS1_EXCT, RS2_EXCT, RD_EXCT,
                                           alu_op_EXCT, mem_width_EXCT});
pipelineLatch #(.width(13))latch_EXECT2(clk, PipeRegRst_EXCT, PipeRegEn_EXCT,
                                          {MemToReg_DISP, MemWrite_DISP, ALUSrc1_DISP, ALUSrc2_DISP, RegWrite_DISP,
                                           Branch_DISP, InvertBranchTriger_DISP, Jump_DISP, PCMux_DISP, Exception_DISP,
                                           valid_DISP},
                                          {MemToReg_EXCT, MemWrite_EXCT, ALUSrc1_EXCT, ALUSrc2_EXCT, RegWrite_EXCT,
                                           Branch_EXCT, InvertBranchTriger_EXCT, Jump_EXCT, PCMux_EXCT, Exception_EXCT,
                                           valid_EXCT});
//~~~~~~~~~~~~~~~~~~~~~~

// EXECUTE
logic [31:0] RS1_val_forwarded_EXCT =
    (FW_RS1_EXCT [1:1]) ? ALUOut_MEM : ((FW_RS1_EXCT [0:0]) ? Result_WB : RS1_val_EXCT);
logic [31:0] RS2_val_forwarded_EXCT =
    (FW_RS2_EXCT [1:1]) ? ALUOut_MEM : ((FW_RS2_EXCT [0:0]) ? Result_WB : RS2_val_EXCT);
logic [31:0] ALUSrc1_val_EXCT = (ALUSrc1_EXCT) ? pc_EXCT : RS1_val_forwarded_EXCT;
logic [31:0] ALUSrc2_val_EXCT =
    (ALUSrc2_EXCT == 2'b00) ? RS2_val_forwarded_EXCT : ((ALUSrc2_EXCT == 2'b01) ? Imm32_EXCT : 4);
logic [31:0] ALUOut_EXCT;
logic [31:0] pc_MEM, ALUOut_MEM, MemWriteData_MEM;
logic [2:0] mem_width_MEM;
logic MemToReg_MEM, MemWrite_MEM, Exception_MEM, valid_MEM;
logic PipeRegRst_MEM = rst;
logic PipeRegEn_MEM = !Exception_WB;

alu alu1(ALUSrc1_val_EXCT, ALUSrc2_val_EXCT, alu_op_EXCT, ALUOut_EXCT, ALUZero_EXCT);


// EXCTECUTE~~~~~~~~~~MEMORY
pipelineLatch #(.width(96))latch_mem1(clk, PipeRegRst_MEM, PipeRegEn_MEM,
                                      {pc_EXCT, ALUOut_EXCT, RS2_val_forwarded_EXCT},
                                      {pc_MEM, ALUOut_MEM, MemWriteData_MEM});
pipelineLatch #(.width(13))
    latch_mem2((clk, PipeRegRst_MEM, PipeRegEn_MEM,
                {mem_width_EXCT, MemToReg_EXCT, MemWrite_EXCT, RegWrite_EXCT, RD_EXCT, Exception_EXCT, valid_EXCT},
                {mem_width_MEM, MemToReg_MEM, MemWrite_MEM, RegWrite_MEM, RD_MEM, Exception_MEM, valid_MEM}););
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// MEMORY
logic [31:0] ReadData_MEM;
memory #(.N(17))dataMemory(clk, MemWrite_MEM, ALUOut_MEM >> 2, mem_width_MEM, MemWriteData_MEM, ReadData_MEM);

// MEMORY~~~~~~~~WRITEBACK
logic [31:0] ReadData_WB, ALUOut_WB;
logic MemToReg_WB, valid_WB;
logic PipeRegRst_WB = rst;
logic PipeRegEn_WB = !Exception_WB;
logic [31:0] Imm32_WB, pc_WB;
logic [4:0] RS1_WB, RS2_WB;

pipelineLatch #(.width(64))latch_WB1(clk, PipeRegRst_WB, PipeRegEn_WB, {ReadData_MEM, ALUOut_MEM},
                                     {ReadData_WB, ALUOut_WB});
pipelineLatch #(.width(9))latch_WB2(clk, PipeRegRst_WB, PipeRegEn_WB,
                                    {RegWrite_MEM, MemToReg_MEM, RD_MEM, Exception_MEM, valid_MEM},
                                    {RegWrite_WB, MemToReg_WB, RD_WB, Exception_WB, valid_WB});

assign pc_out = pc_WB;
assign RS1_out = RS1_WB;
assign RS2_out = RS2_WB;
assign RD_out = RD_WB;
assign Imm_out = Imm32_WB;
assign valid_out = valid_WB;

// WRITEBACK
assign Result_WB = (MemToReg_WB) ? ReadData_WB : ALUOut_WB;

// HAZARD
hazardUnit hazardUnit1(RegWrite_MEM, RegWrite_WB, RS1_EXCT, RS2_EXCT, RD_MEM, RD_WB, FW_RS1_EXCT, FW_RS2_EXCT,
                       MemToReg_EXCT, RS1_DISP, RS2_DISP, RD_EXCT, FLUSH_EXCT, STALL_DISP, STALL_FETCH,
                       BranchIsTaken_EXCT);

endmodule
