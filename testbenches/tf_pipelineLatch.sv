`timescale 1 ns / 100 ps

module tf_pipelineLatch();

logic clk = 1'b0;
logic en = 1'b0;
logic rst = 1'b0;
logic en = 1'b0;
logic [31:0] In = 32'h228;
logic [31:0] Out = 32'h228;

always begin
   #1 clk = ~clk;
end



pipelineLatch pipelineLatch_test(clk, rst, en, In, Out);

initial begin
    $dumpvars;
    $display("Starting simulation");
    #5
    en = 1;
    #5
    rst = 1;
    #5
    rst = 0;
    #5
    en = 0;
    #5
    In = 32'h42;
    #5
    $finish;

end

endmodule
