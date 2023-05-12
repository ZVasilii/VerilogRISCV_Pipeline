`include "constants.sv"
`include "aluCodes.sv"

module dispatcher (
    input  logic [31:0] Instr,
    output logic [4:0]RS1,
    output logic [4:0]RS2,
    output logic [4:0]RD,
    output logic [31:0] Imm,
    output logic [2:0] memWidth,

    // control unit out
    output logic [3:0] ALU_OP,
    output logic MemToReg, MemWrite,
    // ALUSrc1:
    // 0 - rs1
    // 1 - pc
    // ALUSrc2:
    // 00 - rs2
    // 01 - imm
    // 11 - 4
    output logic ALUSrc1,
    output logic [1:0] ALUSrc2,
    output logic RegWrite,
    output logic Branch, InvertBranchTriger,
    output logic Jump,
    //00 - PC = PC + 4
    //01 -  PC = PC_Execute + imm
    //10 -  PC = Reg + imm
    output logic [1:0] PCMux,
    output logic Exception = 0, //If ecall or etc
    output logic valid          //0 - everything is ok
);


logic [6:0] opcode;
logic [6:0] funct7;
logic [2:0] funct3;

//DECODER STAGE
assign RS1  = Instr[19:15];
assign RS2  = Instr[24:20];
assign RD = Instr[11:7];
assign memWidth = funct3;
assign opcode = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7 = Instr[31:25];

