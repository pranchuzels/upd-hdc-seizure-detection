`timescale 1ns / 1ps
module tb_bundler_even; 
    localparam T = 10;  // clock period in ms
    
    // General Params
    localparam DIMENSIONS = 6;
    // Bundler Params
    localparam NUM_HVS = 6;
    localparam PAR_BITS = 2;

    // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [NUM_HVS - 1:0][DIMENSIONS-1:0] hv_array;
    wire out;
    wire [DIMENSIONS - 1:0] hv_out;

    
    bundler #(
        .DIMENSIONS(DIMENSIONS),
        .NUM_HVS(NUM_HVS),
        .PAR_BITS(PAR_BITS)
    ) 
    u_bundler (
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
        hv_array[0] = 6'b0;
        hv_array[1] = 6'b0;
        hv_array[2] = 6'b0;
        hv_array[3] = 6'b0;
        hv_array[4] = 6'b0;
        hv_array[5] = 6'b0;
        #105
        nrst = 1;
        en = 1;
        hv_array[0] = 6'b001101;
        hv_array[1] = 6'b000111;
        hv_array[2] = 6'b001111;
        hv_array[3] = 6'b100011;
        hv_array[4] = 6'b100011;
        hv_array[5] = 6'b111011;
        #10
        en = 0;
        #290
        en = 1;
        hv_array[0] = 6'b000010;
        hv_array[1] = 6'b010000;
        hv_array[2] = 6'b001000;
        hv_array[3] = 6'b010100;
        hv_array[4] = 6'b000100;
        hv_array[5] = 6'b010000;
        #10
        en = 0;
        #290
        en = 1;
        hv_array[0] = 6'b111011;
        hv_array[1] = 6'b011011;
        hv_array[2] = 6'b001111;
        hv_array[3] = 6'b010111;
        hv_array[4] = 6'b110101;
        hv_array[5] = 6'b111110;
        #10
        en = 0;
        #295
        $finish;
    end
    endmodule