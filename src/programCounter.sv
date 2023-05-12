`include "src/constants.sv"

module programCounter(
    input clk,
    input en,
    input[1:0] PCMux,
    input[31:0] PC_Execute,
    input[31:0] Imm,
    input[31:0] Reg1,

    output[31:0] PCOut
);
logic [31:0] pc /*verilator public*/;
logic [31:0] PC_SRC1 = (NextPC === `PC_IF) ? pc : ((NextPC === `PC_EX) ? PC_Execute : Reg1);
logic [31:0] PC_SRC2 = (NextPC === `PC_REG) ? Imm : 4;
always @(posedge clk) begin
    if (en) begin
        PCOut <= PC_SRC1 + PC_SRC2;
    end
end

endmodule
