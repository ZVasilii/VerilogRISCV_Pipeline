`timescale 1 ns / 100 ps

module tf_memory();

logic clk = 1'b0;
logic we = 0;
logic [31:0]  Addr = 32'h42;
logic [2:0] Width = 3'h0;
logic [31:0] InData = 32'h228;
logic [31:0] OutData = 32'h322;

logic we = 0'b1;

always begin
   #1 clk = ~clk;
end

always begin
   #5 Width = Width + 3'h1;
end


memory memory_test(clk, we, Addr, Width, InData, OutData);

initial begin
    $dumpvars;
    $display("Starting simulation");
    #5
    we = 1;
    Addr = 32'h42;
    #5
    Addr = 32'h48;
    #5
    Addr = 32'52;
    #5
    we = 0;
    #5
    Addr = 32'h42;
    #5
    Addr = 32'h48;
    #5
    Addr = 32'52;
    #5
     $finish;

end

endmodule
