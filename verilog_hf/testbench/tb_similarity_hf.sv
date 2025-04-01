`timescale 1ns / 1ps
 
module tb_similarity_hf;
    localparam T = 10;  // clock period in ms

  // General Params
  localparam DIMENSIONS = 5;

  // Port declarations
  reg clk;
  reg nrst;
  reg en;
  reg [DIMENSIONS - 1 : 0] hv;
  reg [DIMENSIONS - 1 : 0] ns_hv;
  reg [DIMENSIONS - 1 : 0] s_hv;
  wire out;
  wire label_out;

 
  similarity_hf #(
    .DIMENSIONS(DIMENSIONS)
  ) 
  u_similarity(
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .hv(hv),
        .ns_hv(ns_hv),
        .s_hv(s_hv),
        .out(out),
        .label_out(label_out)
    );

    // Clock
    always begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end

    initial begin
        // $vcdplusfile("tb_similarity.vpd");
        // $vcdpluson;
        nrst = 0;
        en = 0;
        hv = 5'b0;
        ns_hv = 5'b00000;
        s_hv = 5'b11111;
        #95
        nrst = 1;
        en = 1;
        hv = 5'b00001;
        #10
        en = 0;
        #90
        en = 1;
        hv = 5'b00101;
        #10
        en = 0;
        #90
        en = 1;
        hv = 5'b11011;
        #10
        en = 0;
        #90
        en = 1;
        hv = 5'b11111;
        #10
        en = 0;
        #95
        $finish;
    end
endmodule