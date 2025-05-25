`timescale 1ns / 1ps

//REGISTER FILE 

module DP_01_REG_FILE(
    input clk,
    input [4:0] read_reg_1,
    input [4:0] read_reg_2,
    input [4:0] write_reg,
    input [31:0] data_write,
    input write_ctrl,
    output reg [31:0] data_read_1,
    output reg [31:0] data_read_2
);
    reg [31:0] registers [31:0];
    integer i;
    
    initial begin
        // Initialize all registers to 0;
        // preset some registers for testing.
        for (i = 0; i < 32; i = i+1)
            registers[i] = 32'd0;
        // For testing, set x1 and x2. 
        registers[1] = 32'd10; // x1 = 10
        registers[2] = 32'd10; // x2 = 10
        registers[9] = 32'hffff;// x9 = fffff
    end

    // Synchronous write. Writes happen on the positive edge of the clock.
    always @(negedge clk) begin
        if (write_ctrl) begin // x0 (register 0) is hardwired to 0 and cannot be written
            registers[write_reg] <= data_write;
        end
    end

    // Combinational read. Reads happen immediately based on read_reg_1 and read_reg_2.
    always @(*) begin
        data_read_1 = registers[read_reg_1];
        data_read_2 = registers[read_reg_2];
    end
endmodule
