`timescale 1ns / 1ps
 
module tb_bundler_odd_v2;

  // General Params
  localparam DIMENSIONS = 5;

  // Bundler Params
  localparam NUM_HVS = 5;

  // Port declarations
  reg clk;
  reg [DIMENSIONS-1:0] hv_array [NUM_HVS - 1:0];
  wire [DIMENSIONS - 1:0] hvout;

 
  bundler_ch_v2 #(
    .DIMENSIONS(DIMENSIONS),
    .NUM_HVS(NUM_HVS)
  ) 
  u_bundler_ch_v2(
      .hv_array  (hv_array),
      .hvout  (hvout)
  );
 
  initial begin
    $vcdplusfile("tb_bundler_odd.vpd");
    $vcdpluson;
    clk = 0;
    hv_array[0] = 5'b0;
    hv_array[1] = 5'b0;
    hv_array[2] = 5'b0;
    hv_array[3] = 5'b0;
    hv_array[4] = 5'b0;
    #200
    clk = 1;
    #200
    hv_array[0] = 5'b01101;
    #200
    hv_array[1] = 5'b00111;
    #200
    hv_array[2] = 5'b01111;
    #200
    hv_array[3] = 5'b00011;
    #200
    hv_array[4] = 5'b00011;
    #200
    hv_array[0] = 4'b0010;
    hv_array[1] = 4'b0000;
    hv_array[2] = 4'b1000;
    hv_array[3] = 4'b0100;
    hv_array[4] = 4'b0100;
    #600
    $finish;
  end
endmodule