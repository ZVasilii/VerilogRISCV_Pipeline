`timescale 1 ns / 100 ps

module tf_alu();

logic clk = 1'b0;

logic[31:0] Src1 = 32'h42;
logic[31:0] Src2 = 32'h16;

logic[3:0] ALUop = 4'h0;
logic [31:0] ALUOut = 32'h0;
logic zFlag = 0;

always begin
   #1 clk = ~clk;
end

always begin
   #5 ALUop = ALUop + 4'h1; //switch operations
end

alu alu_test(Src1, Src2, ALUop, ALUOut, zFlag);

initial begin
    $dumpvars;
    $display("Starting simulation");
    #200
     $finish;

end

endmodule
