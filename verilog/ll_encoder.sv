`timescale 1ns / 1ps
module ll_encoder (
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
    parameter NUM_LL = 64;

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
    windower ll_windower (
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .samples(samples),
        .done(windower_done),
        .sample_memory(sample_memory)
    );

    // LL extractor
    reg [$clog2(NUM_CHS) - 1: 0] c;
    reg ll_extractor_en;
    logic [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] ll_extractor_samples;
    wire ll_extractor_done;
    wire [$clog2(NUM_LL) - 1:0] ll;

    always_comb begin
        for (int i = 0; i < WINDOW_SIZE; i = i + 1)
            ll_extractor_samples[i] = sample_memory[i][c];
    end
    
    ll_extractor u_ll_extractor(   
        .clk (clk),
        .nrst (nrst),
        .en (ll_extractor_en),
        .samples (ll_extractor_samples),
        .done (ll_extractor_done),
        .ll (ll)
    );
    
    // Item Mem
    wire [DIMENSIONS - 1:0] ch_hv;
    wire [DIMENSIONS - 1:0] ll_hv;
    item_mem_4 enc_item_mem_4(
        .c (c),
        .ll (ll),
        .ch_hv (ch_hv),
        .ll_hv  (ll_hv)
    );

    // Binder
    wire [DIMENSIONS - 1: 0] bound_ch_ll;
    binder channel_ll_binder (
        .hv_1(ch_hv),
        .hv_2(ll_hv),
        .hv_out(bound_ch_ll)
    );

    // Ch-LL Bundler
    reg bundler_channel_ll_en;
    reg [DIMENSIONS - 1: 0] bundler_channel_ll_in;
    reg bundler_channel_ll_finish;
    wire [DIMENSIONS - 1: 0] bundler_channel_ll_out;

    bundler_cont  bundler_channel_ll (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_channel_ll_en),
        .finish(bundler_channel_ll_finish),
        .hv_in(bundler_channel_ll_in),
        .hv_out(bundler_channel_ll_out)
    );


    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 0;
            window_hv <= 0;
            state <= 0;

            c <= 0;
            ll_extractor_en <= 0;

            bundler_channel_ll_en <= 0;
            bundler_channel_ll_in <= 0;
            bundler_channel_ll_finish <= 0;

        end else begin
            if (state == 0) begin
                done <= 0;
                if (windower_done) begin
                    state <= 1;
                    
                    ll_extractor_en <= 1;
                end
            end

            // Wait for LL extractor to finish, then comb. bind ch_hv and ll_hv
            else if (state == 1) begin
                bundler_channel_ll_en <= 0;
                ll_extractor_en <= 0;
                if (ll_extractor_done) begin
                    state <= 2;
                end
            end

            // Iterate through each channel, bind and add to channel-LBP bundler
            else if (state == 2) begin
                bundler_channel_ll_in <= bound_ch_ll;
                bundler_channel_ll_en <= 1;
                bundler_channel_ll_finish <= 0;

                if (c == NUM_CHS - 1) begin
                    c <= 0;
                    state <= 3;
                end 
                else begin
                    c <= c + 1;
                    ll_extractor_en <= 1;
                    state <= 1;
                end
            end

            // Finish channel_ll bundler
            else if (state == 3) begin
                bundler_channel_ll_en <= 0;
                bundler_channel_ll_finish <= 1;

                state <= 4;
            end

            // Output window HV
            else if (state == 4) begin
                bundler_channel_ll_finish <= 0;
                state <= 5;
            end
            else if (state == 5) begin
                window_hv <= bundler_channel_ll_out;
                done <= 1;
                state <= 0;
            end
        end
    end

endmodule