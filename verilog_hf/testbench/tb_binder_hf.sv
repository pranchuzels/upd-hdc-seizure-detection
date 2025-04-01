`timescale 1ns / 1ps
 
module tb_binder_hf;
    localparam T = 10;  // clock period in ms

    localparam DIMENSIONS = 5;

    reg clk;
    reg nrst;
    reg en;
    reg [DIMENSIONS - 1:0] hv1;
    reg [DIMENSIONS - 1:0] hv2;
    wire out;
    wire [DIMENSIONS - 1:0] hv_out;
    
    binder_hf #(
        .DIMENSIONS(DIMENSIONS)
    ) 
    u_binder(
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .hv1  (hv1),
        .hv2 (hv2),
        .out (out),
        .hv_out  (hv_out)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_binder.vpd");
        // $vcdpluson;
        nrst = 0;
        en = 0;
        hv1 = 0;
        hv2 = 0;
        #105
        nrst = 1;
        en = 1;
        hv1 = 5'b11101;
        hv2 = 5'b10010;
        #10
        en = 0;
        #90
        en = 1;
        hv1 = 5'b00101;
        hv2 = 5'b00111;
        #10
        en = 0;
        #90
        en = 1;
        hv1 = 5'b11111;
        hv2 = 5'b10110;
        #10
        en = 0;
        #95
        $finish;
    end
endmodule