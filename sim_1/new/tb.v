`timescale 1ns/1ps

module RISC_V_uut_tb;
    reg clk;
    reg reset;
    
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

    integer i;
    initial begin
        clk = 0;
        reset = 1;
        #15 reset = 0; 
    end
    
    always #5 clk = ~clk; 

    // Monitor key signals.
    initial begin
        $monitor("clk = %b|Time=%0t | PC=%h | Instr=%h | ALU_out=%h | Reg[10]=%h | Reg[1]=%h | Reg[2]=%h | Reg[7]=%h | Reg[8]=%h | Reg[9]=%h | RS1_Val=%h | RS2_Val=%h | Imm_Out=%h | Mem_Addr_12=%h | Mem_Addr_10=%h | Mem_Read_Data=%h | Mem_Read_Data=%h| Write_Ctrl=%b | Operand_Ctrl=%b | Load_Ctrl=%b | Mem_Read_Ctrl=%b | Mem_Write_Ctrl=%b | Branch_Flag=%b | Ctrl_Op=%h",
           clk, $time,
           C1.DP.instr_addr,         // PC
           instr_op_from_mem,     // Current instruction
           C1.DP.ALU.out,            // ALU output
           C1.DP.Registers.registers[10],
           C1.DP.Registers.registers[1], // x1
           C1.DP.Registers.registers[2], // x2
           C1.DP.Registers.registers[7], // x7 (for addi x7, x0, 100)
           C1.DP.Registers.registers[8], // x8 (for addi x8, x1, 5 and add x8, x1, x2)
           C1.DP.Registers.registers[9], // x9 (for lw x9, 0(x1))
           C1.DP.data_read_1,            // Value read from rs1
           C1.DP.data_read_2,            // Value read from rs2 or imm
           C1.DP.imm_out,                // Immediate value generated
           {DataMem.memory[15],DataMem.memory[14],DataMem.memory[13],DataMem.memory[12]}, // Memory at address 12
           {DataMem.memory[13],DataMem.memory[12],DataMem.memory[11],DataMem.memory[10]}, // Memory at address 10 (for lw)
           C1.DP.mem_read_data,          // Data read from data memory
           C1.DP.data_read_2,
           C1.CU_write_ctrl,
           C1.CU_operand_ctrl,
           C1.CU_load_ctrl,
           C1.CU_mem_read,
           C1.CU_mem_write,
           C1.CU_branch_flag,
           C1.CU_ctrl_op
        );
        
         #100
        for (i = 30; i > 5; i = i - 1) begin
            $display(" location =%h | data=%h \n", i,DataMem.memory[i]);
        end
        

        #150 $finish; 
    end
endmodule
