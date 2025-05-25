`timescale 1ns / 1ps

// All elements are connected to together to form the core structure of the single cycle CPU.

module Data_path(
    input clk,
    input reset,
    input write_ctrl,
    input operand_ctrl,
    input load_ctrl,
    input branch_flag,
    input [31:0] instr_op, // Instruction from Instruction Memory
    input [3:0] ctrl_op,
    input [31:0] mem_read_data,
    output [31:0] instr_addr, // PC output to Instruction Memory
    output [31:0] alu_out,
    output [31:0] data_read_2
);
    // Wires connecting the internals
    wire [31:0] data_read_1, data_write;
    wire [31:0] imm_out;
    wire [31:0] alu_b;
    reg  [31:0] PC; // Program Counter
    wire branch_taken;

    
    // ALU - second operand comes from immediate when operand_ctrl is asserted.
    assign alu_b = operand_ctrl ? imm_out : data_read_2;

    DP_00_ALU ALU (
        .a(data_read_1),
        .b(alu_b),
        .ctrlop(ctrl_op),
        .out(alu_out),
        .flag()  // flag not used in this design
    );

    
    // Write-back multiplexer: if load_ctrl is high, select memory data; otherwise, take ALU result.
    assign data_write = load_ctrl ? mem_read_data : alu_out;
    
    // Register File Instance (synchronous write)
    DP_01_REG_FILE Registers (
        .clk(clk),
        .read_reg_1(instr_op[19:15]), // rs1
        .read_reg_2(instr_op[24:20]), // rs2
        .write_reg(instr_op[11:7]),   // rd
        .data_write(data_write),      // Data to write
        .write_ctrl(write_ctrl),      // Write enable
        .data_read_1(data_read_1),
        .data_read_2(data_read_2)
    );

    // Instantiate the unified Immediate Generator.
    DP_02_Imm_Gen immgen (
        .instr(instr_op),
        .imm(imm_out)
    );


    /* Branch comparator logic
    ->The ALU output (alu_out) is used for comparison in branch instructions.
    ->For branches like BEQ, BNE, BLT, etc., the ALU performs (rs1 - rs2)
    and the branch condition checks the sign/zero flag of the result.*/

    assign branch_taken = branch_flag &&
        ( (instr_op[14:12] == 3'b000 && (alu_out == 32'd0)) ||             // BEQ (rs1 == rs2) -> (rs1 - rs2 == 0)
          (instr_op[14:12] == 3'b001 && (alu_out != 32'd0)) ||             // BNE (rs1 != rs2) -> (rs1 - rs2 != 0)
          (instr_op[14:12] == 3'b100 && (alu_out[31] == 1'b1)) ||         // BLT (rs1 < rs2 signed) -> (rs1 - rs2 < 0 signed)
          (instr_op[14:12] == 3'b101 && (alu_out[31] == 1'b0 && alu_out != 32'd0)) || // BGE (rs1 >= rs2 signed) -> (rs1 - rs2 >= 0 signed)
          (instr_op[14:12] == 3'b110 && ($unsigned(data_read_1) < $unsigned(data_read_2))) || // BLTU (rs1 < rs2 unsigned)
          (instr_op[14:12] == 3'b111 && ($unsigned(data_read_1) >= $unsigned(data_read_2)))   // BGEU (rs1 >= rs2 unsigned)
        );

    /* Synchronous PC Update:
     ->If reset is asserted, PC is forced to 0.
     ->Else, if branch is taken, PC = PC + branch immediate (imm_out, which is computed in B-type format).
     ->Otherwise, PC increments by 4. */

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'd0;
        else if (branch_taken)
            PC <= PC + imm_out; // Branch target calculation
        else
            PC <= PC + 4;       // Next sequential instruction
    end

    assign instr_addr = PC; // PC value is the address for instruction memory
endmodule
