`timescale 1ns / 1ps
module lbp_encoder (
    clk,
    nrst,
    en,
    samples,
    done,
    window_hv
);

    // General params
    parameter DIMENSIONS = 10000;
    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    parameter SAMPLE_SIZE = 16;
    
    // Feature params
    parameter LBP_SIZE = 6;
    parameter NUM_LBP = 64;

    // Bundler params
    parameter COUNT_SIZE = 8;

    input clk;
    input nrst;
    input en;
    input [NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    output reg done;
    output reg [DIMENSIONS - 1:0] window_hv;

    reg [2:0] state;


    // Windower
    wire windower_done;
    wire [WINDOW_SIZE + LBP_SIZE - 1: 0][NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] sample_memory;
    windower #(
        .NUM_CHS(NUM_CHS),
        .WINDOW_SIZE(WINDOW_SIZE + LBP_SIZE),
        .WINDOW_STEP(WINDOW_STEP),
        .SAMPLE_SIZE(SAMPLE_SIZE)
    ) lbp_windower (
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .samples(samples),
        .done(windower_done),
        .sample_memory(sample_memory)
    );


    // LBP extractor
    reg signed [SAMPLE_SIZE - 1: 0] sample_window [LBP_SIZE: 0];
    wire [LBP_SIZE - 1: 0] sample_pattern;

    lbp_extractor u_lbp_extractor (
        .sample_window(sample_window),
        .sample_pattern(sample_pattern)
    );

    // Item Mem
    reg [$clog2(NUM_CHS) - 1: 0] c;
    wire [DIMENSIONS - 1:0] ch_hv;
    wire [DIMENSIONS - 1:0] lbp_hv;
    item_mem_1 enc_item_mem_1(
        .c (c),
        .l (sample_pattern),
        .ch_hv (ch_hv),
        .lbp_hv  (lbp_hv)
    );

    // Binder
    wire [DIMENSIONS -1: 0] bound_ch_lbp;
    binder channel_lbp_binder (
        .hv_1(ch_hv),
        .hv_2(lbp_hv),
        .hv_out(bound_ch_lbp)
    );

                                               

    reg bundler_channel_lbp_en;
    reg [DIMENSIONS - 1: 0] bundler_channel_lbp_in;
    reg bundler_channel_lbp_finish;
    wire [DIMENSIONS - 1: 0] bundler_channel_lbp_out;

    bundler_cont  bundler_channel_lbp (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_channel_lbp_en),
        .finish(bundler_channel_lbp_finish),
        .hv_in(bundler_channel_lbp_in),
        .hv_out(bundler_channel_lbp_out)
    );


    // Sample HVs bundler
    reg [WINDOW_SIZE - 1: 0] s;
    reg bundler_sample_en;
    reg [DIMENSIONS - 1: 0] bundler_sample_in;
    reg bundler_sample_finish;
    wire [DIMENSIONS - 1: 0] bundler_sample_out;

    bundler_cont bundler_sample (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_sample_en),
        .finish(bundler_sample_finish),
        .hv_in(bundler_sample_in),
        .hv_out(bundler_sample_out)
    );


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 0;
            window_hv <= 0;
            state <= 0;

            for (int i = 0; i < LBP_SIZE + 1; i = i + 1) begin
                sample_window[i] <= 0;
            end

            c <= 0;

            bundler_channel_lbp_en <= 0;
            bundler_channel_lbp_finish <= 0;
            bundler_channel_lbp_in <= 0;

            s <= 0;
            bundler_sample_en <= 0;
            bundler_sample_finish <= 0;
            bundler_sample_in <= 0;

        end else begin
            if (state == 0) begin
                done <= 0;
                if (windower_done) begin
                    state <= 1;
                    
                    c <= 0;
                    s <= 0;
                end
            end

            // Compute LBP pattern
            else if (state == 1) begin
                for (int j = 0; j < LBP_SIZE + 1; j = j + 1) begin
                    sample_window[j] <= sample_memory[s + j][c];
                end
                
                bundler_sample_en <= 0;
                bundler_channel_lbp_en <= 0;
                state <= 2;
            end

            // Iterate through each channel, bind and add to channel-LBP bundler
            else if (state == 2) begin
                bundler_channel_lbp_in <= bound_ch_lbp;
                bundler_channel_lbp_en <= 1;
                bundler_channel_lbp_finish <= 0;

                if (c == NUM_CHS - 1) begin
                    c <= 0;
                    state <= 3;
                end 
                else begin
                    c <= c + 1;
                    state <= 1;
                end
            end

            else if (state == 3) begin
                bundler_channel_lbp_en <= 0;
                bundler_channel_lbp_finish <= 1;

                state <= 4;
            end

            // Finish channel-LBP bundler and iterate through samples
            else if (state == 4) begin
                bundler_channel_lbp_finish <= 0;

                bundler_sample_in <= bundler_channel_lbp_out;
                bundler_sample_en <= 1;

                if (s == WINDOW_SIZE - 1) begin
                    s <= 0;
                    state <= 5;
                end else begin
                    s <= s + 1;
                    state <= 1;
                end
            end

            // Finish sample bundler
            else if (state == 5) begin
                bundler_sample_en <= 0;
                bundler_sample_finish <= 1;
                state <= 6;
            end

            // Output window HV
            else if (state == 6) begin
                bundler_sample_finish <= 0;
                state <= 7;
            end
            else if (state == 7) begin
                window_hv <= bundler_sample_out;
                done <= 1;
                state <= 0;
            end
        end
    end

endmodule