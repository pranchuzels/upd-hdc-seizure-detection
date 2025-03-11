`timescale 1ns / 1ps

module binder (
    hv1,
    hv2,
    hvout
);

    parameter DIMENSIONS = 10000;

    input [DIMENSIONS - 1:0] hv1;
    input [DIMENSIONS - 1:0] hv2;
    output [DIMENSIONS - 1:0] hvout;
    
    assign hvout =  hv1 ^ hv2;

endmodule