module test_bundler (
    clk,
    nrst,
    hv1,
    hv2,
    hvout
);

    parameter DIMENSIONS = 10000;
    input clk;
    input nrst;
    input [DIMENSIONS - 1:0] hv1;
    input [DIMENSIONS - 1:0] hv2;
    output reg [DIMENSIONS - 1:0] hvout;

    always_ff @(clk) begin
        if (!nrst) begin
            hvout <= 0;
        end else begin
            hvout <= hv1 ^ hv2;
        end
    end
endmodule