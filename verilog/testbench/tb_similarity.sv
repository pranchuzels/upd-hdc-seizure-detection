`timescale 1ns / 1ps
 
module tb_similarity;

  // General Params
  localparam DIMENSIONS = 10;

  // Port declarations
  reg [DIMENSIONS - 1 : 0] hv;
  reg [DIMENSIONS - 1 : 0] ns_hv;
  reg [DIMENSIONS - 1 : 0] s_hv;
  wire label_out;

 
  similarity #(
    .DIMENSIONS(DIMENSIONS)
  ) 
  u_similarity(
      .hv(hv),
      .ns_hv(ns_hv),
      .s_hv(s_hv),
      .label_out(label_out)
  );
 
  initial begin
    $vcdplusfile("tb_similarity.vpd");
    $vcdpluson;
    hv = 10'b0;
    ns_hv = 10'b0000000000;
    s_hv = 10'b1111111111;
    #200
    hv = 10'b0110000100;
    #200
    hv = 10'b0000000000;
    #200
    hv = 10'b0110110110;
    #200
    hv = 10'b1110011111;
    #200
    hv = 10'b1111111111;
    #200
    hv = 10'b0000000000;
    #200
    $finish;
  end
endmodule