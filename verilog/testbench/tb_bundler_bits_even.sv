`timescale 1ns / 1ps
module tb_bundler_bits_even; 
    localparam T = 10;  // clock period in ms
    
    // bundler_bits params
    localparam NUM_HVS = 6;
    localparam PAR_BITS = 2;

    // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [NUM_HVS - 1:0][PAR_BITS - 1: 0] bits;
    reg [PAR_BITS - 1: 0] ties_1;
    reg [PAR_BITS - 1: 0] ties_2;
    wire done;
    wire [PAR_BITS - 1: 0] out_bits;

    
    bundler_bits #(
        .NUM_HVS(NUM_HVS),
        .PAR_BITS(PAR_BITS)
    ) 
    u_bundler_bits (
        .clk (clk),
        .nrst (nrst),
        .en (en),
        .bits  (bits),
        .ties_1 (ties_1),
        .ties_2 (ties_2),
        .done (done),
        .out_bits (out_bits)
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
        bits[0] = 2'b0;
        bits[1] = 2'b0;
        bits[2] = 2'b0;
        bits[3] = 2'b0;
        bits[4] = 2'b0;
        bits[5] = 2'b0;
        ties_1 = 2'b0;
        ties_2 = 2'b0;
        #95
        nrst = 1;
        en = 1;
        bits[0] = 2'b00;
        bits[1] = 2'b00;
        bits[2] = 2'b01;
        bits[3] = 2'b00;
        bits[4] = 2'b00;
        bits[5] = 2'b11;
        ties_1 = 2'b00;
        ties_2 = 2'b00;
        #10
        en = 0;
        #90
        en = 1;
        bits[0] = 6'b100101;
        bits[1] = 6'b101001;
        bits[0] = 2'b11;
        bits[1] = 2'b00;
        bits[2] = 2'b10;
        bits[3] = 2'b01;
        bits[4] = 2'b00;
        bits[5] = 2'b11;
        ties_1 = 2'b00;
        ties_2 = 2'b10;
        #10
        en = 0;
        #90
        en = 1;
        bits[0] = 6'b101100;
        bits[1] = 6'b111111;
        bits[0] = 2'b11;
        bits[1] = 2'b10;
        bits[2] = 2'b11;
        bits[3] = 2'b11;
        bits[4] = 2'b10;
        bits[5] = 2'b10;
        ties_1 = 2'b01;
        ties_2 = 2'b01;
        #10
        en = 0;
        #95
        $finish;
    end
    endmodule