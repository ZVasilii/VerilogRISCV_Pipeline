`timescale 1 ns / 100 ps

module tf_regFile();

logic clk = 1'b0;

logic[4:0] ReadN1 = 32'h42;
logic[4:0] ReadN2 = 32'h16;

logic[4:0] WriteN = 4'h0;
logic [31:0] In = 32'h0;
logic [31:0] Out1 = 32'h0;
logic [31:0] Out2 = 32'h0;

logic we = 0'b1;

always begin
   #1 clk = ~clk;
end


registerFile regFile_test(clk, we, ReadN1, ReadN2, WriteN, In, Out1, Out2);

initial begin
    $dumpvars;
    $display("Starting simulation");
    #5
    we = 1;
    writeN = 5'h8;
    In = 32'h42;
    #2
    we = 0;
    #5
    ReadN1 = 5'h8;
    ReadN2 = 5'h9;
    #10
     $finish;

end

endmodule
