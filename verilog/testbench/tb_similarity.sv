`timescale 1ns / 1ps
 
module tb_similarity;
    localparam T = 10;  // clock period in ms

  // General Params
  localparam DIMENSIONS = 5;

  // Port declarations
    reg clk;
    reg nrst;
    reg en;
    reg [DIMENSIONS - 1 : 0] hv_test;
    reg [DIMENSIONS - 1 : 0] hv_nonseizure;
    reg [DIMENSIONS - 1 : 0] hv_seizure;
    wire done;
    wire label;
 
  similarity #(
    .DIMENSIONS(DIMENSIONS)
  ) 
  u_similarity(
        .clk(clk),
        .nrst(nrst),
        .en(en),
        .hv_test(hv_test),
        .hv_nonseizure(hv_nonseizure),
        .hv_seizure(hv_seizure),
        .done(done),
        .label(label)
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
        hv_test = 5'b0;
        hv_nonseizure = 5'b00000;
        hv_seizure = 5'b11111;
        # (20 - 5)
        nrst = 1;
        en = 1;
        hv_test = 5'b00001;
        # (5 + 5)
        en = 0;
        # (100 - 5 - 5)
        en = 1;
        hv_test = 5'b00101;
        # (5 + 5)
        en = 0;
        # (100 - 5 - 5)
        en = 1;
        hv_test = 5'b11010;
        # (5 + 5)
        en = 0;
        # (100 - 5 - 5)
        en = 1;
        hv_test = 5'b11111;
        # (5 + 5)
        en = 0;
        # (100 - 5)
        $finish;
    end
endmodule