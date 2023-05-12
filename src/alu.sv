
`include "src/alu_codes.sv"
//Verified
//ALU module (see alu_codes.sv for encoding)

module ALU(input logic [31:0] Src1, Src2,   //Source 1 && 2 ALU
           input logic [3:0] ALUop,         //Operation code
           output logic [31:0] ALUOut,      //ALUOutput
           output logic zFlag  //for Comparison
);

assign zFlag = (ALUOut === 0);
logic [4:0]shamt = Src2[4:0];

always_comb
begin
  case (ALUop)
    `ALU_ADD:  ALUOut = Src1 + Src2;
    `ALU_SUB:  ALUOut = Src1 - Src2;
    `ALU_AND:  ALUOut = Src1 & Src2;
    `ALU_OR:   ALUOut = Src1 | Src2;
    `ALU_XOR:  ALUOut = Src1 ^ Src2;
    `ALU_SHL:  ALUOut = Src1 << shamt;
    `ALU_SHR:  ALUOut = Src1 >> shamt;
    `ALU_SHA:  ALUOut = $signed(Src1)>>>$signed(shamt);
    `ALU_SLT:  ALUOut = {{31{1'b0}}, $signed(Src1) < $signed(Src2)};
    `ALU_SLTU: ALUOut = {{31{1'b0}} , Src1 < Src2};
    `ALU_SRC1:    ALUOut = Src1;
    `ALU_SRC2:    ALUOut = Src2;
    default: ; //To syntesize into comb logic
   endcase
end

endmodule
