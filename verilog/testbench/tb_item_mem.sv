`timescale 1ns / 1ps
module tb_cont_mem ();
    localparam T = 10;  // clock period in ns

    localparam DIMENSIONS = 10000;
    localparam NUM_LBP = 64;

    reg clk;
    wire [DIMENSIONS - 1:0] lbp_hv [NUM_LBP - 1: 0];

    item_mem #() 
    u_item_mem(
        .lbp_hv  (lbp_hv)
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
        #30
        $finish;
    end
endmodule