`timescale 1ns / 1ps

module bundler (
    clk,
    nrst,
    en,
    hv_array,
    out,
    hv_out
);

    parameter DIMENSIONS = 10000;
    parameter NUM_HVS = 17;
    parameter PAR_BITS = 10;

    input reg clk;
    input reg nrst;
    input en;
    input [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    output reg out;
    output reg [DIMENSIONS - 1:0] hv_out;

    reg [$clog2(DIMENSIONS) - 1: 0] d;

    reg bundler_bit_en;
    reg bundler_bit_in [PAR_BITS - 1: 0][NUM_HVS - 1: 0];
    reg ties_1 [PAR_BITS - 1: 0];
    reg ties_2 [PAR_BITS - 1: 0];
    reg [PAR_BITS - 1: 0] bundler_bit_out;
    reg [1:0] state;

    reg [PAR_BITS - 1:0] bundler_bit_done;

    generate
        for (genvar i = 0; i < PAR_BITS; i = i + 1) begin : bundler_bits
            bundler_bit #(
                .NUM_HVS(NUM_HVS)
            ) u_bundler_bit (
                .clk(clk),
                .nrst(nrst),
                .en(bundler_bit_en),
                .bits(bundler_bit_in[i]),
                .tie_1(ties_1[i]),
                .tie_2(ties_2[i]),
                .done(bundler_bit_done[i]),
                .out_bit(bundler_bit_out[i])
            );  
        end
    endgenerate

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            d <= 0;
            state <= 0;

            out <= 1;
        end

        else begin
            // Idle State
            if (state == 0) begin
                if (en) begin
                    d <= 0;
                    state <= 1;

                    out <= 0;
                end
            end

            // Send data to bundler_bit state
            else if (state == 1) begin
                state <= 2;              
            end

            // Wait for output State
            else if (state == 2) begin
                if (bundler_bit_done == {PAR_BITS{1'b1}}) begin
                    if (d == DIMENSIONS - PAR_BITS) begin
                        state <= 3;
                        out <= 1;
                    end
                    else begin
                        d <= d + PAR_BITS;
                        state <= 1;
                    end
                end
            end

            else if (state == 3) begin
                if (en) begin
                    d <= 0;
                    state <= 1;

                    out <= 0;
                end
            end
        end
    end

    always_comb begin : bundler_bit_outputs
        if (state == 0) begin
            hv_out = 0;
        end

        else if (state == 2) begin
            if (bundler_bit_done == {PAR_BITS{1'b1}}) begin
                for (int i = 0; i < PAR_BITS; i = i + 1) begin
                    if (bundler_bit_out[i] == 1) begin
                        hv_out[d + i] = 1;
                    end else begin
                        hv_out[d + i] = 0;
                    end
                end
            end
        end
    end

    always_comb begin : bundler_bit_inputs
        if (state == 0) begin
            bundler_bit_en = 0;
            for (int i = 0; i < PAR_BITS; i = i + 1) begin
                for (int j = 0; j < NUM_HVS; j = j + 1) begin
                    bundler_bit_in[i][j] = 0;
                end
                ties_1[i] = 0;
                ties_2[i] = 0;
            end
        end

        else if (state == 1 || state == 2) begin

            if (state == 1)
                bundler_bit_en = 1;
            else
                bundler_bit_en = 0;

            for (int i = 0; i < PAR_BITS; i = i + 1) begin
                for (int j = 0;  j < NUM_HVS; j = j + 1) begin
                    bundler_bit_in[i][j] = hv_array[j][d + i];
                end
                if (d + i == DIMENSIONS - 1) begin
                    ties_1[i] = hv_array[NUM_HVS - 1][0];
                    ties_2[i] = hv_array[0][0];
                end else begin
                    ties_1[i] = hv_array[NUM_HVS - 1][d + i + 1];
                    ties_2[i] = hv_array[0][d + i + 1];
                end
            end
        end

        else begin
            bundler_bit_en = 0;
            for (int i = 0; i < PAR_BITS; i = i + 1) begin
                for (int j = 0; j < NUM_HVS; j = j + 1) begin
                    bundler_bit_in[i][j] = 0;
                end
                ties_1[i] = 0;
                ties_2[i] = 0;
            end
        end
    end
endmodule