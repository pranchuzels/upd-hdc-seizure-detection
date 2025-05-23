`timescale 1ns / 1ps
module tb_bundler_cont ();
    localparam T = 10;  // clock period in ns


    parameter DIMENSIONS = 6;
    parameter PAR_BITS = 2;

    reg clk;
    reg nrst;
    reg en;
    reg [DIMENSIONS - 1:0] hv_train;
    wire done;
    wire [DIMENSIONS - 1:0] hv_out;

    bundler_cont #(
        .DIMENSIONS(DIMENSIONS),
        .PAR_BITS(PAR_BITS)
    ) 
    u_bundler_cont (
        .clk  (clk),
        .nrst  (nrst),
        .en (en),
        .hv_train (hv_train),
        .done (done),
        .hv_out (hv_out)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        nrst = 0;
        en = 0;
        hv_train = 6'b0;
        # (20 - 5)
        nrst = 1;

        en = 1;
        hv_train = 6'b100001;
        # (5 + 5)
        en = 0;
        # (60 - 5 - 5)

        en = 1;
        hv_train = 6'b110001;
        # (5 + 5)
        en = 0;
        # (60 - 5 - 5)

        en = 1;
        hv_train = 6'b111111;
        # (5 + 5)
        en = 0;
        # (60 - 5)
        $finish;
    end
endmodule