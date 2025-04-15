`timescale 1ns / 1ps

module bundler_in (
        state,
        d,
        hv_array,
        bundler_bits_en,
        bundler_bits_in,
        ties_1,
        ties_2
    );

    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;
    parameter PAR_BITS = 10;

    input [1:0] state;
    input [$clog2(DIMENSIONS) - 1: 0] d;
    input [NUM_HVS - 1:0][DIMENSIONS - 1:0] hv_array;
    output reg bundler_bits_en;
    output reg [NUM_HVS - 1: 0][PAR_BITS - 1: 0] bundler_bits_in;
    output reg [PAR_BITS - 1: 0] ties_1;
    output reg [PAR_BITS - 1: 0] ties_2;


    always_comb begin : bundler_bit_en_in
        if (state == 1)
            bundler_bits_en = 1;
        else
            bundler_bits_en = 0;

        for (int i = 0; i < NUM_HVS; i = i + 1) begin
            bundler_bits_in[i] = hv_array[i][d +: PAR_BITS];
        end
    end

    generate
        if (NUM_HVS % 2 == 0) begin
            always_comb begin : ties
                if (d == DIMENSIONS - PAR_BITS) begin
                    ties_1 = {hv_array[NUM_HVS - 1][0], hv_array[NUM_HVS - 1][0 +: PAR_BITS - 1]};
                    ties_2 = {hv_array[0][0], hv_array[0][0+: PAR_BITS - 1]};
                end else begin
                    ties_1 = hv_array[NUM_HVS - 1][d + 1 +: PAR_BITS];
                    ties_2 = hv_array[0][d + 1 +: PAR_BITS];
                end
            end
        end
    endgenerate

endmodule