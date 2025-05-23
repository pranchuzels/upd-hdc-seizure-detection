`timescale 1ns / 1ps
module bundler_cont (
    clk,
    nrst,
    en,
    finish,
    hv_in,
    hv_out
);

    parameter DIMENSIONS = 10000;
    parameter COUNT_SIZE = 8;


    input clk;
    input nrst;
    input en;
    input finish;
    input [DIMENSIONS - 1:0] hv_in;
    output reg [DIMENSIONS - 1:0] hv_out;

    reg [DIMENSIONS - 1:0][COUNT_SIZE - 1 : 0] counters_hv;
    reg [COUNT_SIZE : 0] counter;
    

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            hv_out <= 0;
            counters_hv <= 0;
            counter <= 0;
        end
        else begin
            if (finish) begin
                for (int i = 0; i < DIMENSIONS; i = i + 1) begin
                    if (counters_hv[i] > counter/2) begin
                        hv_out[i] <= 1;
                    end
                    else begin
                        hv_out[i] <= 0;
                    end
                end
                counters_hv <= 0;
                counter <= 0;
            end
            else if (en) begin
                for (int i = 0; i < DIMENSIONS; i = i + 1) begin
                    counters_hv[i] <= counters_hv[i] + hv_in[i];
                end
                counter <= counter + 1;
            end
        end
    end
endmodule