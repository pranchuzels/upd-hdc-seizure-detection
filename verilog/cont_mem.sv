`timescale 1ns / 1ps
module cont_mem (
    clk,
    nrst,
    hv,
    en,
    label,
    ns_hv,
    s_hv
);
    // General params
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
    input [DIMENSIONS - 1:0] hv;
    input en;
    input label;
    output reg [DIMENSIONS - 1:0] ns_hv = 0;
    output reg [DIMENSIONS - 1:0] s_hv = 0;

    reg [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    wire [DIMENSIONS - 1:0] hv_out;

    bundler_ch #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS),
        .NUM_REGS(NUM_REGS),
        .SEED(SEED),
        .NUM_VALS(NUM_VALS),
        .START_VAL(START_VAL)
    ) 
    mem_bundler_ch(
        .clk  (clk),
        .nrst  (nrst),
        .hv_array  (hv_array),
        .hvout  (hv_out)
    );

    always @(posedge clk) begin
        if (!nrst) begin
            ns_hv <= 0;
            s_hv <= 0;
        end else begin
            if (OVERRIDE == 1'b1) begin
                ns_hv = OR_NS;
                s_hv = OR_S;
            end
            else if (en == 1'b1) begin
                if (label == 1'b0) begin
                    hv_array[0] = ns_hv;
                    hv_array[1] = hv;
                end
                else begin
                    hv_array[0] = s_hv;
                    hv_array[1] = hv;
                end
            end
        end
    end

    always @(hv_out) begin
        if (label == 1'b0)
            ns_hv <= hv_out;
        else
            s_hv <= hv_out;
    end
endmodule