`timescale 1ns / 1ps
module cont_mem (
    clk,
    nrst,
    en,
    hv,
    label,
    ns_hv,
    s_hv
);
    // General params
    parameter DIMENSIONS = 10000;

    // Bundler params
    localparam NUM_HVS = 2;

    // Continuous memory params
    parameter START_NS_HV = 10000'b0;
    parameter START_S_HV = 10000'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    input clk;
    input nrst;
    input [DIMENSIONS - 1:0] hv;
    input en;
    input label;
    output reg [DIMENSIONS - 1:0] ns_hv = 0;
    output reg [DIMENSIONS - 1:0] s_hv = 0;

    reg [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    wire [DIMENSIONS - 1:0] hv_out;

    bundler_ch_v2 #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS)
    ) 
    mem_bundler_ch(
        .hv_array  (hv_array),
        .hvout  (hv_out)
    );

    always @(posedge clk) begin
        if (!nrst) begin
            
        end else begin
            if (en == 1'b1) begin
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

    always @(hv_out or nrst) begin
        if (!nrst) begin
            ns_hv = START_NS_HV;
            s_hv = START_S_HV;
        end else begin
            if (en == 1'b1) begin
                if (label == 1'b0)
                    ns_hv = hv_out;
                else
                    s_hv = hv_out;
            end
            else begin
                // ns_hv = ns_hv;
                // s_hv = s_hv;
            end
        end

    end
endmodule