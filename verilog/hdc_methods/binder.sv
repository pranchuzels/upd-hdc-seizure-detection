`timescale 1ns / 1ps

module binder (
    hv_1,
    hv_2,
    hv_out
);

    parameter DIMENSIONS = 10000;

    input [DIMENSIONS - 1:0] hv_1;
    input [DIMENSIONS - 1:0] hv_2;
    output logic [DIMENSIONS - 1:0] hv_out;
    
    always_comb begin
        hv_out = hv_1 ^ hv_2;
    end

endmodule