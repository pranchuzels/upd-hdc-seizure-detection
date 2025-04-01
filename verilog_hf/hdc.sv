`timescale 1ms / 1us
module hdc (
    clk,
    nrst,
    samples,
    op,
    trained_label,
    
    ns_hv,
    s_hv,
    predicted_label
);
    // General parameters
    parameter DIMENSIONS = 10000;
    parameter NUM_CHS = 17;
    parameter WINDOW_SIZE = 256;
    parameter WINDOW_STEP = 128;
    
    // LBP-only params
    parameter LBP_SIZE = 6;
    parameter NUM_LBP = 64;

    // Continuous Memory params
    parameter START_NS_HV = 10000'b0;
    parameter START_S_HV = 10000'b0;

    input clk;
    input nrst;
    input [16 - 1: 0] samples [NUM_CHS - 1: 0];
    input op;
    input trained_label;
    
    output reg [DIMENSIONS - 1:0] ns_hv;
    output reg [DIMENSIONS - 1:0] s_hv;
    output reg predicted_label;

    wire [DIMENSIONS - 1:0] window_hv;
    wire out_en;

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
        .window_hv (window_hv),
        .out_en (out_en)
    );

    gen_class #(
        .DIMENSIONS(DIMENSIONS),
        .START_NS_HV(START_NS_HV),
        .START_S_HV(START_S_HV)
    ) 
    u_gen_class(
        .clk  (clk),
        .nrst  (nrst),
        .en (out_en),
        .in_hv (window_hv),
        .op  (op),
        .trained_label (trained_label),
        
        .ns_hv (ns_hv),
        .s_hv (s_hv),
        .predicted_label (predicted_label)
    );

endmodule