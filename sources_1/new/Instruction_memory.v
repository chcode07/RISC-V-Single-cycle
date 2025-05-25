`timescale 1ns / 1ps

//INSTRUCTION MEMORY - "Preloaded with Test Instructions" 

//   Address 0:  addi x8, x1, 5       --> 0x00508413
//   Address 4:  lb x10, 4(x2)        --> 0x00410503
//   Address 8:  sw x9, 4(x1)         --> 0x00912223
//   Address 12: beq x1, x2, 8        --> 0x00850663
//   Address 16: add x8, x1, x2       --> 0x00208433

module Instr_Mem(
    input [31:0] read_addr,
    output reg [31:0] instr_op
);
    reg [7:0] memory_units [1023:0];
    wire [31:0] aligned_addr;
    
    // Align to 4-byte boundaries.
    assign aligned_addr = read_addr & 32'hFFFFFFFC;
     integer j;
    initial begin
        // Initialize all memory units to 0 to prevent 'x' propagation
       
        for (j = 0; j < 1024; j = j + 1) begin
            memory_units[j] = 8'h00;
        end

        // Instruction at address 0: addi x8, x1, 5 --> 0x00508413
        memory_units[0] = 8'h13; // LSB
        memory_units[1] = 8'h84;
        memory_units[2] = 8'h50;
        memory_units[3] = 8'h00; // MSB

        // Instruction at address 4: lb x10, 4(x2) --> 0x00410503
        memory_units[4] = 8'h03;
        memory_units[5] = 8'h05;
        memory_units[6] = 8'h41;
        memory_units[7] = 8'h00;

        // Instruction at address 8: sw x9, 4(x1) -->0x00912223
        memory_units[8]  = 8'h23;
        memory_units[9]  = 8'h22;
        memory_units[10] = 8'h91;
        memory_units[11] = 8'h00;

        // Instruction at address 12: beq x1, x2, 8 --> 0x00850663
        // This is a branch to PC + 8 (relative to current PC, so 12 + 8 = 20)
//        memory_units[12] = 8'h63;
//        memory_units[13] = 8'h06;
//        memory_units[14] = 8'h85;
//        memory_units[15] = 8'h00;

        // Instruction at address 16: add x8, x1, x2 --> 0x00208433
        // If beq branches, this instruction is skipped.
        memory_units[16] = 8'h33;
        memory_units[17] = 8'h84;
        memory_units[18] = 8'h20;
        memory_units[19] = 8'h00;

        // Add a simple instruction at address 20 for beq to jump to if taken
        // Example: addi x7, x0, 100 --> 0x06400093 (dummy instruction)
        memory_units[20] = 8'h93;
        memory_units[21] = 8'h00;
        memory_units[22] = 8'h40;
        memory_units[23] = 8'h06;
    end

    always @(*) begin
        instr_op = { memory_units[aligned_addr+3],
                     memory_units[aligned_addr+2],
                     memory_units[aligned_addr+1],
                     memory_units[aligned_addr+0] };
    end
endmodule
