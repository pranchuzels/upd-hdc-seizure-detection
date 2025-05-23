`timescale 1ns / 1ps
module ma_encoder (
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
    parameter NUM_MA = 64;

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
    wire [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] sample_memory;
    windower ma_windower (
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .samples(samples),
        .done(windower_done),
        .sample_memory(sample_memory)
    );

    // MA extractor
    reg [$clog2(NUM_CHS) - 1: 0] c;
    reg ma_extractor_en;
    logic [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] ma_extractor_samples;
    wire ma_extractor_done;
    wire [$clog2(NUM_MA) - 1:0] ma;

    always_comb begin
        for (int i = 0; i < WINDOW_SIZE; i = i + 1)
            ma_extractor_samples[i] = sample_memory[i][c];
    end
    
    ma_extractor u_ma_extractor(   
        .clk (clk),
        .nrst (nrst),
        .en (ma_extractor_en),
        .samples (ma_extractor_samples),
        .done (ma_extractor_done),
        .ma (ma)
    );
    
    // Item Mem
    wire [DIMENSIONS - 1:0] ch_hv;
    wire [DIMENSIONS - 1:0] ma_hv;
    item_mem_3 enc_item_mem_3(
        .c (c),
        .ma (ma),
        .ch_hv (ch_hv),
        .ma_hv  (ma_hv)
    );

    // Binder
    wire [DIMENSIONS - 1: 0] bound_ch_ma;
    binder channel_ma_binder (
        .hv_1(ch_hv),
        .hv_2(ma_hv),
        .hv_out(bound_ch_ma)
    );

    // Ch-ma Bundler
    reg bundler_channel_ma_en;
    reg [DIMENSIONS - 1: 0] bundler_channel_ma_in;
    reg bundler_channel_ma_finish;
    wire [DIMENSIONS - 1: 0] bundler_channel_ma_out;

    bundler_cont  bundler_channel_ma (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_channel_ma_en),
        .finish(bundler_channel_ma_finish),
        .hv_in(bundler_channel_ma_in),
        .hv_out(bundler_channel_ma_out)
    );


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 0;
            window_hv <= 0;
            state <= 0;

            c <= 0;
            ma_extractor_en <= 0;

            bundler_channel_ma_en <= 0;
            bundler_channel_ma_in <= 0;
            bundler_channel_ma_finish <= 0;

        end else begin
            if (state == 0) begin
                done <= 0;
                if (windower_done) begin
                    state <= 1;
                    
                    ma_extractor_en <= 1;
                end
            end

            // Wait for MA extractor to finish, then comb. bind ch_hv and ma_hv
            else if (state == 1) begin
                bundler_channel_ma_en <= 0;
                ma_extractor_en <= 0;
                if (ma_extractor_done) begin
                    state <= 2;
                end
            end

            // Iterate through each channel, bind and add to channel-LBP bundler
            else if (state == 2) begin
                bundler_channel_ma_in <= bound_ch_ma;
                bundler_channel_ma_en <= 1;
                bundler_channel_ma_finish <= 0;

                if (c == NUM_CHS - 1) begin
                    c <= 0;
                    state <= 3;
                end 
                else begin
                    c <= c + 1;
                    ma_extractor_en <= 1;
                    state <= 1;
                end
            end

            // Finish channel_ma bundler
            else if (state == 3) begin
                bundler_channel_ma_en <= 0;
                bundler_channel_ma_finish <= 1;

                state <= 4;
            end

            // Output window HV
            else if (state == 4) begin
                bundler_channel_ma_finish <= 0;
                state <= 5;
            end
            else if (state == 5) begin
                window_hv <= bundler_channel_ma_out;
                done <= 1;
                state <= 0;
            end
        end
    end

endmodule