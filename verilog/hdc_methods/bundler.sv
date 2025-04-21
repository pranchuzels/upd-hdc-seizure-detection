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

    parameter NUM_REGS = 32;
    parameter [NUM_REGS - 1: 0] SEEDS [0: 10 - 1] = {32'hee84d6f0, 32'he5062510, 32'hce670ebc, 32'h1908ac42, 32'h2cbce7d3, 32'h1907fc39, 32'h5b7f724b, 32'h16184cd3, 32'h6fee04d8, 32'hbd1b07a6};
    parameter [$clog2(NUM_REGS) - 1: 0] TAPS [3: 0] = {0, 2, 6, 7};

    input clk;
    input nrst;
    input en;
    input [NUM_HVS - 1:0][DIMENSIONS - 1:0] hv_array;
    output reg out;
    output reg [DIMENSIONS - 1:0] hv_out;

    reg [$clog2(DIMENSIONS) - 1: 0] d;

    reg bundler_bits_en;
    reg [NUM_HVS - 1: 0][PAR_BITS - 1: 0] bundler_bits_in;
    reg [PAR_BITS - 1: 0] tie_bits;
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
        .bundler_bits_in(bundler_bits_in)
    );

    generate
        if (NUM_HVS % 2 == 0) begin
            for (genvar i = 0; i < PAR_BITS; i = i + 1) begin
                lfsr #(
                    .NUM_REGS(NUM_REGS),
                    .SEED(SEEDS[i]),
                    .TAPS(TAPS)
                ) u_lfsr (
                    .clk(clk),
                    .nrst(nrst),
                    .en(bundler_bits_en),
                    .out_tie(tie_bits[i])
                );
            end
        end
    endgenerate

    bundler_bits #(
        .NUM_HVS(NUM_HVS),
        .PAR_BITS(PAR_BITS)
    ) u_bundler_bit (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_bits_en),
        .bits(bundler_bits_in),
        .tie_bits(tie_bits),
        .done(bundler_bits_done),
        .out_bits(bundler_bits_out)
    );  

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            d <= 0;
            state <= 0;

            out <= 1;
            hv_out <= 0;
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
                    
                    hv_out[d +: PAR_BITS] <= bundler_bits_out;
                    
                    if (d == DIMENSIONS - PAR_BITS) begin
                        state <= 0;
                        out <= 1;
                    end
                    else begin
                        d <= d + PAR_BITS;
                        state <= 1;
                    end
                end
            end

            else begin
                state <= 0;
            end
        end
    end

endmodule