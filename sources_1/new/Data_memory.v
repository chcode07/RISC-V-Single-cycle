`timescale 1ns / 1ps

//Data Memory with inbuilt control logic

module Mem_Data(
    input [31:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data,
    input mem_write,
    input mem_read,
    input [2:0] funct_3, // Used for byte/half-word/word access
    input clk
);
    // A simple memory array of 256 words (1024 bytes).
    reg [7:0] memory [1023:0]; //This forms the memory 
    integer i;
    wire [31:0] aligned_address_word, aligned_address_halfword;

    // From here everything is memory controller.

    assign aligned_address_word = addr & 32'hFFFFFFFC;   // Align to 4-byte boundary for word access
    assign aligned_address_halfword =  addr & 32'hFFFFFFFE; // Align to 2-byte boundary for half-word access

    initial begin
        // Initialize memory to zero
        for (i = 0; i < 1024; i = i+1) 
            memory[i] = 8'd0;
        // For testing: preload a word at an address (if desired)
        memory[10] = 8'h01; 
        memory[11] = 8'h88;
        memory[12] = 8'h55;
        memory[13] = 8'hA0;
        memory[14] = 8'hAB; 
    end
    
    // Combinational read. Single cycle risc-v cores use combinational memory reads.
    always @(*) begin
        read_data = 32'd0;
        if(mem_read) begin
            case(funct_3)
                // Load Byte - (LB) - sign-extended
                3'b000: read_data = {{24{memory[addr][7]}}, memory[addr]};

                // Load Half-word - (LH) - sign-extended
                3'b001: read_data = {{16{memory[aligned_address_halfword+1][7]}}, memory[aligned_address_halfword+1], memory[aligned_address_halfword]};

                // Load Word - (LW)
                3'b010: read_data = {memory[aligned_address_word+3], memory[aligned_address_word+2], memory[aligned_address_word+1], memory[aligned_address_word]};

                // Load Byte Unsigned - (LBU) - zero-extended
                3'b100: read_data = {{24{1'b0}}, memory[addr]};

                // Load Half-word Unsigned - (LHU) - zero-extended
                3'b101: read_data = {{16{1'b0}}, memory[aligned_address_halfword+1], memory[aligned_address_halfword]};
                default: read_data = 32'd0; 
            endcase 
        end
    end

    // Synchronous write (for simulation, use a simple clocked model).
    always @(negedge clk) begin
        if(mem_write) begin
            case(funct_3)
                // Store Byte - (SB)
                3'b000: begin memory[addr] <= write_data[7:0]; end

                // Store Half-word - (SH)
                3'b001: begin 
                            memory[aligned_address_halfword] <= write_data[7:0];
                            memory[aligned_address_halfword+1] <= write_data[15:8];
                        end

                // Store Word - (SW)
                3'b010: begin 
                            memory[aligned_address_word] <= write_data[7:0];
                            memory[aligned_address_word+1] <= write_data[15:8];
                            memory[aligned_address_word+2] <= write_data[23:16];
                            memory[aligned_address_word+3] <= write_data[31:24];
                        end
                default: ;
            endcase
        end
    end
endmodule
