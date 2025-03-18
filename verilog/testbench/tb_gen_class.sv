`timescale 1ns / 1ps
module tb_gen_class ();
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
    reg op;
    reg trained_label;
    reg [DIMENSIONS - 1:0] in_hv;
    wire [DIMENSIONS - 1:0] ns_hv;
    wire [DIMENSIONS - 1:0] s_hv;
    wire predicted_label;

    gen_class #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_REGS(NUM_REGS),
        .SEED(SEED),
        .NUM_VALS(NUM_VALS),
        .START_VAL(START_VAL),
        .OVERRIDE(OVERRIDE),
        .OR_NS(OR_NS),
        .OR_S(OR_S)
    ) 
    u_gen_class(
        .clk  (clk),
        .nrst  (nrst),
        .op  (op),
        .trained_label (trained_label),
        .in_hv (in_hv),
        .ns_hv (ns_hv),
        .s_hv (s_hv),
        .predicted_label (predicted_label)
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
        in_hv = 5'b0;
        op = 0;
        trained_label = 0;
        #25
        nrst = 1;
        in_hv = 5'b11111;
        trained_label = 1;
        #10
        in_hv = 5'b10001;
        trained_label = 0;
        #10
        in_hv = 5'b11111;
        trained_label = 1;
        #10
        op = 1;
        in_hv = 5'b11111;
        #10
        op = 1;
        in_hv = 5'b11101;
        #10
        op = 1;
        in_hv = 5'b00111;
        #10
        op = 1;
        in_hv = 5'b00000;
        #10
        op = 1;
        in_hv = 5'b00001;
        #30
        $finish;
    end
endmodule