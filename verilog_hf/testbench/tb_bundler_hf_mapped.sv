`timescale 1ns / 1ps
module tb_bundler_hf_mapped; 
    localparam T = 10;  // clock period in ms
    
    // General Params
    localparam DIMENSIONS = 10000;
    // Bundler Params
    localparam NUM_HVS = 17;

    // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [NUM_HVS - 1:0][DIMENSIONS-1:0] hv_array ;
    wire out;
    wire [DIMENSIONS - 1:0] hv_out;

    
    bundler_hf #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS)
    ) 
    u_bundler_hf(
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .hv_array  (hv_array),
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
        // $vcdplusfile("tb_bundler_odd.vpd");
        // $vcdpluson;
        $sdf_annotate("../mapped/bundler_hf_mapped.sdf", u_bundler_hf);
        nrst = 0;
        en = 0;
        hv_array[0] = 5'b0;
        hv_array[1] = 5'b0;
        hv_array[2] = 5'b0;
        hv_array[3] = 5'b0;
        hv_array[4] = 5'b0;
        hv_array[5] = 5'b0;
        hv_array[6] = 5'b0;
        hv_array[7] = 5'b0;
        hv_array[8] = 5'b0;
        hv_array[9] = 5'b0;
        hv_array[10] = 5'b0;
        hv_array[11] = 5'b0;
        hv_array[12] = 5'b0;
        hv_array[13] = 5'b0;
        hv_array[14] = 5'b0;
        hv_array[15] = 5'b0;
        hv_array[16] = 5'b0;
        # (50000000 - 5)
        // # (100 - 5)
        nrst = 1;
        en = 1;
        hv_array[0] = 5'b11101;
        hv_array[1] = 5'b10111;
        hv_array[2] = 5'b11111;
        hv_array[3] = 5'b00011;
        hv_array[4] = 5'b00011;
        hv_array[5] = 5'b01011;
        hv_array[6] = 5'b11101;
        hv_array[7] = 5'b10101;
        hv_array[8] = 5'b11101;
        hv_array[9] = 5'b10101;
        hv_array[10] = 5'b11101;
        hv_array[11] = 5'b10101;
        hv_array[12] = 5'b11101;
        hv_array[13] = 5'b10101;
        hv_array[14] = 5'b11101;
        hv_array[15] = 5'b10101;
        hv_array[16] = 5'b11101;
        # (5 + 5)
        en = 0;
        # (50000000 - 5 - 5)
        // # (100 - 5 - 5)
        en = 1;
        hv_array[0] = 5'b00010;
        hv_array[1] = 5'b10000;
        hv_array[2] = 5'b01000;
        hv_array[3] = 5'b10100;
        hv_array[4] = 5'b00100;
        hv_array[5] = 5'b00010;
        hv_array[6] = 5'b10000;
        hv_array[7] = 5'b01000;
        hv_array[8] = 5'b10100;
        hv_array[9] = 5'b00100;
        hv_array[10] = 5'b00010;
        hv_array[11] = 5'b10000;
        hv_array[12] = 5'b01000;
        hv_array[13] = 5'b10100;
        hv_array[14] = 5'b00100;
        hv_array[15] = 5'b00010;
        hv_array[16] = 5'b10000;
        # (5 + 5)
        en = 0;
        # (50000000 - 5 - 5)
        // # (100 - 5 - 5)
        en = 1;
        hv_array[0] = 5'b11011;
        hv_array[1] = 5'b11011;
        hv_array[2] = 5'b01111;
        hv_array[3] = 5'b10111;
        hv_array[4] = 5'b10101;
        hv_array[5] = 5'b11011;
        hv_array[6] = 5'b11011;
        hv_array[7] = 5'b01111;
        hv_array[8] = 5'b10111;
        hv_array[9] = 5'b10101;
        hv_array[10] = 5'b11011;
        hv_array[11] = 5'b11011;
        hv_array[12] = 5'b01111;
        hv_array[13] = 5'b10111;
        hv_array[14] = 5'b10101;
        hv_array[15] = 5'b11011;
        hv_array[16] = 5'b11011;
        # (5 + 5)
        en = 0;
        # (50000000 - 5)
        // # (100 - 5)
        en = 1;
        $finish;
    end
    endmodule