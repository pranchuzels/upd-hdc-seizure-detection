`timescale 1ns / 1ps
module tb_lbp_encoder ();
    localparam T = 10;  // clock period in ns

    // General params
    localparam DIMENSIONS = 10000;
    localparam NUM_CHS = 4;
    localparam WINDOW_SIZE = 4;
    localparam WINDOW_STEP = 2;
    localparam SAMPLE_SIZE = 16;

    // LBP params
    localparam LBP_SIZE = 6;
    localparam NUM_LBP = 64;

    // Bundler params
    localparam COUNT_SIZE = 8;

    reg clk;
    reg nrst;
    reg en;
    reg [NUM_CHS - 1: 0][SAMPLE_SIZE - 1: 0] samples;
    wire done;
    wire [DIMENSIONS - 1:0] window_hv;

    lbp_encoder #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_CHS(NUM_CHS),
        .WINDOW_SIZE(WINDOW_SIZE),
        .WINDOW_STEP(WINDOW_STEP),
        .SAMPLE_SIZE(SAMPLE_SIZE),
        .LBP_SIZE(LBP_SIZE),
        .NUM_LBP(NUM_LBP)
    )
    u_lbp_encoder(   
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .samples (samples),
        .done (done),
        .window_hv (window_hv)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_lbp_encoder.vpd");
        // $vcdpluson;
        nrst = 0;
        en = 0;
        samples = 0;
        # (20 - 5)
        nrst = 1;

        en = 1;
        samples[0] = 16'b0000000000100111;
        samples[1] = 16'b1111111101111011;
        samples[2] = 16'b1111111100110110;
        samples[3] = 16'b1111111110001000;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b0000000000001011;
        samples[1] = 16'b1111111101111000;
        samples[2] = 16'b1111111100101010;
        samples[3] = 16'b1111111101001001;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111111001100;
        samples[1] = 16'b1111111101100101;
        samples[2] = 16'b1111111100010100;
        samples[3] = 16'b1111111101001100;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111101111011;
        samples[1] = 16'b1111111101011001;
        samples[2] = 16'b1111111100010100;
        samples[3] = 16'b1111111101001111;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111100110000;
        samples[1] = 16'b1111111101011001;
        samples[2] = 16'b1111111100100100;
        samples[3] = 16'b1111111101001001;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111010101101;
        samples[1] = 16'b1111111100111101;
        samples[2] = 16'b1111111100011101;
        samples[3] = 16'b1111111111011001;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111001100101;
        samples[1] = 16'b1111111110001110;
        samples[2] = 16'b1111111101110101;
        samples[3] = 16'b1111111101110101;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111011010101;
        samples[1] = 16'b1111111111101001;
        samples[2] = 16'b1111111110010111;
        samples[3] = 16'b1111111011001001;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)
        
        en = 1;
        samples[0] = 16'b1111111100111010;
        samples[1] = 16'b0000000000000010;
        samples[2] = 16'b1111111101101100;
        samples[3] = 16'b1111111011011111;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111101110101;
        samples[1] = 16'b0000000000010111;
        samples[2] = 16'b1111111101100101;
        samples[3] = 16'b1111111011001100;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111111010000;
        samples[1] = 16'b0000000000000010;
        samples[2] = 16'b1111111101010110;
        samples[3] = 16'b1111111011100010;
        # (5 + 5)
        en = 0;
        # (250 - 5 - 5)

        en = 1;
        samples[0] = 16'b1111111111110010;
        samples[1] = 16'b1111111111010110;
        samples[2] = 16'b1111111101000011;
        samples[3] = 16'b1111111101001100;
        # (5 + 5)
        en = 0;
        # (250 - 5)
        $finish;
    end
endmodule