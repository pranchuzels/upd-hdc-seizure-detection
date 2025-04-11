`timescale 1ns / 1ps
module tb_bundler_bit_odd; 
    localparam T = 10;  // clock period in ms
    
    // Bundler Params
    localparam NUM_HVS = 5;

    // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg bits [NUM_HVS - 1:0];
    reg tie_1;
    reg tie_2;
    wire done;
    wire out_bit;

    
    bundler_bit #(
        .NUM_HVS(NUM_HVS)
    ) 
    u_bundler_bit (
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .bits  (bits),
        .tie_1 (tie_1),
        .tie_2 (tie_2),
        .done (done),
        .out_bit  (out_bit)
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
        bits[0] = 0;
        bits[1] = 0;
        bits[2] = 0;
        bits[3] = 0;
        bits[4] = 0;
        tie_1 = 0;
        tie_2 = 0;
        #105
        nrst = 1;
        en = 1;
        bits[0] = 0;
        bits[1] = 0;
        bits[2] = 0;
        bits[3] = 0;
        bits[4] = 0;
        tie_1 = 0;
        tie_2 = 0;
        #10
        en = 0;
        #90
        en = 1;
        bits[0] = 1;
        bits[1] = 1;
        bits[2] = 0;
        bits[3] = 1;
        bits[4] = 0;
        tie_1 = 0;
        tie_2 = 0;
        #10
        en = 0;
        #90
        en = 1;
        bits[0] = 1;
        bits[1] = 1;
        bits[2] = 1;
        bits[3] = 1;
        bits[4] = 1;
        tie_1 = 0;
        tie_2 = 0;
        #10
        en = 0;
        #95
        $finish;
    end
    endmodule