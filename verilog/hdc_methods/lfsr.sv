// TODO: Change output to be able to handle multiple dimensions for hypervector

`timescale 1ns / 1ps

module lfsr (
    clk,
    nrst,
    out
);
    parameter SEED = 16'b1001010010110101;
    parameter NUM_HVS = 17;

    input clk;
    input nrst;
    output reg [NUM_HVS - 1: 0] out;
    reg [15:0] registers = SEED;
    reg msb = 0;
    

    always @( posedge clk ) begin
        if (!nrst) begin
            registers <= SEED;
            out <= 0;
            msb <= 0;
        end else begin
            msb <= registers[1] ^ registers[2] ^ registers[4] ^ registers[13];
            registers <= {msb, registers[15:1]};
            out <= registers[0];
        end
    end
endmodule