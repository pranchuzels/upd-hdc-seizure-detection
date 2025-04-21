// TODO: Change output to be able to handle multiple dimensions for hypervector

`timescale 1ns / 1ps

module lfsr (
    clk,
    nrst,
    en,
    out_tie
);
    parameter NUM_REGS = 32;
    parameter SEED = 32'hee84d6f0;
    parameter [$clog2(NUM_REGS) - 1: 0] TAPS [3: 0] = {0, 2, 6, 7};

    input clk;
    input nrst;
    input en;
    output wire out_tie;
    reg [NUM_REGS - 1 : 0] regs;

    assign out_tie = regs[0];

    always @(posedge clk or negedge nrst) begin

        if (!nrst) begin
            regs <= SEED;
        end 
        
        else begin
            if (en) begin
                regs <= {regs[TAPS[0]] ^ regs[TAPS[1]] ^ regs[TAPS[2]] ^ regs[TAPS[3]], regs[NUM_REGS - 1:1]};
            end
        end

    end

endmodule