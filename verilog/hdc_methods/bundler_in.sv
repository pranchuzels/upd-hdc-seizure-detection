`timescale 1ns / 1ps

module bundler_in (
        state,
        d,
        hv_array,
        bundler_bits_en,
        bundler_bits_in
    );

    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;
    parameter PAR_BITS = 10;

    input [1:0] state;
    input [$clog2(DIMENSIONS) - 1: 0] d;
    input [NUM_HVS - 1:0][DIMENSIONS - 1:0] hv_array;
    output reg bundler_bits_en;
    output reg [NUM_HVS - 1: 0][PAR_BITS - 1: 0] bundler_bits_in;


    always_comb begin : bundler_bit_en_in
        if (state == 1)
            bundler_bits_en = 1;
        else
            bundler_bits_en = 0;

        for (int i = 0; i < NUM_HVS; i = i + 1) begin
            bundler_bits_in[i] = hv_array[i][d +: PAR_BITS];
        end
    end

endmodule