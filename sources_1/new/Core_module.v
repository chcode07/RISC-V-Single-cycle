`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2025 22:36:37
// Design Name: 
// Module Name: Core_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Core_module(
output  [31:0]  alu_out, data_read_2,instr_addr_to_mem,
input [31:0] mem_read_data, instr_op_from_mem,
output CU_mem_write, CU_mem_read,
input clk, reset
    );
    

    wire CU_write_ctrl, CU_operand_ctrl, CU_load_ctrl, CU_branch_flag;
    wire [3:0] CU_ctrl_op;
    // Instantiate the top-level core (Control Unit)
        control_path_single_clk CU (
        .instr_op_1(instr_op_from_mem), 
        .write_ctrl(CU_write_ctrl),
        .operand_ctrl(CU_operand_ctrl),
        .load_ctrl(CU_load_ctrl),
        .branch_flag(CU_branch_flag),
        .mem_read(CU_mem_read),
        .mem_write(CU_mem_write),
        .ctrl_op(CU_ctrl_op)
    );
    
    // Instantiate Datapath
    Data_path DP (
        .clk(clk),
        .reset(reset),
        .write_ctrl(CU_write_ctrl),
        .operand_ctrl(CU_operand_ctrl),
        .load_ctrl(CU_load_ctrl),
        .branch_flag(CU_branch_flag),
        .instr_op(instr_op_from_mem), 
        .ctrl_op(CU_ctrl_op),
        .mem_read_data(mem_read_data),
        .instr_addr(instr_addr_to_mem),
        .alu_out(alu_out),
        .data_read_2(data_read_2)
    );


endmodule
