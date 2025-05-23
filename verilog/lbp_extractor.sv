`timescale 1ns / 100ps
module lbp_extractor (
    sample_window,
    sample_pattern
);

    // General params
    parameter SAMPLE_SIZE = 16;
    parameter LBP_SIZE = 6;

    input [SAMPLE_SIZE - 1: 0] sample_window [LBP_SIZE: 0];
    output logic [LBP_SIZE - 1: 0] sample_pattern;

    always_comb begin
        for (int i = 0; i < LBP_SIZE; i = i + 1) begin
            if (sample_window[i] <= sample_window[i+1])
                sample_pattern[LBP_SIZE - 1 - i] = 1'b1;
            else
                sample_pattern[LBP_SIZE - 1 - i] = 1'b0;
        end
    end

endmodule