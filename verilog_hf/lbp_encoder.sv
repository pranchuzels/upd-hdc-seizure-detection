`timescale 1ms / 1us
module lbp_encoder (
    clk,
    nrst,
    samples,
    window_hv,
    out_en
);

    // General params
    parameter DIMENSIONS = 10000;
    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    
    // LBP-only params
    parameter LBP_SIZE = 6;
    parameter NUM_LBP = 64;

    input clk;
    input nrst;

    // Samples currently set as real numbers; change to accept fixed-representation!
    input [16 - 1: 0] samples [NUM_CHS - 1: 0]; // 256 + 6 = 262

    output reg [DIMENSIONS - 1:0] window_hv;
    output wire out_en;

    // Feature Item HVs
    wire [DIMENSIONS - 1:0] ch_hv [17 - 1: 0];
    wire [DIMENSIONS - 1:0] lbp_hv [64 - 1: 0];

    /////////////////// LBP Declarations ////////////////////////////

    // LBP-only registers
    reg isFirstSample = 1;
    reg isFirstWindow = 1;
    reg [$clog2(WINDOW_SIZE + LBP_SIZE): 0] sampleCounter = 0;
    reg [16 - 1: 0] sample_memory [NUM_CHS - 1: 0][LBP_SIZE: 0];
    reg [LBP_SIZE - 1: 0] sample_pattern [NUM_CHS - 1: 0];
    reg [DIMENSIONS - 1: 0] sample_lbp_hv [NUM_CHS - 1: 0];
    reg [DIMENSIONS - 1: 0] lbp_ch_bind [NUM_CHS - 1: 0];
    reg [DIMENSIONS - 1: 0] curr_sample_hv;
    reg [DIMENSIONS - 1: 0] samples_hv [WINDOW_SIZE - 1: 0];
    reg [DIMENSIONS - 1: 0] window_bundler_out;
    reg window_out = 0;
    assign out_en = window_out;

    integer i;
    integer j;

    // Item memory
    item_mem enc_item_mem(
        .ch_hv (ch_hv),
        .lbp_hv  (lbp_hv)
    );

    // Generate channel-lbp binding
    generate
        genvar c;
        for (c = 0; c < NUM_CHS; c = c + 1) begin
            binder #(
                .DIMENSIONS(DIMENSIONS)
            ) 
            lbp_binder(
                .hv1  (sample_lbp_hv[c]),
                .hv2 (ch_hv[c]),
                .hvout  (lbp_ch_bind[c])
            );
        end
    endgenerate

    // LBP-Channel HVs bundler
    bundler_ch_v2 #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_CHS)
    ) 
    lbp_ch_bundler_ch(
        .hv_array  (lbp_ch_bind),
        .hvout  (curr_sample_hv)
    );

    // Samples hv to window hv bundler
    bundler_ch_v2 #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(WINDOW_SIZE)
    ) 
    window_bundler_ch(
        .hv_array  (samples_hv),
        .hvout  (window_bundler_out)
    );

    always @(posedge clk) begin
        if (!nrst) begin
            
            for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
                samples_hv[i] = 0;
            end
            isFirstSample <= 1;
            isFirstWindow <= 1;
            sampleCounter <= 0;
            window_out = 0;
        end else begin
            if (isFirstSample) begin

                // Shift sample value memory
                for (i = 0; i < NUM_CHS; i = i + 1) begin
                    for (j = 0; j < LBP_SIZE; j = j + 1) begin
                        sample_memory[i][j] = sample_memory[i][j + 1];
                    end
                end
                for (i = 0; i < NUM_CHS; i = i + 1) begin
                    sample_memory[i][LBP_SIZE] = samples[i]; // Get sample inputs
                end

                if (sampleCounter == LBP_SIZE - 1) begin
                    isFirstSample <= 0;
                    sampleCounter <= 0;
                end else begin
                    sampleCounter <= sampleCounter + 1;
                end
                
            end else begin
                
                // Shift sample value memory
                for (i = 0; i < NUM_CHS; i = i + 1) begin
                    for (j = 0; j < LBP_SIZE; j = j + 1) begin
                        sample_memory[i][j] = sample_memory[i][j + 1];
                    end
                end

                // Shift sample HV memory
                for (i = 0; i < WINDOW_SIZE - 1; i = i + 1) begin
                    samples_hv[i] = samples_hv[i + 1];
                end

                ///////////// GENERAL PROCESS ////////////////////
                for (i = 0; i < NUM_CHS; i = i + 1) begin
                    sample_memory[i][LBP_SIZE] = samples[i]; // Get sample inputs

                    // Get LBP pattern of channel's current samples
                    for (j = 0; j < LBP_SIZE; j = j + 1) begin
                        if (((sample_memory[i][j] + (~sample_memory[i][j + 1]) + 1) & 16'h8000) == 16'h8000) begin
                            sample_pattern[i][LBP_SIZE - j - 1] = 1'b1;
                        end else if (((sample_memory[i][j] + (~sample_memory[i][j + 1]) + 1) & 16'h8000)  == 16'h0000) begin
                            sample_pattern[i][LBP_SIZE - j - 1] = 1'b0;
                        end else begin
                            sample_pattern[i][LBP_SIZE - j - 1] = 1'b1; // change later
                        end
                    end
                    sample_lbp_hv[i] = lbp_hv[sample_pattern[i]]; // Get LBP hv
                end

                // Per channel-LBP HV binding and all channel bundling 
                // is done thru submodules from above

                // samples_hv[WINDOW_SIZE - 1] = curr_sample_hv;
                // samples_hv 

                //////////// OUTPUT PROCESS ////////////////

                // if current window is complete
                if ((sampleCounter == WINDOW_SIZE - 1 && isFirstWindow) || 
                (sampleCounter == WINDOW_STEP - 1 && !isFirstWindow)) begin
                    window_out = 1;
                    
                    sampleCounter <= 0; // reset sampleCounter
                    if (isFirstWindow) begin
                        isFirstWindow <= 0;
                    end
                end 
                
                else begin
                    window_out = 0;
                    sampleCounter <= sampleCounter + 1; // add sampleCounter
                end

                //////////// Do finishing processes ////////////////
            end
        end
    end

always @(curr_sample_hv) begin
    samples_hv[WINDOW_SIZE - 1] = curr_sample_hv;
end

always @(*) begin
    if (window_out) begin
        window_hv = window_bundler_out;
    end else begin
        //window_hv = window_hv;
    end
end

endmodule