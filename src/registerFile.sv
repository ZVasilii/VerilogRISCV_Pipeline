//RISC-V register file module
//R0 always set to 32'b0
//Verified
module registerFile (
    input logic  clk,
    input logic we,
    input logic[4:0] ReadN1,
    input logic[4:0] ReadN2,
    input logic[4:0] WriteN,
    input logic[31:0] In,
    output logic[31:0] Out1,
    output logic[31:0] Out2
);

logic [31:0] registerFile [31:0] /*verilator public*/;

//Combinational reading from regFile
assign Out1 = (ReadN1 === 5'b0) ? 32'b0 : registerFile[ReadN1];
assign Out2 = (ReadN2 === 5'b0) ? 32'b0 : registerFile[ReadN2];

//Sequential writing on Negedge (to solve issue with writeback)
always_ff @(negedge clk)
begin
    if(we && (WriteN != 5'b0))
    begin
        registerFile[WriteN] <= In;
    end
end

endmodule
