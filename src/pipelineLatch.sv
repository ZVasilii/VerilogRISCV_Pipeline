//Verified
module pipelineLatch #(parameter width = 32)
(
    input logic clk,
    input logic rst,
    input logic en,
    input logic [width - 1:0] In,
    output logic [width - 1:0] Out
);
logic [width - 1:0] Stored;
assign Out = Stored;

always_ff @(posedge clk)
begin
    if (en && !rst)
        Stored <= In;
    else if (rst)
        Stored <= {width{1'b0}};
end
endmodule
