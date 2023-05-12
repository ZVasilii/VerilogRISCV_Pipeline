//Verified

module memory
#(parameter N = 12)
(input logic clk,
input logic we,
input logic [31:0] Addr,
input logic [2:0] Width,
input logic [31:0] InData,
output logic [31:0] OutData
);

logic	[31:0]	memoryBuffer 	[0:((1<<N)-1)] /*verilator public*/;

//Width === funct3 on decode stage:
//000 - LB ( 8 bits with sign extend)
//001 - LH ( 16 bits with sign extend)
//010 - LW ( 32 bits)
//10* - LBU || LHU (8 || 16 bits with ZERO extend)
logic isHalf = Width[0];
logic isWord = Width[1];
logic ifUnsigned = Width[2];
logic signExtend = ~ifUnsigned;

//If not signExtend -> zeroExtend
logic [31:0]DataByte = { {24{signExtend && memoryBuffer[Addr][7]}}, memoryBuffer[Addr][7:0] };
logic [31:0]DataHalf = { {16{signExtend && memoryBuffer[Addr][15]}}, memoryBuffer[Addr][15:0] };
logic [31:0]DataWord = memoryBuffer[Addr];

//Combinational Reading
assign OutData = (isHalf) ? DataHalf : ((isWord) ? DataWord : DataByte);

//Sequential writing
always_ff @(posedge clk)
begin
    if (we)
    begin
        memoryBuffer[Addr][7:0] <= InData[7:0];

        if(isHalf)
        begin
            memoryBuffer[Addr][15:8] <= InData[15:8];
        end
        else if(isWord)
        begin
            memoryBuffer[Addr][31:8] <= InData[31:8];
        end
    end
end
endmodule
