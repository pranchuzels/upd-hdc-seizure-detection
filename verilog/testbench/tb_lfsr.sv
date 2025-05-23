`timescale 1ns / 1ps
 
module tb_lfsr;
  localparam T = 1000;  // clock period in ns

  localparam NUM_REGS = 8;
  localparam SEED = 8'b10010110;
  localparam [$clog2(NUM_REGS) - 1: 0] TAPS [3: 0] = {0, 2, 3, 4};

  reg clk;
  reg nrst;
  reg en;
  wire [10000 - 1: 0] out_ties;
 
  lfsr #(
    .NUM_REGS(NUM_REGS),
    .SEED(SEED),
    .TAPS(TAPS)
  ) 
  u_lfsr (
      .clk  (clk),
      .nrst (nrst),
      .en   (en),
      .out_ties  (out_ties)
  );
  
  // Clock
  always begin
    clk = 1'b1;
    #(T / 2);
    clk = 1'b0;
    #(T / 2);
  end
 
  initial begin
    // $vcdplusfile("tb_lfsr.vpd");
    // $vcdpluson;
    nrst = 1'b0;
    en = 0;
    #15
    nrst = 1'b1;
    for (int i = 0; i < 5; i = i + 1) begin
      en = 1;
      # 1000
      en = 0;
    end
    # 15
    $finish;
  end
endmodule