`timescale 1ns / 1ps
module ll_extractor (
    clk,
    nrst,
    en,
    samples,
    done,
    ll
);

    // General params
    parameter DIMENSIONS = 10000;
    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    parameter SAMPLE_SIZE = 16;
    
    // Feature params
    parameter NUM_LL = 64;
    parameter LL_MIN_PATIENT = 16'b0;
    parameter LL_MAX_PATIENT = 16'b0000010000001110;

    input clk;
    input nrst;
    input en;
    input [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    output reg done;
    output reg [$clog2(NUM_LL) - 1:0] ll;

    reg [1:0] state;
    reg [$clog2(WINDOW_SIZE) - 1:0] s;

    wire signed [SAMPLE_SIZE - 1: 0] sample_1;
    wire signed [SAMPLE_SIZE - 1: 0] sample_2;
    wire signed [SAMPLE_SIZE - 1: 0] sample_sub;
    reg signed [SAMPLE_SIZE + $clog2(WINDOW_SIZE) - 1: 0] sum;
    wire signed [SAMPLE_SIZE - 1: 0] sum_16;
    wire signed [SAMPLE_SIZE - 1: 0] ll_val;
    wire signed [SAMPLE_SIZE: 0] ll_rem;

    assign sample_1 = samples[s];
    assign sample_2 = samples[s + 1];
    assign sample_sub = sample_1 - sample_2;
    assign sum_16 = sum[SAMPLE_SIZE + $clog2(WINDOW_SIZE) - 1: $clog2(WINDOW_SIZE)];
    assign ll_val = (sum_16  - LL_MIN_PATIENT) / ((LL_MAX_PATIENT - LL_MIN_PATIENT) >> 6);
    assign ll_rem = {(sum_16  - LL_MIN_PATIENT), 1'b0}/ {1'b0, ((LL_MAX_PATIENT - LL_MIN_PATIENT) >> 6)};


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 1'b0;
            ll <= 0;

            state <= 2'b0;
            s <= 0;
            sum <= 0;
        end
        else begin
            if (state == 0) begin
                done <= 1'b0;
                sum <= 0;
                if (en) begin
                    state <= 2'b1;
                end
            end
            else if (state == 1) begin
                if (sample_sub[SAMPLE_SIZE - 1] == 1)
                    sum <= sum - {{$clog2(WINDOW_SIZE){1'b1}}, sample_sub};
                else
                    sum <= sum + {{$clog2(WINDOW_SIZE){1'b0}}, sample_sub};;

                if (s == WINDOW_SIZE - 2) begin
                    state <= 2;
                    s <= 0;
                end
                else
                    s <= s + 1;
            end

            else if (state == 2) begin
                if (sum_16 == 0)
                    ll <= 0;
                else if (sum_16 > LL_MAX_PATIENT)
                    ll <= NUM_LL - 1;
                else begin
                    if (ll_rem[0] == 0)
                        ll <= ll_val[$clog2(NUM_LL) - 1: 0];
                    else
                        ll <= ll_val[$clog2(NUM_LL) - 1: 0] + 1;
                end

                done <= 1'b1;
                state <= 0;
            end
        end
    end

endmodule