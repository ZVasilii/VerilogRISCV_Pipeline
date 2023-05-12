module RGF(
    input logic  clk,
    input logic we,
    input logic[4:0] ReadN,
    input logic[4:0] ReadN,
    input logic[4:0] WriteN,
    input logic[31:0] In,
    output logic[31:0] Out1,
    output logic[31:0] Out2
);

logic [31:0] registers [31:0] /*verilator public*/;

// read registers
assign val1 = (rn1 == 0) ? 0 : registers[rn1];
assign val2 = (rn2 == 0) ? 0 : registers[rn2];

// write to register wn
always @(negedge clk) begin
    if(we && wn !=0) begin
        registers[wn] <= data;
    end
end

endmodule
