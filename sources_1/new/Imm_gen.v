`timescale 1ns / 1ps

// Unified Immediate Generator Module
// Generates immediate values based on instruction type:
//   # I-type (arithmetic and load): from bits [31:20]
//   # S-type (store): from {instr[31:25], instr[11:7]}
//   # B-type (branch): from {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}

module DP_02_Imm_Gen(
    input [31:0] instr,
    output reg [31:0] imm
);
    wire [6:0] op;
    assign op = instr[6:0];
    
    always @(*) begin
        case (op)
            7'b0010011: imm = {{20{instr[31]}}, instr[31:20]}; // I-type arithmetic (ADDI, etc.)
            7'b0000011:  // Load instructions (I-type)
                imm = {{20{instr[31]}}, instr[31:20]};
            7'b0100011:   // Store (S-type)
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011:   // Branch (B-type)
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            default: 
                imm = 32'd0;
        endcase
    end
endmodule
