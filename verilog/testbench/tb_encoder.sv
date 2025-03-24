`timescale 1ms / 1us
module tb_encoder ();
    localparam T = 3.90625;  // clock period in ms

    // General params
    localparam DIMENSIONS = 10000;
    localparam NUM_CHS = 4;
    localparam WINDOW_SIZE = 4;
    localparam WINDOW_STEP = 2;

    // LBP params
    localparam LBP_SIZE = 6;
    localparam NUM_LBP = 64;

    reg clk;
    reg nrst;
    real samples [NUM_CHS - 1: 0];
    wire [DIMENSIONS - 1:0] window_hv;

    lbp_encoder #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_CHS(NUM_CHS),
        .WINDOW_SIZE(WINDOW_SIZE),
        .WINDOW_STEP(WINDOW_STEP),
        .LBP_SIZE(LBP_SIZE),
        .NUM_LBP(NUM_LBP)
    ) 
    u_lbp_encoder(   
        .clk (clk),
        .nrst (nrst),
        .samples (samples),
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
        $vcdplusfile("tb_encoder.vpd");
        $vcdpluson;
        nrst = 0;
        #7
        nrst = 1;
        samples[0] = 4.8840048840048835;
        samples[1] = -16.605616605616607;
        samples[2] = -25.2014652014652;
        samples[3] = -15.04273504273504;
        #3.90625
        samples[0] = 1.3675213675213669;
        samples[1] = -16.996336996336996;
        samples[2] = -26.76434676434676;
        samples[3] = -22.857142857142858;
        #3.90625
        samples[0] = -6.446886446886447;
        samples[1] = -19.340659340659343;
        samples[2] = -29.4993894993895;
        samples[3] = -22.466422466422465;
        #3.90625
        samples[0] = -16.605616605616607;
        samples[1] = -20.903540903540904;
        samples[2] = -29.4993894993895;
        samples[3] = -22.075702075702075;
        #3.90625
        samples[0] = -25.982905982905983;
        samples[1] = -20.903540903540904;
        samples[2] = -27.545787545787547;
        samples[3] = -22.857142857142858;
        #3.90625
        samples[0] = -42.39316239316239;
        samples[1] = -24.42002442002442;
        samples[2] = -28.32722832722833;
        samples[3] = -4.884004884004884;
        #3.90625
        samples[0] = -51.37973137973138;
        samples[1] = -14.261294261294262;
        samples[2] = -17.38705738705739;
        samples[3] = -17.38705738705739;
        #3.90625
        samples[0] = -37.313797313797316;
        samples[1] = -2.9304029304029307;
        samples[2] = -13.08913308913309;
        samples[3] = -38.876678876678874;
        #3.90625
        samples[0] = -24.810744810744808;
        samples[1] = 0.19536019536019467;
        samples[2] = -18.55921855921856;
        samples[3] = -36.14163614163614;
        #3.90625
        samples[0] = -17.38705738705739;
        samples[1] = 2.9304029304029293;
        samples[2] = -19.340659340659343;
        samples[3] = -38.485958485958484;
        #3.90625
        samples[0] = -6.056166056166057;
        samples[1] = 0.19536019536019467;
        samples[2] = -21.294261294261293;
        samples[3] = -35.75091575091575;
        #3.90625
        samples[0] = -1.7582417582417589;
        samples[1] = -5.274725274725275;
        samples[2] = -23.63858363858364;
        samples[3] = -22.466422466422465;
        #3.90625
        samples[0] = -5.665445665445666;
        samples[1] = -4.493284493284494;
        samples[2] = -22.466422466422465;
        samples[3] = -14.652014652014653;
        #3.90625
        samples[0] = -4.493284493284494;
        samples[1] = -3.3211233211233218;
        samples[2] = -20.903540903540904;
        samples[3] = -13.08913308913309;
        #3.90625
        $finish;
    end
endmodule