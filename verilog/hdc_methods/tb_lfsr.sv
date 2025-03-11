`timescale 1ns / 1ps
 
module tb_lfsr;
  localparam T = 10;  // clock period in ns
  localparam SEED = 16'b1001010010110101;
  reg clk;
  reg nrst;
  wire out;
 
  lfsr #(
    .SEED(SEED)
  ) 
  u_lfsr(
      .clk  (clk ),
      .nrst (nrst),
      .out  (out )
  );
  
  // Clock
  always begin
    clk = 1'b1;
    #(T / 2);
    clk = 1'b0;
    #(T / 2);
  end
 
  initial begin
    $vcdplusfile("tb_lfsr.vpd");
    $vcdpluson;
    nrst = 1'b0;
    #(T / 2);
    nrst = 1'b1;
    #200
    $finish;
  end
endmodule