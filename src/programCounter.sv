`include "src/constants.sv"
//Verified
module programCounter(
    input logic clk,
    input logic en,
    input logic [1:0] PCMux,
    input logic [31:0] PC_Execute,
    input logic [31:0] Imm,
    input logic [31:0] Reg1,

    output logic [31:0] PCOut
);

assign PCOut = pc;

//PC = PC + 4
//OR PC = PC_Execute + imm
//OR PC = Reg + imm
logic [31:0] pc /*verilator public*/;
wire [31:0] PC_SRC1 = (PCMux === `PC_IF) ? pc : ((PCMux === `PC_EX) ? PC_Execute : Reg1);
wire [31:0] PC_SRC2 = (PCMux === `PC_REG || PCMux === `PC_EX) ? Imm : 32'h4;
always_ff @(posedge clk) begin
    if (en) begin
        pc <= PC_SRC1 + PC_SRC2;
    end
end

endmodule
