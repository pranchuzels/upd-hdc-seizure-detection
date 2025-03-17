`timescale 1ns / 1ps
module tb_cont_mem ();
    localparam T = 10;  // clock period in ns


    // General params
    parameter DIMENSIONS = 5;
    // Bunder LFSR params
    parameter NUM_REGS = 16;
    parameter SEED = 16'b1001010010110101;
    parameter NUM_VALS = 5;
    parameter START_VAL = 5'b10101;
    // Continuous memory params
    parameter OVERRIDE = 0;
    parameter OR_NS = 10000'b0;
    parameter OR_S = 10000'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    reg clk;
    reg nrst;
    reg [DIMENSIONS - 1:0] hv;
    reg en;
    reg label;
    wire [DIMENSIONS - 1:0] ns_hv;
    wire [DIMENSIONS - 1:0] s_hv;

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
    u_cont_mem(
        .clk  (clk),
        .nrst  (nrst),
        .hv  (hv),
        .en (en),
        .label (label),
        .ns_hv (ns_hv),
        .s_hv (s_hv)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        $vcdplusfile("tb_cont_mem.vpd");
        $vcdpluson;
        nrst = 0;
        hv = 5'b0;
        en = 0;
        label = 0;
        #25
        nrst = 1;
        hv = 5'b11111;
        en = 1;
        label = 1;
        #10
        hv = 5'b10001;
        en = 1;
        label = 0;
        #10
        hv = 5'b11111;
        en = 1;
        label = 1;
        #30
        $finish;
    end
endmodule