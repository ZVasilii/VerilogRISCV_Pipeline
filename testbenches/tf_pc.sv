`timescale 1 ns / 100 ps

module tf_pc();

logic clk = 1'b0;

logic en = 0;
logic [1:0] PCMux = 2'h0;
logic [31:0] PC_Execute = 32'h42;
logic [31:0] Imm = 32'h228;
logic [31:0] Reg1 = 32'h322;
logic [31:0] PCOut = 32'h0;


always begin
   #1 clk = ~clk;
end



programCounter pc_test(clk, en, PCMux, PC_Execute, Imm, Reg1, PCOut);

initial begin
    $dumpvars;
    $display("Starting simulation");
    #5
    en = 1;
    PCMux = 2'h1;
    #5
    PCMux = 2'h2;
    #5
    PCMux = 2'h3;
    #5
     $finish;

end

endmodule
