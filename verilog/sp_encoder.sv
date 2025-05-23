`timescale 1ns / 1ps
module sp_encoder (
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
    parameter NUM_SPI = 6;
    parameter NUM_SPV = 64;

    // Bundler params
    parameter COUNT_SIZE = 8;
    
    input clk;
    input nrst;
    input en;
    input [NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    output reg done;
    output reg [DIMENSIONS - 1:0] window_hv;

    reg [3:0] state;


    // Windower
    wire windower_done;
    wire [WINDOW_SIZE - 1: 0][NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] sample_memory;
    windower sp_windower (
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .samples(samples),
        .done(windower_done),
        .sample_memory(sample_memory)
    );

    // ASSUMED SP extractor
    reg [$clog2(NUM_CHS) - 1: 0] c;
    reg [$clog2(NUM_SPI) - 1: 0] spi;
    reg sp_extractor_en;
    logic [WINDOW_SIZE - 1: 0][SAMPLE_SIZE - 1: 0] sp_extractor_samples;
    wire sp_extractor_done;
    wire [$clog2(NUM_SPV) - 1:0] spv;

    always_comb begin
        for (int i = 0; i < WINDOW_SIZE; i = i + 1)
            sp_extractor_samples[i] = sample_memory[i][c];
    end
    
    sp_extractor u_sp_extractor(   
        .clk (clk),
        .nrst (nrst),
        .en (sp_extractor_en),
        .spi (spi),
        .c (c),
        .samples (sp_extractor_samples),
        .done (sp_extractor_done),
        .spv (spv)
    );
    
    // Item Mem
    wire [DIMENSIONS - 1:0] ch_hv;
    wire [DIMENSIONS - 1:0] spv_hv;
    wire [DIMENSIONS - 1:0] spi_hv;
    item_mem_2 enc_item_mem_2(
        .c (c),
        .spv (spv),
        .spi (spi),
        .ch_hv (ch_hv),
        .spv_hv  (spv_hv),
        .spi_hv  (spi_hv)
    );

    // Binder
    wire [DIMENSIONS - 1: 0] bound_spv_spi;
    binder spv_spi_binder (
        .hv_1(spv_hv),
        .hv_2(spi_hv),
        .hv_out(bound_spv_spi)
    );

    // SPV-SPI Bundler
    reg bundler_spv_spi_en;
    reg [DIMENSIONS - 1: 0] bundler_spv_spi_in;
    reg bundler_spv_spi_finish;
    wire [DIMENSIONS - 1: 0] bundler_spv_spi_out;
    bundler_cont_tie  bundler_spv_spi (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_spv_spi_en),
        .finish(bundler_spv_spi_finish),
        .hv_in(bundler_spv_spi_in),
        .hv_out(bundler_spv_spi_out)
    );

    // Binder
    wire [DIMENSIONS - 1: 0] bound_sp_ch;
    binder sp_ch_binder (
        .hv_1(bundler_spv_spi_out),
        .hv_2(ch_hv),
        .hv_out(bound_sp_ch)
    );

    //SP-Ch Bundler
    reg bundler_sp_ch_en;
    reg bundler_sp_ch_finish;
    reg [DIMENSIONS - 1: 0] bundler_sp_ch_in;
    wire [DIMENSIONS - 1: 0] bundler_sp_ch_out;
    bundler_cont bundler_sp_ch (
        .clk(clk),
        .nrst(nrst),
        .en(bundler_sp_ch_en),
        .finish(bundler_sp_ch_finish),
        .hv_in(bundler_sp_ch_in),
        .hv_out(bundler_sp_ch_out)
    );

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            done <= 0;
            window_hv <= 0;
            state <= 0;

            c <= 0;
            spi <= 0;
            sp_extractor_en <= 0;

            bundler_spv_spi_en <= 0;
            bundler_spv_spi_in <= 0;
            bundler_spv_spi_finish <= 0;

        end else begin
            if (state == 0) begin
                done <= 0;
                if (windower_done) begin
                    state <= 1;
                    
                    sp_extractor_en <= 1;
                end
            end

            // Wait for SP extractor to finish, then comb. bind spv_hv and spi_hv
            else if (state == 1) begin
                bundler_spv_spi_en <= 0;
                bundler_sp_ch_en <= 0;
                sp_extractor_en <= 0;
                if (sp_extractor_done) begin
                    state <= 2;
                end
            end

            // Iterate through each channel, bind and add to SPV-SPI bundler
            else if (state == 2) begin
                bundler_spv_spi_in <= bound_spv_spi;
                bundler_spv_spi_en <= 1;
                bundler_spv_spi_finish <= 0;

                if (spi == NUM_SPI - 1) begin
                    spi <= 0;
                    state <= 3;
                end 
                else begin
                    spi <= spi + 1;
                    sp_extractor_en <= 1;
                    state <= 1;
                end
            end

            // Finish spv_spi bundler
            else if (state == 3) begin
                bundler_spv_spi_en <= 0;
                bundler_spv_spi_finish <= 1;

                state <= 4;
            end

            // Finish spv-spi bundler, wait for binder to bind sp_ch_hv
            else if (state == 4) begin
                bundler_spv_spi_finish <= 0;
                state <= 5;
            end

            // Iterate through all channels and add to channel-sp bundler
            else if (state == 5) begin
                bundler_sp_ch_in <= bound_sp_ch;
                bundler_sp_ch_en <= 1;

                if (c == NUM_CHS - 1) begin
                    c <= 0;
                    state <= 6;
                end else begin
                    c <= c + 1;
                    state <= 1;

                    sp_extractor_en <= 1;
                end
            end

            // Finish channel-sp bundler
            else if (state == 6) begin
                bundler_sp_ch_en <= 0;
                bundler_sp_ch_finish <= 1;

                state <= 7;
            end

            // Output window HV
            else if (state == 7) begin
                bundler_sp_ch_finish <= 0;
                state <= 8;
            end
            else if (state == 8) begin
                window_hv <= bundler_sp_ch_out;
                done <= 1;
                state <= 0;
            end
        end
    end

endmodule