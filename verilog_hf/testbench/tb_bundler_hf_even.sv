`timescale 1ns / 1ps
module tb_bundler_hf_even; 
    localparam T = 10;  // clock period in ms
    
    // General Params
    localparam DIMENSIONS = 5;
    // Bundler Params
    localparam NUM_HVS = 6;

    // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [DIMENSIONS-1:0] hv_array [NUM_HVS - 1:0];
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
        nrst = 0;
        en = 0;
        hv_array[0] = 5'b0;
        hv_array[1] = 5'b0;
        hv_array[2] = 5'b0;
        hv_array[3] = 5'b0;
        hv_array[4] = 5'b0;
        hv_array[5] = 5'b0;
        #105
        nrst = 1;
        en = 1;
        hv_array[0] = 5'b01101;
        hv_array[1] = 5'b00111;
        hv_array[2] = 5'b01111;
        hv_array[3] = 5'b10011;
        hv_array[4] = 5'b10011;
        hv_array[5] = 5'b11011;
        #10
        en = 0;
        #90
        en = 1;
        hv_array[0] = 5'b00010;
        hv_array[1] = 5'b10000;
        hv_array[2] = 5'b01000;
        hv_array[3] = 5'b10100;
        hv_array[4] = 5'b00100;
        hv_array[5] = 5'b10000;
        #10
        en = 0;
        #90
        en = 1;
        hv_array[0] = 5'b11011;
        hv_array[1] = 5'b11011;
        hv_array[2] = 5'b01111;
        hv_array[3] = 5'b10111;
        hv_array[4] = 5'b10101;
        hv_array[4] = 5'b11111;
        #10
        en = 0;
        #95
        $finish;
    end
    endmodule