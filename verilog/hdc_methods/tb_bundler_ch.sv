`timescale 1ns / 1ps
 
module tb_bundler_ch;

  localparam DIMENSIONS = 4;
  localparam NUM_CHS = 17;
  reg [DIMENSIONS-1:0] hv_array [NUM_CHS - 1:0];
  wire [DIMENSIONS - 1:0] hvout;

 
  bundler_ch #(
    .DIMENSIONS(DIMENSIONS)
  ) 
  u_bundler_ch(
      .hv_array  (hv_array),
      .hvout  (hvout)
  );
 
  initial begin
    $vcdplusfile("tb_bundler_ch.vpd");
    $vcdpluson;
    hv_array[0] = 4'b0110;
    #200
    hv_array[1] = 4'b0110;
    #200
    hv_array[2] = 4'b0110;
    #200
    hv_array[3] = 4'b0110;
    #200
    hv_array[4] = 4'b0100;
    #200
    hv_array[5] = 4'b1000;
    #200
    hv_array[6] = 4'b0000;
    #200
    hv_array[7] = 4'b0000;
    #200
    hv_array[8] = 4'b1001;
    #200
    hv_array[9] = 4'b0001;
    #200
    hv_array[10] = 4'b0101;
    #200
    hv_array[11] = 4'b0101;
    #200
    hv_array[12] = 4'b0101;
    #200
    hv_array[13] = 4'b0101;
    #200
    hv_array[14] = 4'b0101;
    #200
    hv_array[15] = 4'b0101;
    #200
    hv_array[16] = 4'b0101;
    #200
    hv_array[0] = 4'b0010;
    hv_array[1] = 4'b0010;
    hv_array[2] = 4'b0010;
    hv_array[3] = 4'b0110;
    hv_array[4] = 4'b0100;
    hv_array[5] = 4'b1000;
    hv_array[6] = 4'b0000;
    hv_array[7] = 4'b0000;
    hv_array[8] = 4'b1001;
    hv_array[9] = 4'b0001;
    hv_array[10] = 4'b0100;
    hv_array[11] = 4'b0000;
    hv_array[12] = 4'b0000;
    hv_array[13] = 4'b0000;
    hv_array[14] = 4'b0101;
    hv_array[15] = 4'b0101;
    hv_array[16] = 4'b0101;
    #200
    $finish;
  end
endmodule