//IMMEDIATE STAGE
logic [31:0] i_imm_32, s_imm_32, b_imm_32, u_imm_32, j_imm_32, shamt_32;
assign i_imm_32 = { {20{Instr[31]}}, Instr[31:20]};                              // I-type
assign s_imm_32 = { {20{Instr[31]}}, Instr[31:25], Instr[11:7]};                 // S-Type
assign b_imm_32 = { {20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; //B-type
assign u_imm_32 = { Instr[31:12]   , {12{1'b0}}}; // U-type
assign j_imm_32 = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // J-type
assign shamt_32 = {{27{1'b0}}, Instr[24:20]};

assign Imm =    (opcode == `I_TYPE && funct3 == 3'b001)? shamt_32:  //SLLI
                (opcode == `I_TYPE && funct3 == 3'b101)? shamt_32:  //SRLI
                (opcode == `I_TYPE)? i_imm_32:  //I-type
                (opcode == `LOAD  )? i_imm_32:  //Load
                (opcode == `STORE )? s_imm_32:  //S-type
                (opcode == `BRANCH)? b_imm_32:  //Branches
                (opcode == `JAL   )? j_imm_32:  //JAL
                (opcode == `JALR  )? i_imm_32:  //JALR
                (opcode == `AUIPC )? u_imm_32:  //Auipc
                (opcode == `LUI   )? u_imm_32:  //Lui
                32'b0;

//CONTROLLER STAGE
always_comb begin
    case(opcode)
        `R_TYPE:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 0; ALUSrc2 = 2'b00;
            Branch = 0; Jump = 0; RegWrite = 1; PCMux = 2'b00; //PC = PC + 4
            Exception = 0; valid = 1;
            if (funct3 == 3'b000) begin
                if (funct7 == 7'b0000000) begin
                    ALU_OP = `ALU_ADD;
                end else begin
                    ALU_OP = `ALU_SUB;
                end
            end else if (funct3 == 3'b010) begin
                ALU_OP = `ALU_SLT;
            end else if (funct3 == 3'b100) begin
                ALU_OP = `ALU_XOR;
            end else if (funct3 == 3'b111) begin
                ALU_OP = `ALU_AND;
            end else if (funct3 == 3'b001) begin
                ALU_OP = `ALU_SHL;
            end else if (funct3 == 3'b011) begin
                ALU_OP = `ALU_SLTU;
            end else if (funct3 == 3'b110) begin
                ALU_OP = `ALU_OR;
            end else if (funct3 == 3'b101) begin
                if (funct7 == 7'b0000000) begin
                    ALU_OP = `ALU_SHR;
                end else begin
                    ALU_OP = `ALU_SHA;
                end
            end
        end
        `I_TYPE:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 0; ALUSrc2 = 2'b01;
            Branch = 0; Jump = 0; RegWrite = 1; PCMux = 2'b00; // PC = PC + 4
            Exception = 0; valid = 1;
            if (funct3 == 3'b000) begin
                ALU_OP = `ALU_ADD; //addi
            end else if (funct3 == 3'b001) begin
                ALU_OP = `ALU_SHL; //slli
            end else if (funct3 == 3'b010) begin
                ALU_OP = `ALU_SLT; //slti
            end else if (funct3 == 3'b011) begin
                ALU_OP = `ALU_SLTU; //sltiu
            end else if (funct3 == 3'b100) begin
                ALU_OP = `ALU_XOR; //xori
            end else if (funct3 == 3'b101) begin
                if (funct7 == 7'b0000000) begin
                    ALU_OP = `ALU_SHR; //srli
                end else begin
                    ALU_OP = `ALU_SHA; //srai
                end
            end else if (funct3 == 3'b110) begin
                ALU_OP = `ALU_OR; //ori
            end else if (funct3 == 3'b111) begin
                ALU_OP = `ALU_AND; //andi
            end
        end
        `STORE:
        begin
            MemToReg = 0; MemWrite = 1; ALUSrc1 = 0; ALUSrc2 = 2'b01;
            Branch = 0; Jump = 0; RegWrite = 0; PCMux = 2'b00; // PC = PC + 4
            Exception = 0; valid = 1; ALU_OP = `ALU_ADD;
        end
        `LOAD:
        begin
            MemToReg = 1; MemWrite = 0; ALUSrc1 = 0; ALUSrc2 = 2'b01;
            Branch = 0; Jump = 0; RegWrite = 1; PCMux = 2'b00; // PC = PC + 4
            Exception = 0; valid = 1; ALU_OP = `ALU_ADD;
        end
        `BRANCH:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 0; ALUSrc2 = 2'b00;
            Branch = 1; Jump = 0; RegWrite = 0; PCMux = 2'b01; // PC = PC + Imm
            Exception = 0; valid = 1;
            if (funct3 == 3'b000) begin
                ALU_OP = `ALU_SUB; //beq
                InvertBranchTriger = 1;
            end else if (funct3 == 3'b001) begin
                ALU_OP = `ALU_SUB; //bne
                InvertBranchTriger = 0;
            end else if (funct3 == 3'b100) begin
                ALU_OP = `ALU_SLT; //blt
                InvertBranchTriger = 0;
            end else if (funct3 == 3'b101) begin
                ALU_OP = `ALU_SLT; //bge
                InvertBranchTriger = 1;
            end else if (funct3 == 3'b110) begin
                ALU_OP = `ALU_SLTU; //bltu
                InvertBranchTriger = 0;
            end else if (funct3 == 3'b111) begin
                ALU_OP = `ALU_SLTU; //bgeu
                InvertBranchTriger = 1;
            end
        end
        `JALR:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 1; ALUSrc2 = 2'b11;
            Branch = 0; Jump = 1; RegWrite = 1; PCMux = 2'b11; // PC = REG + IMM
            Exception = 0; valid = 1;
        end
        `JAL:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 1; ALUSrc2 = 2'b11;
            Branch = 0; Jump = 1; RegWrite = 1; PCMux = 2'b01; //PC = PC + Imm
            Exception = 0; valid = 1;
        end
        `AUIPC:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 1; ALUSrc2 = 2'b01;
            Branch = 0; Jump = 0; RegWrite = 1; PCMux = 2'b00; //PC = PC + 4
            Exception = 0; valid = 1; ALU_OP = `ALU_ADD;
        end
        `LUI:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 0; ALUSrc2 = 2'b01;
            Branch = 0; Jump = 0; RegWrite = 1; PCMux = 2'b00; // PC = PC + 4
            Exception = 0; valid = 1; ALU_OP = `ALU_SRC2;
        end
        `ZERO:
        begin
            MemToReg = 0; MemWrite = 0; ALUSrc1 = 1'bx; ALUSrc2 = 2'bxx;
            Branch = 0; Jump = 0; RegWrite = 0; PCMux = 2'b00; // PC = PC + 4
            Exception = 0; valid = 0;
        end
        default:
        begin
            Exception = 1; valid = 1;
        end
    endcase
end

endmodule
