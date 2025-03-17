`timescale 1ns / 1ps
module gen_class (
    clk,
    nrst,
    op,
    trained_label,
    in_hv,
    ns_hv,
    s_hv,
    predicted_label
);
    // General parameters
    parameter DIMENSIONS = 10000;
     // Bundler params
    localparam NUM_HVS = 2;
    // Bunder LFSR params
    parameter NUM_REGS = 16;
    parameter SEED = 16'b1001010010110101;
    parameter NUM_VALS = 5;
    parameter START_VAL = 5'b10101;
    // Continuous memory params
    parameter OVERRIDE = 0;
    parameter OR_NS = 10000'b0;
    parameter OR_S = 10000'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    input clk;
    input nrst;
    input op;
    input trained_label;
    input [DIMENSIONS - 1:0] in_hv;
    output reg [DIMENSIONS - 1:0] ns_hv;
    output reg [DIMENSIONS - 1:0] s_hv;
    output reg predicted_label;

    reg en;
    reg label_out;

    assign en = ~op; 

    cont_mem #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_REGS(NUM_REGS),
        .SEED(SEED),
        .NUM_VALS(NUM_VALS),
        .START_VAL(START_VAL),
        .OVERRIDE(OVERRIDE),
        .OR_NS(OR_NS),
        .OR_S(OR_S)
    ) 
    sub_cont_mem(
        .clk  (clk),
        .nrst  (nrst),
        .hv  (in_hv),
        .en (en),
        .label (trained_label),
        .ns_hv (ns_hv),
        .s_hv (s_hv)
    );

    similarity #(
        .DIMENSIONS(DIMENSIONS)
    ) 
    u_similarity(
        .hv(in_hv),
        .ns_hv(ns_hv),
        .s_hv(s_hv),
        .label_out(label_out)
    );

    always @(posedge clk) begin
        if (!nrst) begin
            predicted_label <= 0;
        end else begin
            if (op == 1'b0) begin
                //
            end
            else begin
                predicted_label <= label_out;
            end
        end
    end
endmodule