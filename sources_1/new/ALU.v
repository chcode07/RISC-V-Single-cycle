`timescale 1ns / 1ps
// Arithematic and Logic Unit of the cure - also used implicitly for calculating effective address and branch address.

module DP_00_ALU(
    input signed [31:0] a,
    input signed [31:0] b,
    input  [3:0] ctrlop,
    output reg signed [31:0] out,
    output flag 
);
    always @(*) begin
        case (ctrlop)
            4'b0000: out = a + b;           // ADD or ADDI, or effective address computation
            4'b0001: out = a - b;           // SUB (also used for branch comparisons for zero/sign check)
            4'b0010: out = a ^ b;           // XOR / XORI
            4'b0011: out = a | b;           // OR / ORI
            4'b0100: out = a & b;           // AND / ANDI
            4'b0101: out = a << b;          // Logical left shift (SLL/SLLI)
            4'b0110: out = a >> b;          // Logical right shift (SRL/SRLI)
            4'b0111: out = a >>> b;         // Arithmetic right shift (SRA/SRAI)
            4'b1000: out = (a < b) ? 32'd1 : 32'd0;  // SLT (Set Less Than - signed)
            4'b1001: out = ($unsigned(a) < $unsigned(b)) ? 32'd1 : 32'd0; // SLTU (Set Less Than Unsigned)
            default: out = 32'd0; 
        endcase
    end
    assign flag = 1'b0; // Unused in this design.
endmodule