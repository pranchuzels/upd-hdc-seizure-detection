`timescale 1ms / 1us
module gen_class (
    clk,
    nrst,
    en,
    in_hv,
    op,
    trained_label,
    
    ns_hv,
    s_hv,
    predicted_label
);
    // General parameters
    parameter DIMENSIONS = 10000;
     // Continuous Memory Bundler params
    localparam NUM_HVS = 2;

    // Continuous memory params
    parameter START_NS_HV = 10000'b0;
    parameter START_S_HV = 10000'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    input clk;
    input nrst;
    input [DIMENSIONS - 1:0] in_hv;
    input en;
    input op;
    input trained_label;
    
    output reg [DIMENSIONS - 1:0] ns_hv;
    output reg [DIMENSIONS - 1:0] s_hv;
    output reg predicted_label;

    reg [DIMENSIONS - 1:0] in_train;
    reg [DIMENSIONS - 1:0] in_test;

    wire en_train;
    assign en_train = ~op; 

    cont_mem #(
        .DIMENSIONS(DIMENSIONS),
        .START_NS_HV(START_NS_HV),
        .START_S_HV(START_S_HV)
    ) 
    sub_cont_mem(
        .clk  (clk),
        .nrst  (nrst),
        .hv  (in_train),
        .en (en_train),
        .label (trained_label),
        .ns_hv (ns_hv),
        .s_hv (s_hv)
    );

    similarity #(
        .DIMENSIONS(DIMENSIONS)
    ) 
    u_similarity(
        .hv(in_test),
        .ns_hv(ns_hv),
        .s_hv(s_hv),
        .label_out(predicted_label)
    );

    always @(posedge clk) begin
        if (!nrst) begin
            in_train = 0;
            in_test = 0;
        end else begin
            if (en) begin
                if (op == 1'b0) begin
                    in_train = in_hv;
                end
                else begin
                    in_test = in_hv;
                end
            end
            
        end
    end
endmodule