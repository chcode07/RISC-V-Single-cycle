`timescale 1ns / 1ps

module top_module( input clk, input reset);
    
    // Wires to connect the instruction memory to the control unit and datapath
    wire [31:0] instr_op_from_mem;
    wire [31:0] instr_addr_to_mem;
    wire [31:0] mem_read_data, alu_out, data_read_2;

    // Instantiate Instruction Memory first
    Instr_Mem Instr_mem (
        .read_addr(instr_addr_to_mem),
        .instr_op(instr_op_from_mem)
        );
        
    Core_module C1 (.alu_out(alu_out),.data_read_2(data_read_2),.instr_addr_to_mem(instr_addr_to_mem),
    .mem_read_data(mem_read_data), .instr_op_from_mem(instr_op_from_mem),
    .CU_mem_write(CU_mem_write), .CU_mem_read(CU_mem_read), .clk(clk),.reset(reset)
    );
    // Wires for control signals coming from Control Unit to Datapath
    wire CU_mem_read, CU_mem_write;

    // Data Memory instance for load and store instructions.
    Mem_Data DataMem (
        .addr(alu_out),         // effective address = base + offset
        .write_data(data_read_2),// Data to write comes from data_read_2 for S-type
        .read_data(mem_read_data),
        .mem_write(CU_mem_write),
        .mem_read(CU_mem_read),
        .funct_3(instr_op_from_mem[14:12]),
        .clk(clk)
    );

endmodule

