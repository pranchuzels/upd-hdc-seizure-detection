`timescale 1ns / 1ps
module cont_mem_hf (
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
    input en;
    input [DIMENSIONS - 1:0] hv;
    input label;

    output reg [DIMENSIONS - 1:0] ns_hv;
    output reg [DIMENSIONS - 1:0] s_hv;

    reg bundler_en;
    reg [DIMENSIONS - 1:0] hv_array [NUM_HVS - 1:0];
    
    wire out;
    wire [DIMENSIONS - 1:0] hv_out;

    reg state;

    bundler_hf #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS)
    ) 
    mem_bundler_hf(
        .clk (clk),
        .nrst (nrst),
        .en (bundler_en),
        .hv_array  (hv_array),
        .out (out),
        .hvout  (hv_out)
    );

    always @(posedge clk) begin
        if (!nrst) begin
            out <= 1'b0;
            ns_hv <= START_NS_HV;
            s_hv <= START_S_HV;
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

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            ns_hv <= START_NS_HV;
            s_hv <= START_S_HV;
            state <= 1'b0;
            bundler_en <= 1'b0;

        end else begin
            if (!state) begin
                if (en) begin

                    if (!label) begin
                        hv_array[0] <= ns_hv;
                        hv_array[1] <= hv;
                    end else begin
                        hv_array[0] <= s_hv;
                        hv_array[1] <= hv;
                    end

                    state <= 1'b1;
                    bundler_en <= 1'b1;
                end
            end else begin
                
            end
        end

    end
endmodule