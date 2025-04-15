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

    input clk;
    input nrst;
    input en;
    input [NUM_HVS - 1:0][DIMENSIONS - 1:0] hv_array;
    output reg out;
    output reg [DIMENSIONS - 1:0] hv_out;

    reg [$clog2(DIMENSIONS) - 1: 0] d;

    reg bundler_bits_en;
    reg [NUM_HVS - 1: 0][PAR_BITS - 1: 0] bundler_bits_in;
    reg [PAR_BITS - 1: 0] ties_1;
    reg [PAR_BITS - 1: 0] ties_2;
    reg [PAR_BITS - 1: 0] bundler_bits_out;
    reg [1:0] state;

    reg bundler_bits_done;

 
    bundler_in #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS),
        .PAR_BITS(PAR_BITS)
    ) u_bundler_in (
        .state(state),
        .d(d),
        .hv_array(hv_array),
        .bundler_bits_en(bundler_bits_en),
        .bundler_bits_in(bundler_bits_in),
        .ties_1(ties_1),
        .ties_2(ties_2)
    );

    bundler_bits #(
        .NUM_HVS(NUM_HVS),
        .PAR_BITS(PAR_BITS)
    ) u_bundler_bit (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_bits_en),
        .bits(bundler_bits_in),
        .ties_1(ties_1),
        .ties_2(ties_2),
        .done(bundler_bits_done),
        .out_bits(bundler_bits_out)
    );  

    always_comb begin : bundler_bit_outputs
        if (state == 0) begin
            hv_out = 0;
        end

        else begin
            hv_out[d +: PAR_BITS] = bundler_bits_out;
        end
    end

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
                if (bundler_bits_done) begin
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

endmodule