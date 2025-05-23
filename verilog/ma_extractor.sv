`timescale 1ns / 1ps
module ma_extractor (
    clk,
    nrst,
    en,
    samples,
    done,
    ma
);

    // General params
    parameter DIMENSIONS = 10000;
    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    parameter SAMPLE_SIZE = 16;
    
    // Feature params
    parameter NUM_MA = 64;
    parameter signed MA_MIN_PATIENT = 16'b1111011110000010;
    parameter signed MA_MAX_PATIENT = 16'b0000100110101010;

    input clk;
    input nrst;
    input en;
    input [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    output reg done;
    output reg [$clog2(NUM_MA) - 1:0] ma;

    reg [1:0] state;
    reg [$clog2(WINDOW_SIZE) - 1:0] s;

    reg signed [SAMPLE_SIZE + $clog2(WINDOW_SIZE) - 1: 0] npeak;
    wire signed [SAMPLE_SIZE - 1: 0] sample_left;
    wire signed [SAMPLE_SIZE - 1: 0] sample_curr;
    wire signed [SAMPLE_SIZE - 1: 0] sample_right;

    assign sample_left = samples[s - 2];
    assign sample_curr = samples[s - 1];
    assign sample_right = samples[s];

    reg signed [SAMPLE_SIZE + $clog2(WINDOW_SIZE) - 1: 0] mean;
    reg signed [SAMPLE_SIZE - 1: 0] mean_div;
    wire signed [SAMPLE_SIZE: 0] ma_val;
    
    
    assign ma_val = {(mean_div  - MA_MIN_PATIENT), 1'b0} / {1'b0, ((MA_MAX_PATIENT - MA_MIN_PATIENT) >> 6)};

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 1'b0;
            ma <= 0;

            state <= 2'b0;
            s <= 2;
            mean <= 0;
            npeak <= 0;
            mean_div <= 0;
        end
        else begin
            if (state == 0) begin
                done <= 1'b0;
                mean <= 0;
                npeak <= 0;
                if (en) begin
                    state <= 2'b1;
                end
            end
            else if (state == 1) begin
                if (sample_left <= sample_curr && sample_curr >= sample_right) begin
                    mean <= mean + sample_curr;
                    npeak <= npeak + 1;
                end

                if (s == WINDOW_SIZE - 1) begin
                    state <= 2;
                    s <= 2;
                end
                else
                    s <= s + 1;
            end

            else if (state == 2) begin
                mean_div <= mean / npeak;
                state <= 3;
            end

            else if (state == 3) begin
                if (mean_div < MA_MIN_PATIENT)
                    ma <= 0;
                else if (mean_div > MA_MAX_PATIENT)
                    ma <= NUM_MA - 1;
                else begin
                    if (ma_val[0] == 0)
                        ma <= ma_val[$clog2(NUM_MA): 1];
                    else
                        ma <= ma_val[$clog2(NUM_MA): 1] + 1;
                end

                done <= 1'b1;
                state <= 0;
            end
        end
    end

endmodule