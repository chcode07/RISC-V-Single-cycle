`timescale 1ns / 1ps

//Control Path all the necessary control signals to co-ordiante the functioning of the core based on the instructions

module control_path_single_clk(
    input [31:0] instr_op_1, 
    output reg write_ctrl, 
    output reg operand_ctrl, 
    output reg load_ctrl,
    output reg branch_flag,
    output reg mem_read,
    output reg mem_write,
    output reg [3:0] ctrl_op
);
    wire [6:0] op_code; 
    assign op_code = instr_op_1[6:0]; 

    // Opcode definitions (7-bit values)
    parameter REG_TYPE = 7'b0110011;
    parameter IMM_TYPE = 7'b0010011;
    parameter LOAD     = 7'b0000011;
    parameter STORE    = 7'b0100011;
    parameter BRANCH   = 7'b1100011;
    
    // Combinational control unit: decode instruction
    always @(*) begin
        // Default values to ensure all outputs are always driven (no latches)
        write_ctrl      = 1'b0;
        operand_ctrl    = 1'b0;
        mem_write       = 1'b0;
        mem_read        = 1'b0;
        load_ctrl       = 1'b0;
        branch_flag     = 1'b0;
        ctrl_op         = 4'd0; // Default to 0, e.g., for unsupported instructions

        case (op_code) 
            // R-type instruction (e.g. add, sub, etc.)
            REG_TYPE: begin
                case({instr_op_1[31:25], instr_op_1[14:12]})
                    10'b0000000000: ctrl_op = 4'b0000; // ADD
                    10'b0100000000: ctrl_op = 4'b0001; // SUB
                    10'b0000000100: ctrl_op = 4'b0010; // XOR
                    10'b0000000110: ctrl_op = 4'b0011; // OR
                    10'b0000000111: ctrl_op = 4'b0100; // AND
                    10'b0000000001: ctrl_op = 4'b0101; // SLL
                    10'b0000000101: ctrl_op = 4'b0110; // SRL
                    10'b0100000101: ctrl_op = 4'b0111; // SRA
                    10'b0000000010: ctrl_op = 4'b1000; // SLT
                    10'b0000000011: ctrl_op = 4'b1001; // SLTU
                    default:        ctrl_op = 4'b0; // Default to ADD/ADDI op if not recognized
                endcase                    
                write_ctrl      = 1'b1;
                operand_ctrl    = 1'b0;
            end
            
            // I-type arithmetic instructions: addi, andi, ori, etc.
            IMM_TYPE: begin
                case ({instr_op_1[31:25], instr_op_1[14:12]})
                    10'b0000000000: ctrl_op = 4'b0000; // ADDI
                    10'b0000000100: ctrl_op = 4'b0010; // XORI
                    10'b0000000110: ctrl_op = 4'b0011; // ORI
                    10'b0000000111: ctrl_op = 4'b0100; // ANDI
                    10'b0000000001: ctrl_op = 4'b0101; // SLLI
                    10'b0000000101: ctrl_op = 4'b0110; // SRLI
                    10'b0100000101: ctrl_op = 4'b0111; // SRAI
                    10'b0000000010: ctrl_op = 4'b1000; // SLTI
                    10'b0000000011: ctrl_op = 4'b1001; // SLTIU
                    default:        ctrl_op = 4'b0; // Default to ADD/ADDI op
                endcase
                write_ctrl      = 1'b1;
                operand_ctrl    = 1'b1;   // use immediate for ALU operand
            end
            
            // Load instruction (I-type format, e.g., lw)
            LOAD: begin
                mem_read        = 1'b1;
                ctrl_op         = 4'b0000; // ALU does addition (base+offset)
                operand_ctrl    = 1'b1;    // immediate used to compute effective address
                load_ctrl       = 1'b1;     // select memory output as write-back value
                write_ctrl      = 1'b1;    // result (memory data) written back to reg file
            end
            
            // Store instruction (S-type format, e.g., sw)
            STORE: begin
                ctrl_op         = 4'b0000; // addition for effective address computation
                operand_ctrl    = 1'b1;    // immediate used to compute effective address
                mem_write       = 1'b1;
            end
            
            // Branch instruction (B-type, e.g., beq)
            BRANCH: begin
                ctrl_op         = 4'b0001; // ALU performs subtraction for comparison (a-b), result zero for equality
                branch_flag     = 1'b1;
            end
            
            default: begin
                // All signals remain their default (0) values set at the top of the always block
            end
        endcase
    end
endmodule